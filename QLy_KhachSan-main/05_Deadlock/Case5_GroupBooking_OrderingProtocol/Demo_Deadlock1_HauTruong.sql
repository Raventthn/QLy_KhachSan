USE QL_KhachSan;
GO

-- ============ PHẦN 1: DỌN DẸP DỮ LIỆU DEMO CŨ (chạy trước mỗi lần demo) ============
UPDATE PHONG_NGAY SET MaDatPhong = NULL WHERE MaDatPhong IN ('DL1_A', 'DL1_B');
DELETE FROM DATPHONG WHERE MaDatPhong IN ('DL1_A', 'DL1_B');

-- ============ PHẦN 2: CHUẨN BỊ DỮ LIỆU MỒI ============
-- Tạo 2 phòng VIP dùng riêng cho demo (nếu chưa có)
IF NOT EXISTS (SELECT 1 FROM PHONG WHERE MaPhong = 'V101')
    INSERT INTO PHONG (MaPhong, MaLoai, SoPhong) VALUES ('V101', 'VIP', '101');
IF NOT EXISTS (SELECT 1 FROM PHONG WHERE MaPhong = 'V102')
    INSERT INTO PHONG (MaPhong, MaLoai, SoPhong) VALUES ('V102', 'VIP', '102');

-- Đảm bảo có dòng lịch cho ngày demo, đang ở trạng thái TRỐNG
IF NOT EXISTS (SELECT 1 FROM PHONG_NGAY WHERE MaPhong = 'V101' AND Ngay = '2026-12-24')
    INSERT INTO PHONG_NGAY (MaPhong, Ngay, MaDatPhong) VALUES ('V101', '2026-12-24', NULL);
ELSE
    UPDATE PHONG_NGAY SET MaDatPhong = NULL WHERE MaPhong = 'V101' AND Ngay = '2026-12-24';

IF NOT EXISTS (SELECT 1 FROM PHONG_NGAY WHERE MaPhong = 'V102' AND Ngay = '2026-12-24')
    INSERT INTO PHONG_NGAY (MaPhong, Ngay, MaDatPhong) VALUES ('V102', '2026-12-24', NULL);
ELSE
    UPDATE PHONG_NGAY SET MaDatPhong = NULL WHERE MaPhong = 'V102' AND Ngay = '2026-12-24';

-- ============ PHẦN 3: XEM KẾT QUẢ SAU KHI CHẠY 2 SESSION ============
-- (Chạy phần này SAU khi Session A và B đã hoàn tất/bị hủy)
SELECT * FROM PHONG_NGAY WHERE MaPhong IN ('V101', 'V102') AND Ngay = '2026-12-24';
SELECT * FROM DATPHONG WHERE MaDatPhong IN ('DL1_A', 'DL1_B');

-- ============ PHẦN 4: DỌN DẸP SAU DEMO ============
 --UPDATE PHONG_NGAY SET MaDatPhong = NULL WHERE MaDatPhong IN ('DL1_A', 'DL1_B');
 --DELETE FROM DATPHONG WHERE MaDatPhong IN ('DL1_A', 'DL1_B');
