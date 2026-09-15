USE QLKHACHSAN;
GO

CREATE OR ALTER VIEW dbo.vw_GiamSat_TrangThaiDatPhong
AS

SELECT
    dp.MaDatPhong,

    dp.MaKH,
    kh.HoTen AS TenKhachHang,

    dp.MaNV,
    nv.HoTen AS TenNhanVien,

    dp.TrangThai,

    dp.Version,

    dp.NgayTao,

    COUNT(pn.MaPhong) AS SoLuongPhong

FROM DATPHONG dp

INNER JOIN KHACHHANG kh
    ON dp.MaKH = kh.MaKH

INNER JOIN NHANVIEN nv
    ON dp.MaNV = nv.MaNV

LEFT JOIN PHONG_NGAY pn
    ON dp.MaDatPhong = pn.MaDatPhong

GROUP BY

    dp.MaDatPhong,

    dp.MaKH,
    kh.HoTen,

    dp.MaNV,
    nv.HoTen,

    dp.TrangThai,

    dp.Version,

    dp.NgayTao;

GO