-- SESSION B: LỄ TÂN THAO TÁC CHECK-IN CÙNG LÚC
PRINT N'Lễ tân thao tác Check-in, đổi trạng thái DP101 thành "Đang ở"...';

-- Thao tác cập nhật nhanh của Lễ tân
UPDATE DATPHONG 
SET TrangThai = N'Đang ở'
WHERE MaDatPhong = 'DP101';

PRINT N' Check-in thành công! Đã chốt (Commit) dữ liệu xuống DB.';