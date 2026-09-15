USE QL_KhachSan;
GO

CREATE OR ALTER VIEW dbo.vw_BaoCao_DoanhThu_LoaiPhong
AS

SELECT
    lp.MaLoai,
    lp.TenLoai,

    COUNT(DISTINCT dp.MaDatPhong) AS SoLuongBooking,

    CAST(
        SUM(ISNULL(dp.TongTien,0))
        AS DECIMAL(18,2)
    ) AS TongDoanhThu

FROM LOAIPHONG lp

LEFT JOIN PHONG p
    ON lp.MaLoai = p.MaLoai

LEFT JOIN PHONG_NGAY pn
    ON p.MaPhong = pn.MaPhong

LEFT JOIN DATPHONG dp
    ON pn.MaDatPhong = dp.MaDatPhong

GROUP BY
    lp.MaLoai,
    lp.TenLoai;


GO