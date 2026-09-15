USE QL_KhachSan;
GO

SELECT MaDatPhong, TrangThai, Version FROM DATPHONG WHERE MaDatPhong = 'DP001';

SELECT MaPhong, Ngay, MaDatPhong FROM PHONG_NGAY
WHERE MaPhong = 'P101' AND Ngay IN ('2026-10-01', '2026-10-02');

INSERT INTO DANHSACHCHO (MaKH, MaLoai, NgayMongMuon, TrangThai)
VALUES ('KH02', 'STD', '2026-10-01', N'Đang chờ');

SELECT * FROM DANHSACHCHO WHERE MaKH = 'KH02';

EXEC sp_NoShow_NhaPhong @MaGD = 'GD_TEST01', @MaDatPhong = 'DP001', @PhiPhat = 100000;

SELECT MaDatPhong, TrangThai, Version FROM DATPHONG WHERE MaDatPhong = 'DP001';

SELECT MaPhong, Ngay, MaDatPhong FROM PHONG_NGAY
WHERE MaPhong = 'P101' AND Ngay IN ('2026-10-01', '2026-10-02');

SELECT * FROM DANHSACHCHO WHERE MaKH = 'KH02';
