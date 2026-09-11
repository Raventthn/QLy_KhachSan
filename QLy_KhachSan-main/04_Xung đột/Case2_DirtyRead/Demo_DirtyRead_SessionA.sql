-- SESSION A: LỄ TÂN HỦY NHẦM VÀ ĐANG SUY NGHĨ...
BEGIN TRAN;

-- Thao tác 1: Nhả phòng P101 (Nhưng chưa chốt COMMIT)
UPDATE PHONG_NGAY 
SET MaDatPhong = NULL 
WHERE MaPhong = 'P101' AND Ngay = '2026-10-10';

PRINT N'⏳ Lễ tân đã nhả phòng nhưng CHƯA COMMIT. Đang khựng lại 10 giây...';
WAITFOR DELAY '00:00:10';

-- Thao tác 2: Phát hiện sai, Hủy bỏ toàn bộ (Rollback)
ROLLBACK TRAN;
PRINT N'Lễ tân phát hiện nhầm, đã ROLLBACK. Phòng P101 quay lại cho DP002!';