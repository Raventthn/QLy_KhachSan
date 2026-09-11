-- HẬU TRƯỜNG: Dọn dẹp và chuẩn bị dữ liệu DP101
-- Gỡ khóa ngoại (nếu có)
UPDATE PHONG_NGAY SET MaDatPhong = NULL WHERE MaDatPhong = 'DP101';
DELETE FROM THANHTOAN WHERE MaDatPhong = 'DP101';
DELETE FROM DATPHONG WHERE MaDatPhong = 'DP101';

-- Tạo đơn DP101 ban đầu
-- TongTien = 500000: giá trị minh họa (case này chỉ demo đọc TrangThai, không phụ thuộc phòng cụ thể)
INSERT INTO DATPHONG (MaDatPhong, MaKH, MaNV, TongTien, TrangThai, Version)
VALUES ('DP101', 'KH01', 'NV01', 500000, N'Đã đặt', 1);

PRINT N'Chuẩn bị xong: Đơn DP101 đang ở trạng thái "Đã đặt"';
