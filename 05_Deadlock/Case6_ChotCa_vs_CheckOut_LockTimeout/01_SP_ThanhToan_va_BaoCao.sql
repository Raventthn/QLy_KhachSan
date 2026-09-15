USE QL_KhachSan;
GO

-- =====================================================================
-- KỊCH BẢN DEADLOCK 2: Chốt ca (đọc báo cáo) vs Check-out trễ (ghi dữ liệu)
-- Bảng liên quan: DATPHONG, THANHTOAN
--
-- T1 — SP_ThanhToan (Lễ tân check-out cho khách):
--      UPDATE DATPHONG (X-lock)  ->  INSERT THANHTOAN (cần X-lock)
-- T2 — SP_BaoCao_Loi (Quản lý chốt ca cuối ngày):
--      SELECT SUM THANHTOAN (S-lock, giữ tới hết transaction nhờ SERIALIZABLE)
--      -> SELECT DATPHONG (cần đọc, đụng X-lock của T1)
-- => T2 chờ T1 nhả DATPHONG, T1 chờ T2 nhả THANHTOAN -> Deadlock (lỗi 1205)
--
-- LƯU Ý KỸ THUẬT QUAN TRỌNG:
-- Mức mặc định READ COMMITTED sẽ nhả Share Lock ngay sau khi SELECT xong,
-- nên T1 sẽ KHÔNG BAO GIỜ bị chặn khi INSERT vào THANHTOAN -> không có
-- deadlock nào xảy ra cả. Bắt buộc phải đặt SERIALIZABLE (hoặc dùng hint
-- khóa bảng) cho phần đọc báo cáo thì Share Lock mới được giữ tới COMMIT
-- và mới đủ sức chặn được cả INSERT dòng mới (range lock).
-- Trước khi demo, hãy đảm bảo DB KHÔNG bật READ_COMMITTED_SNAPSHOT, vì nếu
-- bật, SQL Server dùng row-versioning và reader sẽ không chặn writer nữa:
--   SELECT is_read_committed_snapshot_on FROM sys.databases WHERE name = 'QL_KhachSan';
-- =====================================================================

-- ---------------------------------------------------------------------
-- Giao tác GHI: Lễ tân Check-out & thanh toán cho khách
-- ---------------------------------------------------------------------
CREATE OR ALTER PROC SP_ThanhToan
    @MaGD VARCHAR(10),
    @MaDatPhong VARCHAR(10),
    @SoTien DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        -- Bước 1: khóa Exclusive trên DATPHONG (đồng thời chặn double check-out)
        UPDATE DATPHONG
        SET TrangThai = N'Đã trả'
        WHERE MaDatPhong = @MaDatPhong AND TrangThai <> N'Đã trả';

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRAN;
            THROW 51002, N'Đơn đặt phòng này đã được trả phòng/thanh toán trước đó.', 1;
        END

        -- ÉP TRANH CHẤP KHI DEMO (bỏ dòng này khi chạy thật):
        WAITFOR DELAY '00:00:05';

        -- Bước 2: chèn dòng doanh thu -> cần khóa Exclusive trên THANHTOAN
        INSERT INTO THANHTOAN (MaGD, MaDatPhong, SoTien, LoaiGiaoDich)
        VALUES (@MaGD, @MaDatPhong, @SoTien, N'Thanh toán');

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRAN;
        THROW; -- giữ nguyên mã lỗi 1205/1222 cho Backend tự phân loại
    END CATCH
END
GO

-- ---------------------------------------------------------------------
-- Giao tác ĐỌC (BẢN LỖI): Báo cáo chốt ca - chờ vô thời hạn, dễ dính deadlock
-- ---------------------------------------------------------------------
CREATE OR ALTER PROC SP_BaoCao_Loi
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @TongDoanhThu DECIMAL(18,2);
        SELECT @TongDoanhThu = SUM(SoTien) FROM THANHTOAN;

        -- ÉP TRANH CHẤP KHI DEMO (bỏ dòng này khi chạy thật):
        WAITFOR DELAY '00:00:05';

        DECLARE @SoKhachDangO INT;
        SELECT @SoKhachDangO = COUNT(*) FROM DATPHONG WHERE TrangThai = N'Đang ở';

        SELECT @TongDoanhThu AS TongDoanhThu, @SoKhachDangO AS SoKhachDangO;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO

-- ---------------------------------------------------------------------
-- Giao tác ĐỌC (BẢN ĐÃ SỬA): thêm LOCK_TIMEOUT để chủ động "nhường" thay vì
-- chờ đến khi SQL Server tự phát hiện và xử lý deadlock (1205).
-- ---------------------------------------------------------------------
CREATE OR ALTER PROC SP_BaoCao
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET LOCK_TIMEOUT 3000; -- tối đa chờ khóa 3 giây, quá thời gian tự văng lỗi 1222
    SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;

    BEGIN TRY
        BEGIN TRAN;

        DECLARE @TongDoanhThu DECIMAL(18,2);
        SELECT @TongDoanhThu = SUM(SoTien) FROM THANHTOAN;

        WAITFOR DELAY '00:00:05';

        DECLARE @SoKhachDangO INT;
        SELECT @SoKhachDangO = COUNT(*) FROM DATPHONG WHERE TrangThai = N'Đang ở';

        SELECT @TongDoanhThu AS TongDoanhThu, @SoKhachDangO AS SoKhachDangO;

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        -- LƯU Ý: SET XACT_ABORT ON KHÔNG tự động rollback với lỗi 1222
        -- (Lock request time out) — đây là 1 ngoại lệ đã được Microsoft
        -- ghi nhận — nên BẮT BUỘC phải tự kiểm tra và ROLLBACK ở đây.
        IF (XACT_STATE()) <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO
