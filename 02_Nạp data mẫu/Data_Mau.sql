-- 1. Thêm Loại phòng
INSERT INTO LOAIPHONG (MaLoai, TenLoai, GiaCoBan) VALUES 
('STD', N'Standard', 500000),
('VIP', N'VIP', 1200000);

-- 2. Thêm Phòng vật lý
INSERT INTO PHONG (MaPhong, MaLoai, SoPhong) VALUES 
('P101', 'STD', '101'),
('P102', 'STD', '102'),
('V201', 'VIP', '201');

-- 3. Thêm Nhân viên
INSERT INTO NHANVIEN (MaNV, HoTen, VaiTro) VALUES 
('NV01', N'Lý Lễ Tân', N'Lễ tân'),
('NV02', N'Trần Quản Lý', N'Quản lý');

-- 4. Thêm Khách hàng
INSERT INTO KHACHHANG (MaKH, HoTen, SDT, Email, CCCD) VALUES 
('KH01', N'Nguyễn Văn An', '0901234567', 'an@email.com', '079123456789'),
('KH02', N'Phạm Thị Bình', '0912345678', 'binh@email.com', '079987654321');


INSERT INTO NHANVIEN (MaNV, HoTen, VaiTro) VALUES ('WEB', N'Hệ thống Website', N'Auto');

-- 5. Khởi tạo lưới Lịch phòng (PHONG_NGAY) cho 3 ngày (Chưa ai đặt -> MaDatPhong = NULL)
INSERT INTO PHONG_NGAY (MaPhong, Ngay, MaDatPhong) VALUES 
('P101', '2026-10-01', NULL), ('P101', '2026-10-02', NULL), ('P101', '2026-10-03', NULL),
('P102', '2026-10-01', NULL), ('P102', '2026-10-02', NULL), ('P102', '2026-10-03', NULL),
('V201', '2026-10-01', NULL), ('V201', '2026-10-02', NULL), ('V201', '2026-10-03', NULL);

-- 6. Tạo 1 Booking giả lập (Khách KH01 đặt phòng P101 trong 2 ngày 1/10 và 2/10)
INSERT INTO DATPHONG (MaDatPhong, MaKH, MaNV, TongTien, NgayTao, TrangThai, Version) VALUES 
('DP001', 'KH01', 'NV01', 1000000, GETDATE(), N'Đã đặt', 1);

-- Cập nhật Lịch phòng để chiếm chỗ cho Booking DP001
UPDATE PHONG_NGAY 
SET MaDatPhong = 'DP001' 
WHERE MaPhong = 'P101' AND Ngay IN ('2026-10-01', '2026-10-02');