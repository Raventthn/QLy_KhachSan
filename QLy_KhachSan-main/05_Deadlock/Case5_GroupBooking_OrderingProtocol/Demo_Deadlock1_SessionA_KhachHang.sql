USE QL_KhachSan;
GO
-- SESSION A — KHÁCH HÀNG đặt online, chọn V102 TRƯỚC, rồi V101 SAU

-- BƯỚC 1: chạy bản LỖI để tạo deadlock (chạy gần như đồng thời với Session B)
--EXEC SP_DatPhong_Loi
--    @MaDatPhong = 'DL1_A',
--    @MaKH = 'KH01',
--    @Ngay = '2026-12-24',
--    @MaPhong1 = 'V102',
--    @MaPhong2 = 'V101';

-- BƯỚC 2: sau khi đã quan sát deadlock (1 trong 2 session bị lỗi 1205),
-- chạy Demo_Deadlock1_HauTruong.sql (Phần 1+2) để reset, rồi chạy lại
-- bằng bản ĐÃ SỬA để chứng minh hết deadlock:
 EXEC SP_DatPhong_Fix
     @MaDatPhong = 'DL1_A', @MaKH = 'KH01', @Ngay = '2026-12-24',
     @MaPhong1 = 'V102', @MaPhong2 = 'V101';
