USE QL_KhachSan;
GO

CREATE OR ALTER PROCEDURE dbo.sp_NhanPhong
    @MaDatPhong VARCHAR(10),
    @Version INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @@TRANCOUNT <> 0
        THROW 50001, N'Procedure phải được gọi ngoài transaction đang mở.', 1;

    SET XACT_ABORT ON;

    IF @MaDatPhong IS NULL OR LTRIM(RTRIM(@MaDatPhong)) = ''
        THROW 50002, N'Mã đặt phòng không được để trống.', 1;

    IF @Version IS NULL OR @Version < 1
        THROW 50003, N'Version phải là số nguyên dương.', 1;

    DECLARE @TrangThai NVARCHAR(50);
    DECLARE @VersionHienTai INT;
    DECLARE @NgayNhanSomNhat DATE;
    DECLARE @NgayNhanMuonNhat DATE;
    DECLARE @HomNay DATE;

    BEGIN TRY
        BEGIN TRANSACTION;

        SELECT
            @TrangThai = TrangThai,
            @VersionHienTai = Version
        FROM dbo.DATPHONG WITH (UPDLOCK, HOLDLOCK)
        WHERE MaDatPhong = @MaDatPhong;

        IF @VersionHienTai IS NULL
            THROW 50004, N'Booking không tồn tại.', 1;

        IF @TrangThai <> N'Đã đặt'
            THROW 50005, N'Chỉ được nhận phòng cho booking có trạng thái Đã đặt.', 1;

        IF @VersionHienTai <> @Version
            THROW 50006, N'Booking đã được thay đổi. Vui lòng tải lại dữ liệu.', 1;

        SELECT
            @NgayNhanSomNhat = MIN(Lich.NgayNhan),
            @NgayNhanMuonNhat = MAX(Lich.NgayNhan)
        FROM (
            SELECT MaPhong, MIN(Ngay) AS NgayNhan
            FROM dbo.PHONG_NGAY WITH (HOLDLOCK)
            WHERE MaDatPhong = @MaDatPhong
            GROUP BY MaPhong
        ) AS Lich;

        IF @NgayNhanSomNhat IS NULL
            THROW 50007, N'Booking chưa được phân bổ phòng.', 1;

        IF @NgayNhanSomNhat <> @NgayNhanMuonNhat
            THROW 50008, N'Các phòng trong booking phải có cùng ngày nhận.', 1;

        SET @HomNay = CONVERT(DATE, GETDATE());

        IF @NgayNhanSomNhat <> @HomNay
            THROW 50009, N'Chỉ được nhận phòng vào ngày bắt đầu đặt.', 1;

        UPDATE dbo.DATPHONG
        SET TrangThai = N'Đang ở',
            Version = Version + 1
        WHERE MaDatPhong = @MaDatPhong
          AND TrangThai = N'Đã đặt'
          AND Version = @Version;

        IF @@ROWCOUNT <> 1
            THROW 50010, N'Không thể nhận phòng. Vui lòng tải lại booking.', 1;

        SELECT
            @TrangThai = TrangThai,
            @VersionHienTai = Version
        FROM dbo.DATPHONG
        WHERE MaDatPhong = @MaDatPhong;

        COMMIT TRANSACTION;

        SELECT
            @MaDatPhong AS MaDatPhong,
            @TrangThai AS TrangThai,
            @VersionHienTai AS Version,
            N'Nhận phòng thành công.' AS ThongBao;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH;
END;
GO