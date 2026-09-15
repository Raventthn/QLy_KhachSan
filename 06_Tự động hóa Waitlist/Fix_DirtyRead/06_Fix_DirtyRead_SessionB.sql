SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

PRINT N'Khách B đang xem trạng thái phòng P101...';

SELECT MaPhong, Ngay, MaDatPhong AS Ai_Dang_Dat
FROM PHONG_NGAY
WHERE MaPhong = 'P101' AND Ngay = '2026-10-10';
