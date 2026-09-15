USE QL_KhachSan;
GO

-- =====================================================================
-- KỊCH BẢN DEADLOCK 1: Đặt gộp 2 phòng (Group Booking) cho cùng 1 khung ngày
-- Bảng liên quan: DATPHONG, PHONG_NGAY
--
-- T1 (Khách hàng đặt online): chọn V102 trước, rồi V101 sau (thứ tự UI hiện)
-- T2 (Lễ tân đặt đoàn tại quầy): chọn V101 trước, rồi V102 sau
-- => 2 giao tác khóa CHÉO nhau -> Deadlock (SQL Server tự kill 1 bên, lỗi 1205)
--
-- CẬP NHẬT (theo schema mới): DATPHONG đã có cột TongTien NOT NULL. Vì đây
-- là booking gộp 2 phòng trong CÙNG 1 ngày (@Ngay), TongTien được tính bằng
-- tổng GiaCoBan của cả 2 phòng (1 đêm/phòng).
-- =====================================================================

-- ---------------------------------------------------------------------
-- BẢN LỖI: khóa 2 phòng đúng theo thứ tự người dùng bấm chọn (không sắp xếp)
-- ---------------------------------------------------------------------
CREATE OR ALTER PROC SP_DatPhong_Loi
    @MaDatPhong VARCHAR(10),
    @MaKH VARCHAR(10),
    @MaNV VARCHAR(10) = NULL,
    @Ngay DATE,
    @MaPhong1 VARCHAR(10), -- phòng khách/lễ tân CLICK CHỌN TRƯỚC
    @MaPhong2 VARCHAR(10)  -- phòng CHỌN SAU
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- THÊM MỚI (theo schema mới): tính TongTien = tổng giá 2 phòng (1 đêm/phòng)
        DECLARE @TongTien DECIMAL(18,2);
        SELECT @TongTien = SUM(lp.GiaCoBan)
        FROM PHONG p JOIN LOAIPHONG lp ON lp.MaLoai = p.MaLoai
        WHERE p.MaPhong IN (@MaPhong1, @MaPhong2);

        BEGIN TRAN;

        INSERT INTO DATPHONG (MaDatPhong, MaKH, MaNV, TongTien, TrangThai, Version)
        VALUES (@MaDatPhong, @MaKH, @MaNV, @TongTien, N'Đã đặt', 1);

        -- Khóa phòng thứ 1 (đúng thứ tự click, KHÔNG sắp xếp lại)
        UPDATE PHONG_NGAY
        SET MaDatPhong = @MaDatPhong
        WHERE MaPhong = @MaPhong1 AND Ngay = @Ngay AND MaDatPhong IS NULL;

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRAN;
            THROW 51003, N'Một trong 2 phòng đã có người đặt, vui lòng chọn lại.', 1;
        END

        -- ÉP TRANH CHẤP KHI DEMO (bỏ dòng này khi chạy thật):
        WAITFOR DELAY '00:00:05';

        -- Khóa phòng thứ 2
        UPDATE PHONG_NGAY
        SET MaDatPhong = @MaDatPhong
        WHERE MaPhong = @MaPhong2 AND Ngay = @Ngay AND MaDatPhong IS NULL;

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRAN;
            THROW 51004, N'Một trong 2 phòng đã có người đặt, vui lòng chọn lại.', 1;
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRAN;
        THROW; -- giữ nguyên mã lỗi 1205 (deadlock victim) cho tầng gọi
    END CATCH
END
GO

-- ---------------------------------------------------------------------
-- BẢN ĐÃ SỬA: Giao thức sắp xếp thứ tự tài nguyên (Ordering Protocol)
-- Bất kể người dùng bấm chọn phòng nào trước, SP luôn tự sắp xếp lại và
-- xin khóa theo thứ tự CỐ ĐỊNH tăng dần theo MaPhong -> phá vỡ chu trình
-- chờ chéo -> không bao giờ deadlock nữa (chỉ còn chờ tuần tự bình thường).
-- ---------------------------------------------------------------------
CREATE OR ALTER PROC SP_DatPhong_Fix
    @MaDatPhong VARCHAR(10),
    @MaKH VARCHAR(10),
    @MaNV VARCHAR(10) = NULL,
    @Ngay DATE,
    @MaPhong1 VARCHAR(10),
    @MaPhong2 VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    -- Tiền xử lý: luôn xin khóa theo thứ tự tăng dần của MaPhong,
    -- không phụ thuộc thứ tự người dùng truyền vào.
    DECLARE @First VARCHAR(10), @Second VARCHAR(10);
    IF (@MaPhong1 < @MaPhong2)
    BEGIN
        SET @First = @MaPhong1; SET @Second = @MaPhong2;
    END
    ELSE
    BEGIN
        SET @First = @MaPhong2; SET @Second = @MaPhong1;
    END

    BEGIN TRY
        -- THÊM MỚI (theo schema mới): tính TongTien = tổng giá 2 phòng (1 đêm/phòng)
        DECLARE @TongTien DECIMAL(18,2);
        SELECT @TongTien = SUM(lp.GiaCoBan)
        FROM PHONG p JOIN LOAIPHONG lp ON lp.MaLoai = p.MaLoai
        WHERE p.MaPhong IN (@MaPhong1, @MaPhong2);

        BEGIN TRAN;

        INSERT INTO DATPHONG (MaDatPhong, MaKH, MaNV, TongTien, TrangThai, Version)
        VALUES (@MaDatPhong, @MaKH, @MaNV, @TongTien, N'Đã đặt', 1);

        UPDATE PHONG_NGAY
        SET MaDatPhong = @MaDatPhong
        WHERE MaPhong = @First AND Ngay = @Ngay AND MaDatPhong IS NULL;

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRAN;
            THROW 51003, N'Một trong 2 phòng đã có người đặt, vui lòng chọn lại.', 1;
        END

        WAITFOR DELAY '00:00:05';

        UPDATE PHONG_NGAY
        SET MaDatPhong = @MaDatPhong
        WHERE MaPhong = @Second AND Ngay = @Ngay AND MaDatPhong IS NULL;

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRAN;
            THROW 51004, N'Một trong 2 phòng đã có người đặt, vui lòng chọn lại.', 1;
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO
