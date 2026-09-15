
-- PHẦN 1: TẠO STORED PROCEDURE CỐ TÌNH BỊ LỖI

CREATE OR ALTER PROC sp_Booking_TaoMoi_BiLoi
    @MaDatPhong VARCHAR(10), 
    @MaKH VARCHAR(10), 
    @MaPhong VARCHAR(10), 
    @NgayNhan DATE, 
    @NgayTra DATE
AS
BEGIN
    -- THÊM MỚI (theo schema mới): tính TongTien = GiaCoBan x số đêm để insert vào DATPHONG
    -- (không đụng vào lỗi Lost Update cố ý bên dưới, chỉ để INSERT không bị lỗi NOT NULL)
    DECLARE @TongTien DECIMAL(18,2);
    SELECT @TongTien = lp.GiaCoBan * DATEDIFF(DAY, @NgayNhan, @NgayTra)
    FROM PHONG p JOIN LOAIPHONG lp ON lp.MaLoai = p.MaLoai
    WHERE p.MaPhong = @MaPhong;

    BEGIN TRAN 

    INSERT INTO DATPHONG (MaDatPhong, MaKH, MaNV, TongTien, TrangThai, Version) 
    VALUES (@MaDatPhong, @MaKH, 'WEB', @TongTien, N'Đã đặt', 1);
    
    WAITFOR DELAY '00:00:10';

    UPDATE PHONG_NGAY
    SET MaDatPhong = @MaDatPhong
    WHERE MaPhong = @MaPhong 
      AND Ngay >= @NgayNhan AND Ngay < @NgayTra;

    COMMIT TRAN 
    PRINT N'ĐẶT PHÒNG THÀNH CÔNG!';
END
GO


-- PHẦN 2: CHUẨN BỊ HIỆN TRƯỜNG (CHẠY TRƯỚC KHI ÉP LỖI)

UPDATE PHONG_NGAY SET MaDatPhong = NULL WHERE MaDatPhong IN ('DP_KHACH_A', 'DP_KHACH_B');
DELETE FROM DATPHONG WHERE MaDatPhong IN ('DP_KHACH_A', 'DP_KHACH_B');

IF NOT EXISTS (SELECT 1 FROM PHONG_NGAY WHERE MaPhong = 'P102' AND Ngay = '2026-10-05')
    INSERT INTO PHONG_NGAY (MaPhong, Ngay, MaDatPhong) 
    VALUES ('P102', '2026-10-05', NULL);
ELSE
    UPDATE PHONG_NGAY SET MaDatPhong = NULL WHERE MaPhong = 'P102' AND Ngay = '2026-10-05';

PRINT N'Phòng P102 ngày 5/10/2026 đang trống.';
SELECT MaPhong, Ngay, MaDatPhong AS 'Ai_Dang_Dat' 
FROM PHONG_NGAY 
WHERE MaPhong = 'P102' AND Ngay = '2026-10-05';


-- PHẦN 3: KIỂM TRA LỖI LOST UPDATE (CHẠY SAU KHI TEST XONG)

SELECT MaPhong, Ngay, MaDatPhong AS 'Ai_Dang_Dat'
FROM PHONG_NGAY 
WHERE MaPhong = 'P102' AND Ngay = '2026-10-05';

SELECT MaDatPhong, MaKH, TrangThai FROM DATPHONG WHERE MaDatPhong IN ('DP_KHACH_A','DP_KHACH_B');


-- PHẦN 4: DỌN DẸP SẠCH SẼ (CHẠY KHI KẾT THÚC BÁO CÁO)

UPDATE PHONG_NGAY 
SET MaDatPhong = NULL 
WHERE MaDatPhong IN ('DP_KHACH_A', 'DP_KHACH_B') 
   OR (MaPhong = 'P102' AND Ngay = '2026-10-05');

DELETE FROM DATPHONG 
WHERE MaDatPhong IN ('DP_KHACH_A', 'DP_KHACH_B');

PRINT N'DB trở lại bình thường!';
