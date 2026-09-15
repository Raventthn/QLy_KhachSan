USE QL_KhachSan;
GO

-- ================================
/* -- SP_KhoiTao_LuoiNgay
	--Vá lỗ hổng: PHONG_NGAY chỉ có sẵn 3 ngày mẫu ban đầu (02_Nạp data mẫu).
	--Nếu khách đặt 1 ngày chưa được sinh trước trong PHONG_NGAY, UPDATE trong
		sp_Booking_TaoMoi sẽ luôn trả về @@ROWCOUNT = 0 -> hệ thống báo "hết phòng"
		dù phòng thực sự còn trống. SP này đảm bảo mọi phòng đều có đủ lịch cho
		N ngày sắp tới, bằng cách chỉ sinh thêm những dòng (phòng, ngày) còn thiếu.
*/
-- ===============================
CREATE OR ALTER PROC SP_KhoiTao_LuoiNgay
    @SoNgayCanSinh INT = 30 -- đảm bảo có sẵn lịch cho N ngày kể từ hôm nay
AS
BEGIN
    SET NOCOUNT ON;

    IF (@SoNgayCanSinh < 1 OR @SoNgayCanSinh > 366)
    BEGIN
        THROW 51010, N'@SoNgayCanSinh phải trong khoảng 1-366.', 1;
    END

    ;WITH Ngay_CTE AS (
        SELECT CAST(GETDATE() AS DATE) AS Ngay
        UNION ALL
        SELECT DATEADD(DAY, 1, Ngay)
        FROM Ngay_CTE
        WHERE Ngay < DATEADD(DAY, @SoNgayCanSinh - 1, CAST(GETDATE() AS DATE))
    )
    INSERT INTO PHONG_NGAY (MaPhong, Ngay, MaDatPhong)
    SELECT p.MaPhong, n.Ngay, NULL
    FROM PHONG p
    CROSS JOIN Ngay_CTE n
    WHERE NOT EXISTS (
        SELECT 1 FROM PHONG_NGAY pn
        WHERE pn.MaPhong = p.MaPhong AND pn.Ngay = n.Ngay
    )
    OPTION (MAXRECURSION 366);

    PRINT N'Đã đảm bảo lưới PHONG_NGAY đủ cho ' + CAST(@SoNgayCanSinh AS NVARCHAR(10)) + N' ngày tới.';
END
GO

-- Chạy thử ngay sau khi tạo, để chuẩn bị sẵn dữ liệu cho các demo phía sau:
EXEC SP_KhoiTao_LuoiNgay @SoNgayCanSinh = 30;


--Kiêm tra xem đã tạo lịch chưa (chạy sau khi chạy sp KhoiTao_LuoiNgay)

--SELECT * 
--FROM PHONG_NGAY 
--WHERE Ngay >= CAST(GETDATE() AS DATE)
--ORDER BY MaPhong ASC, Ngay ASC;
