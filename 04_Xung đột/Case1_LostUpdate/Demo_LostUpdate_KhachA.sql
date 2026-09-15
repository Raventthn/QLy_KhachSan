-- SESSION A: KHÁCH A ĐẶT PHÒNG
PRINT N'Khách A đang thao tác đặt phòng P102...';

EXEC sp_Booking_TaoMoi_BiLoi
    @MaDatPhong = 'DP_KHACH_A', 
    @MaKH = 'KH01', 
    @MaPhong = 'P102', 
    @NgayNhan = '2026-10-05', 
    @NgayTra = '2026-10-06';

PRINT N'Khách A nhận thông báo: ĐẶT PHÒNG THÀNH CÔNG!';


