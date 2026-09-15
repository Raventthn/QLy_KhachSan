-- SESSION B: KHÁCH B CŨNG ĐẶT PHÒNG P102
PRINT N'Khách B cũng bấm đặt phòng P102 cùng lúc...';

EXEC sp_Booking_TaoMoi_BiLoi
    @MaDatPhong = 'DP_KHACH_B', 
    @MaKH = 'KH02', 
    @MaPhong = 'P102', 
    @NgayNhan = '2026-10-05', 
    @NgayTra = '2026-10-06';

PRINT N'Khách B nhận thông báo: ĐẶT PHÒNG THÀNH CÔNG!';