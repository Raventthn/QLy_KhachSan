USE QL_KhachSan;
GO
-- SESSION A — LỄ TÂN thực hiện Check-out & thanh toán trễ cho khách DL2_CK

EXEC SP_ThanhToan
    @MaGD = 'GD_DL2',
    @MaDatPhong = 'DL2_CK',
    @SoTien = 1200000;

/*
-- Sau khi quan sát deadlock, chạy lại Demo_Deadlock2_HauTruong.sql để reset,
	rồi chạy lại (SP_ThanhToan không đổi) cùng lúc với bản SP_BaoCao đã sửa
	ở Session B để kiểm chứng hết deadlock (chỉ còn lỗi timeout 1222 ở Session B).
*/