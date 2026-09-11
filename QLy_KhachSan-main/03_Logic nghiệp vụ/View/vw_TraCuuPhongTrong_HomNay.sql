CREATE OR ALTER VIEW vw_TraCuuPhongTrong_HomNay AS
SELECT 
    p.MaPhong,
    p.SoPhong,
    lp.TenLoai,
    lp.GiaCoBan
FROM PHONG p
JOIN LOAIPHONG lp ON p.MaLoai = lp.MaLoai
JOIN PHONG_NGAY pn ON p.MaPhong = pn.MaPhong
WHERE pn.Ngay = CAST(GETDATE() AS DATE) 
  AND pn.MaDatPhong IS NULL;


SELECT * FROM vw_TraCuuPhongTrong_HomNay;