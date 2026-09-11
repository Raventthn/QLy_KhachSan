-- 1. Cập nhật bảng DATPHONG 
ALTER TABLE DATPHONG 
ALTER COLUMN MaNV VARCHAR(10) NULL;
GO

USE QL_KhachSan;
GO

-- ==============================
	/*NÂNG CẤP: chuyển 2 SP từ kiểu kiểm tra @@ERROR/@@ROWCOUNT cũ
		sang TRY/CATCH + SET XACT_ABORT ON để bắt được cả các lỗi runtime
		ngoài dự kiến (deadlock 1205, lock timeout 1222, vi phạm ràng buộc...)
		không chỉ các lỗi logic (điều kiện WHERE không khớp) như bản cũ.

	MERGE VỚI NHÁNH MAIN (schema mới của nhóm): bảng DATPHONG đã được
		bổ sung cột TongTien DECIMAL(18,2) NOT NULL, không có giá trị mặc
		định -> SP tạo booking bắt buộc phải tự tính và truyền giá trị
		này khi INSERT, nếu không sẽ báo lỗi
		"Cannot insert the value NULL into column 'TongTien'".
		Cách tính tạm thời: GiaCoBan (LOAIPHONG) x số đêm ở. Nếu sau này
		Thành viên 2 hoàn thành Function tính tổng tiền riêng, có thể thay
		đoạn tính @TongTien bên dưới bằng lệnh gọi Function đó.
	*/
-- ==============================

-- 2. Stored Procedure TẠO BOOKING MỚI (bản nâng cấp TRY/CATCH + tính TongTien)
CREATE OR ALTER PROC sp_Booking_TaoMoi
    @MaDatPhong VARCHAR(10),
    @MaKH VARCHAR(10),
    @MaPhong VARCHAR(10),
    @NgayNhan DATE,
    @NgayTra DATE,
    @MaNV VARCHAR(10) = NULL -- có thể NULL (online), có giá trị (lễ tân)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        -- Kiểm tra dữ liệu đầu vào trước khi mở transaction
        IF (@NgayTra <= @NgayNhan)
        BEGIN
            THROW 51000, N'Ngày trả phòng phải sau ngày nhận phòng.', 1;
        END

        -- Tính số đêm thực tế khách ở (cần trước để tính TongTien)
        DECLARE @SoDem INT = DATEDIFF(DAY, @NgayNhan, @NgayTra);

        -- THÊM MỚI (theo schema mới): tra giá phòng theo loại phòng để tính TongTien
        DECLARE @GiaCoBan DECIMAL(18,2);
        SELECT @GiaCoBan = lp.GiaCoBan
        FROM PHONG p
        JOIN LOAIPHONG lp ON lp.MaLoai = p.MaLoai
        WHERE p.MaPhong = @MaPhong;

        IF (@GiaCoBan IS NULL)
        BEGIN
            THROW 51006, N'Không tìm thấy phòng hoặc loại phòng tương ứng để tính giá.', 1;
        END

        DECLARE @TongTien DECIMAL(18,2) = @GiaCoBan * @SoDem;

        BEGIN TRAN;

        -- Bước 1: Ghi nhận đơn đặt phòng (đã bổ sung TongTien theo schema mới)
        INSERT INTO DATPHONG (MaDatPhong, MaKH, MaNV, TongTien, TrangThai, Version)
        VALUES (@MaDatPhong, @MaKH, @MaNV, @TongTien, N'Đã đặt', 1);

        -- THÊM DÒNG NÀY ĐỂ ÉP TRANH CHẤP KHI DEMO (bỏ khi chạy thật):
        WAITFOR DELAY '00:00:10';

        -- Bước 2: Khóa ngày trong bảng lịch phòng
        UPDATE PHONG_NGAY
        SET MaDatPhong = @MaDatPhong
        WHERE MaPhong = @MaPhong
          AND Ngay >= @NgayNhan AND Ngay < @NgayTra
          AND MaDatPhong IS NULL;

        -- Bước 3: Kiểm tra đủ số đêm thì chốt, thiếu thì hủy
        IF (@@ROWCOUNT <> @SoDem)
        BEGIN
            ROLLBACK TRAN;
            THROW 51001, N'Phòng đã bị người khác đặt mất một vài ngày trong khung thời gian này.', 1;
        END

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRAN;
        THROW; -- giữ nguyên mã lỗi gốc (vd 1205/1222/50xxx) cho Backend tự xử lý
    END CATCH
END
GO

-- 3. Stored Procedure XỬ LÝ NO-SHOW 
CREATE OR ALTER PROC sp_NoShow_NhaPhong
    @MaGD VARCHAR(10),
    @MaDatPhong VARCHAR(10),
    @PhiPhat DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRY
        BEGIN TRAN;

        UPDATE DATPHONG
        SET TrangThai = N'No-show', Version = Version + 1
        WHERE MaDatPhong = @MaDatPhong AND TrangThai = N'Đã đặt';

        IF (@@ROWCOUNT = 0)
        BEGIN
            ROLLBACK TRAN;
            THROW 51005, N'Đơn đặt phòng không ở trạng thái "Đã đặt" nên không thể xử lý No-show.', 1;
        END

        UPDATE PHONG_NGAY
        SET MaDatPhong = NULL
        WHERE MaDatPhong = @MaDatPhong;

        INSERT INTO THANHTOAN (MaGD, MaDatPhong, SoTien, LoaiGiaoDich)
        VALUES (@MaGD, @MaDatPhong, @PhiPhat, N'Phạt No-show');

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH
END
GO
