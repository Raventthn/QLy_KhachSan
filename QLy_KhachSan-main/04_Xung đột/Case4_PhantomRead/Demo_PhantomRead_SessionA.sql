-- SESSION A: JOB TỰ ĐỘNG QUÉT DANH SÁCH NO-SHOW (Sau 18:00)
-- Dùng REPEATABLE READ để chứng minh nó KHÔNG chặn được bóng ma (Phantom Read)
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRAN;

PRINT N'Lần 1: Job quét danh sách khách "Đã đặt" để chuẩn bị phạt No-show...';
-- (Giả lập điều kiện WHERE lấy trạng thái Đã đặt)
SELECT MaDatPhong, MaKH, TrangThai 
FROM DATPHONG 
WHERE TrangThai = N'Đã đặt';

-- Giả lập hệ thống mất thời gian phân tích, gửi email cảnh báo...
PRINT N'⏳ Hệ thống đang đối chiếu dữ liệu (Treo 10 giây)...';
WAITFOR DELAY '00:00:10'; 

PRINT N'Lần 2: Job quét lại lần cuối trước khi COMMIT phạt hàng loạt...';
SELECT MaDatPhong, MaKH, TrangThai 
FROM DATPHONG 
WHERE TrangThai = N'Đã đặt';

COMMIT TRAN;
PRINT N' Job quét No-show đã chạy xong!';