USE QL_KhachSan;
GO
-- SESSION B — QUẢN LÝ chạy báo cáo chốt ca, gần như CÙNG LÚC với Session A

-- BƯỚC 1: chạy bản LỖI để tạo deadlock thật (SQL Server tự kill 1 bên, lỗi 1205)
--EXEC SP_BaoCao_Loi;
/*
-- BƯỚC 2: sau khi reset (Demo_Deadlock2_HauTruong.sql), chạy lại bằng bản
	ĐÃ SỬA để chứng minh không còn "treo" vô thời hạn nữa (Session B sẽ tự
	văng lỗi 1222 sau 3 giây thay vì chờ SQL Server phát hiện deadlock)
*/
 EXEC SP_BaoCao;
