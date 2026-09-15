USE QL_KhachSan;
GO

CREATE OR ALTER PROC sp_NoShow_NhaPhong
    @MaGD VARCHAR(10),
    @MaDatPhong VARCHAR(10),
    @PhiPhat DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    DECLARE @PhongDaNha TABLE (MaPhong VARCHAR(10), Ngay DATE);

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
        OUTPUT inserted.MaPhong, inserted.Ngay INTO @PhongDaNha
        WHERE MaDatPhong = @MaDatPhong;

        INSERT INTO THANHTOAN (MaGD, MaDatPhong, SoTien, LoaiGiaoDich)
        VALUES (@MaGD, @MaDatPhong, @PhiPhat, N'Phạt No-show');

        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        IF (XACT_STATE()) <> 0 ROLLBACK TRAN;
        THROW;
    END CATCH

    BEGIN TRY
        DECLARE @Queue TABLE (MaLoai VARCHAR(10), Ngay DATE);

        INSERT INTO @Queue (MaLoai, Ngay)
        SELECT DISTINCT p.MaLoai, pn.Ngay
        FROM @PhongDaNha AS pn
        INNER JOIN PHONG AS p ON p.MaPhong = pn.MaPhong;

        DECLARE @MaLoaiCT VARCHAR(10), @NgayCT DATE;

        WHILE EXISTS (SELECT 1 FROM @Queue)
        BEGIN
            SELECT TOP (1) @MaLoaiCT = MaLoai, @NgayCT = Ngay FROM @Queue;
            EXEC dbo.sp_Waitlist_KhopKhach @MaLoai = @MaLoaiCT, @NgayTrong = @NgayCT;
            DELETE FROM @Queue WHERE MaLoai = @MaLoaiCT AND Ngay = @NgayCT;
        END;
    END TRY
    BEGIN CATCH
    END CATCH
END
GO
