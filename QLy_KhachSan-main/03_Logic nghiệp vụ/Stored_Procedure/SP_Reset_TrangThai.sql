USE QL_KhachSan;
GO

-- ===================================
-- SP_Reset_TrangThai
-- Dọn sạch dữ liệu do các buổi DEMO (Case 1 -> Deadlock 1, 2) sinh ra,
-- để có thể chạy lại demo nhiều lần khi tập dượt mà không phải tạo lại
-- database từ đầu. Gọi SP này TRƯỚC mỗi lần chạy demo.
--
-- Nếu về sau thêm case demo mới, chỉ cần bổ sung mã đặt phòng demo mới
-- vào bảng biến @MaDemo bên dưới.
-- ===================================
CREATE OR ALTER PROC SP_Reset_TrangThai
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaDemo TABLE (MaDatPhong VARCHAR(10));
    INSERT INTO @MaDemo (MaDatPhong) VALUES
        ('DP_KHACH_A'), ('DP_KHACH_B'),  -- Case 1: Lost Update
        ('DL1_A'), ('DL1_B'),            -- Deadlock 1: Group Booking (V101/V102)
        ('DL2_CK');                      -- Deadlock 2: Check-out vs Chốt ca

    -- Bước 1: gỡ tham chiếu trong PHONG_NGAY trước (tránh vướng FK khi xóa DATPHONG)
    UPDATE PHONG_NGAY
    SET MaDatPhong = NULL
    WHERE MaDatPhong IN (SELECT MaDatPhong FROM @MaDemo);

    -- Bước 2: xóa giao dịch thanh toán phát sinh từ demo
    DELETE FROM THANHTOAN
    WHERE MaDatPhong IN (SELECT MaDatPhong FROM @MaDemo);

    -- Bước 3: xóa các đơn đặt phòng demo
    DELETE FROM DATPHONG
    WHERE MaDatPhong IN (SELECT MaDatPhong FROM @MaDemo);

    -- Bước 4: đảm bảo các phòng/ngày dùng để test luôn ở trạng thái TRỐNG
    UPDATE PHONG_NGAY
    SET MaDatPhong = NULL
    WHERE MaPhong IN ('P101', 'P102', 'V101', 'V102')
      AND Ngay IN ('2026-10-01', '2026-10-02', '2026-10-03', '2026-12-24');

    -- Bước 5: đưa các booking dùng để demo No-show/Check-in về lại "Đã đặt"
    -- (bỏ comment dòng dưới nếu cần reset cả DP001 sau khi demo No-show)
    -- UPDATE DATPHONG SET TrangThai = N'Đã đặt', Version = 1 WHERE MaDatPhong = 'DP001';

    PRINT N'Đã reset xong dữ liệu demo. Sẵn sàng chạy lại từ đầu.';
END
GO
