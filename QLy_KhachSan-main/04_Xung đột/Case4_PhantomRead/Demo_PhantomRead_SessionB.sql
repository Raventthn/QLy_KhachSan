PRINT N'Lễ tân chốt đơn đặt phòng mới cho khách...';

-- Dùng KH01 để tránh lỗi khóa ngoại
-- TongTien = 500000: giá trị minh họa, giữ nhất quán với 2 booking mồi ở HauTruong
INSERT INTO DATPHONG (MaDatPhong, MaKH, MaNV, TongTien, TrangThai, Version)
VALUES ('DP_03', 'KH01', 'NV01', 500000, N'Đã đặt', 1);

PRINT N' Tạo booking DP_03 thành công!';
