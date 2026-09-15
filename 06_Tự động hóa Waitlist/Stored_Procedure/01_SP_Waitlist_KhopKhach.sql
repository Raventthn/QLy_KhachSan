USE QL_KhachSan;
GO

CREATE OR ALTER PROCEDURE dbo.sp_Waitlist_KhopKhach
    @MaLoai VARCHAR(10),
    @NgayTrong DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @@TRANCOUNT <> 0
        THROW 50301, N'Procedure phải được gọi ngoài transaction đang mở.', 1;

    SET XACT_ABORT ON;
    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

    IF @MaLoai IS NULL OR LTRIM(RTRIM(@MaLoai)) = ''
        THROW 50302, N'Mã loại phòng không được để trống.', 1;

    IF @NgayTrong IS NULL
        THROW 50303, N'Ngày phòng trống không được để trống.', 1;

    DECLARE @MaWaitlist INT;
    DECLARE @MaKH VARCHAR(10);

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT TOP (1)
            @MaWaitlist = ds.MaWaitlist,
            @MaKH = ds.MaKH
        FROM dbo.DANHSACHCHO AS ds WITH (UPDLOCK, HOLDLOCK, ROWLOCK)
        WHERE ds.MaLoai = @MaLoai
          AND ds.TrangThai = N'Đang chờ'
          AND ds.NgayMongMuon <= @NgayTrong
        ORDER BY ds.MaWaitlist ASC;

        IF @MaWaitlist IS NULL
        BEGIN
            COMMIT TRANSACTION;

            SELECT
                CAST(NULL AS INT) AS MaWaitlist,
                CAST(NULL AS VARCHAR(10)) AS MaKH,
                CAST(NULL AS NVARCHAR(100)) AS HoTen,
                CAST(NULL AS VARCHAR(15)) AS SDT,
                CAST(0 AS BIT) AS DaKhopKhach;

            RETURN;
        END;

        UPDATE dbo.DANHSACHCHO
        SET TrangThai = N'Đến lượt'
        WHERE MaWaitlist = @MaWaitlist
          AND TrangThai = N'Đang chờ';

        IF @@ROWCOUNT <> 1
            THROW 50304, N'Không thể cập nhật trạng thái waitlist. Vui lòng thử lại.', 1;

        COMMIT TRANSACTION;

        SELECT
            ds.MaWaitlist,
            ds.MaKH,
            kh.HoTen,
            kh.SDT,
            CAST(1 AS BIT) AS DaKhopKhach
        FROM dbo.DANHSACHCHO AS ds
        INNER JOIN dbo.KHACHHANG AS kh ON kh.MaKH = ds.MaKH
        WHERE ds.MaWaitlist = @MaWaitlist;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
