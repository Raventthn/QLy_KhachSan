-- Bước 1: Dọn dẹp dữ liệu cũ
UPDATE PHONG_NGAY SET MaDatPhong = NULL WHERE MaDatPhong = 'DP002';
DELETE FROM DATPHONG WHERE MaDatPhong = 'DP002';

-- Bước 2: Tạo đơn đặt phòng DP002
-- TongTien = 500000 (P101, loại STD) x 1 đêm -- theo schema mới, cột NOT NULL
INSERT INTO DATPHONG (MaDatPhong, MaKH, TongTien, TrangThai, Version) 
VALUES ('DP002', 'KH01', 500000, N'Đã đặt', 1);

-- Bước 3: BƠM DỮ LIỆU LỊCH PHÒNG (Dùng IF để đảm bảo không bị lỗi trùng lặp)
IF NOT EXISTS (SELECT 1 FROM PHONG_NGAY WHERE MaPhong = 'P101' AND Ngay = '2026-10-10')
    INSERT INTO PHONG_NGAY (MaPhong, Ngay, MaDatPhong) 
    VALUES ('P101', '2026-10-10', 'DP002');
ELSE
    UPDATE PHONG_NGAY 
    SET MaDatPhong = 'DP002' 
    WHERE MaPhong = 'P101' AND Ngay = '2026-10-10';

PRINT N'Đã dọn dẹp và BƠM xong dữ liệu. Phòng P101 hiện đang thuộc về DP002.';
