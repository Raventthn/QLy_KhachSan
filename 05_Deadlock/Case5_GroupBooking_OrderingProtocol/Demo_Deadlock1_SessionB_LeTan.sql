USE QL_KhachSan;
GO
-- SESSION B — LỄ TÂN đặt đoàn tại quầy, chọn V101 TRƯỚC, rồi V102 SAU
-- (ngược thứ tự với Session A -> tạo khóa chéo)

-- BƯỚC 1: chạy bản LỖI, bấm gần như CÙNG LÚC với Session A
--EXEC SP_DatPhong_Loi
--    @MaDatPhong = 'DL1_B',
--    @MaKH = 'KH02',
--    @MaNV = 'NV01',
--    @Ngay = '2026-12-24',
--    @MaPhong1 = 'V101',
--    @MaPhong2 = 'V102';

-- BƯỚC 2: chạy lại bằng bản ĐÃ SỬA sau khi reset (Demo_Deadlock1_HauTruong.sql):
 EXEC SP_DatPhong_Fix
     @MaDatPhong = 'DL1_B', @MaKH = 'KH02', @MaNV = 'NV01', @Ngay = '2026-12-24',
     @MaPhong1 = 'V101', @MaPhong2 = 'V102';
