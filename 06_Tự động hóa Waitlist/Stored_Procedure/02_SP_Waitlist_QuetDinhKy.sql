USE QL_KhachSan;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Waitlist_QuetDinhKy
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    DECLARE @Ngay DATE = CONVERT(DATE, GETDATE());
    DECLARE @MaLoai VARCHAR(10);
    DECLARE @SoPhongTrong INT;
    DECLARE @DaKhop INT;
    DECLARE @KetQua TABLE (
        MaWaitlist INT NULL,
        MaKH VARCHAR(10) NULL,
        HoTen NVARCHAR(100) NULL,
        SDT VARCHAR(15) NULL,
        DaKhopKhach BIT
    );

    DECLARE cur_loai CURSOR LOCAL FAST_FORWARD FOR
        SELECT p.MaLoai, COUNT(*) AS SoPhongTrong
        FROM dbo.PHONG_NGAY AS pn
        INNER JOIN dbo.PHONG AS p ON p.MaPhong = pn.MaPhong
        WHERE pn.MaDatPhong IS NULL
          AND pn.Ngay = @Ngay
        GROUP BY p.MaLoai;

    OPEN cur_loai;
    FETCH NEXT FROM cur_loai INTO @MaLoai, @SoPhongTrong;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DaKhop = 0;

        WHILE @DaKhop < @SoPhongTrong
        BEGIN
            DELETE FROM @KetQua;

            INSERT INTO @KetQua
            EXEC dbo.sp_Waitlist_KhopKhach @MaLoai = @MaLoai, @NgayTrong = @Ngay;

            IF NOT EXISTS (SELECT 1 FROM @KetQua WHERE DaKhopKhach = 1)
                BREAK;

            SET @DaKhop = @DaKhop + 1;
        END;

        FETCH NEXT FROM cur_loai INTO @MaLoai, @SoPhongTrong;
    END;

    CLOSE cur_loai;
    DEALLOCATE cur_loai;
END;
GO
