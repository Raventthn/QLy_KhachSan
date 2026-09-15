-- SESSION A: QUẢN LÝ CHẠY BÁO CÁO CUỐI CA (Batch Process)
-- Mức mặc định của SQL Server là READ COMMITTED (Sẽ sinh ra lỗi Non-repeatable Read)
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN;

PRINT N'Bước 1: Báo cáo đang lấy danh sách để tổng hợp...';
SELECT MaDatPhong, TrangThai FROM DATPHONG WHERE MaDatPhong = 'DP101';

-- Giả lập độ trễ tự nhiên của tiến trình Batch do phải tính toán số liệu nhiều bảng khác
PRINT N'⏳ Hệ thống đang tổng hợp số liệu các chi nhánh (Treo 10 giây)...';
WAITFOR DELAY '00:00:10'; 

PRINT N'Bước 2: Báo cáo đọc lại trạng thái lần cuối để in chốt ca...';
SELECT MaDatPhong, TrangThai FROM DATPHONG WHERE MaDatPhong = 'DP101';

COMMIT TRAN;
PRINT N' Tiến trình Báo cáo hoàn tất!';