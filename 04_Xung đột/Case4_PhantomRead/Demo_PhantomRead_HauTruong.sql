
-- CHUẨN BỊ 
-- 1. Dọn dẹp  (bao gồm cả các mã nháp từ case trước)
DELETE FROM PHONG_NGAY WHERE MaDatPhong IN ('DP_01', 'DP_02', 'DP_03', 'DP_KHACH_A', 'DP001', 'DP002');
DELETE FROM THANHTOAN WHERE MaDatPhong IN ('DP_01', 'DP_02', 'DP_03', 'DP_KHACH_A', 'DP001', 'DP002');
DELETE FROM DATPHONG WHERE MaDatPhong IN ('DP_01', 'DP_02', 'DP_03', 'DP_KHACH_A', 'DP001', 'DP002');

-- 2. dữ liệu giả lập (2 booking hợp lệ chờ check-in)
-- TongTien = 500000: giá trị minh họa (case này chỉ demo quét theo TrangThai, không phụ thuộc phòng cụ thể)
INSERT INTO DATPHONG (MaDatPhong, MaKH, MaNV, TongTien, TrangThai, Version)
VALUES 
    ('DP_01', 'KH01', 'NV01', 500000, N'Đã đặt', 1),
    ('DP_02', 'KH01','NV01', 500000, N'Đã đặt', 1);

PRINT N'Đã dọn sạch.Hiện chỉ có DP_01 và DP_02 ở trạng thái "Đã đặt".';
