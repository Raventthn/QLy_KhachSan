USE QL_KhachSan;
GO

CREATE OR ALTER VIEW dbo.vw_QuyetToanBooking
AS
WITH GiaoDichTheoBooking AS (
    SELECT
        tt.MaDatPhong,
        CAST(SUM(CASE
            WHEN tt.LoaiGiaoDich IN (N'Đặt cọc', N'Thanh toán')
                THEN tt.SoTien
            ELSE 0
        END) AS DECIMAL(28, 2)) AS TongDaThu,
        CAST(SUM(CASE
            WHEN tt.LoaiGiaoDich = N'Hoàn tiền'
                THEN tt.SoTien
            ELSE 0
        END) AS DECIMAL(28, 2)) AS TongDaHoan,
        COUNT_BIG(*) AS SoGiaoDich,
        SUM(CAST(CASE
            WHEN tt.LoaiGiaoDich IS NULL
              OR tt.LoaiGiaoDich NOT IN
                 (N'Đặt cọc', N'Thanh toán', N'Hoàn tiền')
              OR tt.SoTien IS NULL OR tt.SoTien <= 0
                THEN 1
            ELSE 0
        END AS BIGINT)) AS SoGiaoDichBatThuong,
        MAX(tt.NgayGD) AS NgayGiaoDichGanNhat
    FROM dbo.THANHTOAN AS tt
    GROUP BY tt.MaDatPhong
),
DuLieuBooking AS (
    SELECT
        dp.MaDatPhong,
        dp.MaKH,
        kh.HoTen AS TenKhachHang,
        kh.SDT,
        dp.TrangThai AS TrangThaiBooking,
        dp.Version,
        dp.TongTien AS TongTienBookingGoc,
        CAST(CASE
            WHEN dp.TrangThai = N'Đã hủy' THEN 0
            ELSE dp.TongTien
        END AS DECIMAL(18, 2)) AS TongPhaiTra,
        ISNULL(gd.TongDaThu, CAST(0 AS DECIMAL(28, 2))) AS TongDaThu,
        ISNULL(gd.TongDaHoan, CAST(0 AS DECIMAL(28, 2))) AS TongDaHoan,
        ISNULL(gd.SoGiaoDich, 0) AS SoGiaoDich,
        ISNULL(gd.SoGiaoDichBatThuong, 0) AS SoGiaoDichBatThuong,
        gd.NgayGiaoDichGanNhat
    FROM dbo.DAT_PHONG AS dp
    INNER JOIN dbo.KHACHHANG AS kh ON kh.MaKH = dp.MaKH
    LEFT JOIN GiaoDichTheoBooking AS gd ON gd.MaDatPhong = dp.MaDatPhong
),
KiemTraDuLieu AS (
    SELECT
        dl.*,
        CAST(dl.TongDaThu - dl.TongDaHoan AS DECIMAL(28, 2))
            AS DaThanhToanRong,
        CAST(CASE
            WHEN dl.SoGiaoDichBatThuong > 0
              OR dl.TongDaHoan > dl.TongDaThu
              OR dl.TrangThaiBooking IS NULL
              OR dl.TrangThaiBooking NOT IN
                 (N'Đã đặt', N'Đang ở', N'Đã trả', N'Đã hủy')
              OR dl.TongPhaiTra IS NULL OR dl.TongPhaiTra < 0
                THEN 1
            ELSE 0
        END AS BIT) AS CoDuLieuBatThuong
    FROM DuLieuBooking AS dl
),
TinhSoDu AS (
    SELECT
        kt.*,
        CAST(CASE
            WHEN kt.CoDuLieuBatThuong = 1 THEN NULL
            ELSE kt.TongPhaiTra - kt.DaThanhToanRong
        END AS DECIMAL(28, 2)) AS SoDuQuyetToan
    FROM KiemTraDuLieu AS kt
)
SELECT
    sd.MaDatPhong,
    sd.MaKH,
    sd.TenKhachHang,
    sd.SDT,
    sd.TrangThaiBooking,
    sd.Version,
    sd.TongTienBookingGoc,
    sd.TongPhaiTra,
    sd.TongDaThu,
    sd.TongDaHoan,
    sd.DaThanhToanRong,
    sd.SoDuQuyetToan,
    CAST(CASE
        WHEN sd.CoDuLieuBatThuong = 1 THEN NULL
        WHEN sd.SoDuQuyetToan > 0 THEN sd.SoDuQuyetToan
        ELSE 0
    END AS DECIMAL(28, 2)) AS ConPhaiTra,
    CAST(CASE
        WHEN sd.CoDuLieuBatThuong = 1 THEN NULL
        WHEN sd.SoDuQuyetToan < 0 THEN -sd.SoDuQuyetToan
        ELSE 0
    END AS DECIMAL(28, 2)) AS CanHoanTien,
    CAST(CASE
        WHEN sd.CoDuLieuBatThuong = 1 THEN NULL
        WHEN sd.SoDuQuyetToan = 0 THEN 1
        ELSE 0
    END AS BIT) AS DaCanDoiTien,
    CASE
        WHEN sd.CoDuLieuBatThuong = 1 THEN N'Dữ liệu cần kiểm tra'
        WHEN sd.SoDuQuyetToan > 0 THEN N'Còn phải thu'
        WHEN sd.SoDuQuyetToan < 0 THEN N'Cần hoàn tiền'
        ELSE N'Đã cân đối'
    END AS TrangThaiQuyetToan,
    sd.SoGiaoDich,
    sd.SoGiaoDichBatThuong,
    sd.CoDuLieuBatThuong,
    sd.NgayGiaoDichGanNhat
FROM TinhSoDu AS sd;
GO