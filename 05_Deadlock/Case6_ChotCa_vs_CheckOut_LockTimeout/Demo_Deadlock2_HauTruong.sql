USE QL_KhachSan;
GO

-- ============ PHẦN 0: KIỂM TRA BẮT BUỘC TRƯỚC KHI DEMO ============
/*-- Nếu kết quả trả về = 1 (đang bật), Deadlock 2 sẽ KHÔNG xảy ra vì reader
	(SP_BaoCao_Loi) sẽ dùng bản snapshot thay vì khóa hàng thật. Nếu đang
	bật, cần tắt để phục vụ demo: ALTER DATABASE QL_KhachSan SET READ_COMMITTED_SNAPSHOT OFF;
*/
SELECT is_read_committed_snapshot_on FROM sys.databases WHERE name = 'QL_KhachSan';

-- ============ PHẦN 1: DỌN DẸP DỮ LIỆU DEMO CŨ ============
DELETE FROM THANHTOAN WHERE MaDatPhong = 'DL2_CK';
DELETE FROM DATPHONG WHERE MaDatPhong = 'DL2_CK';

-- ============ PHẦN 2: CHUẨN BỊ DỮ LIỆU MỒI ============
-- Tạo 1 booking đang "Đang ở" để check-out (dùng lại phòng V101 đã tạo ở Case 5)
-- TongTien = 1200000 (V101, loại VIP) x 1 đêm -- theo schema mới, cột NOT NULL
INSERT INTO DATPHONG (MaDatPhong, MaKH, MaNV, TongTien, TrangThai, Version)
VALUES ('DL2_CK', 'KH01', 'NV01', 1200000, N'Đang ở', 1);

-- ============ PHẦN 3: XEM KẾT QUẢ SAU KHI CHẠY 2 SESSION ============
SELECT * FROM DATPHONG WHERE MaDatPhong = 'DL2_CK';
SELECT * FROM THANHTOAN WHERE MaDatPhong = 'DL2_CK';

-- ============ PHẦN 4: DỌN DẸP SAU DEMO ============
 --DELETE FROM THANHTOAN WHERE MaDatPhong = 'DL2_CK';
 --DELETE FROM DATPHONG WHERE MaDatPhong = 'DL2_CK';
