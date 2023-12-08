
-- TRUY VĂN DỮ LIỆU 


--1Hãy hiển thị thông tin sản phẩm có số lần nhập hàng về nhiều nhất 
SELECT c.maSP, s.tenSP, COUNT(c.maSP)as soLanNHap
FROM dbo.PhieuNhap as p
JOIN dbo.ChiTietPhieuNhap as c ON c.maPN = p.maPN
JOIN dbo.SanPham as s  ON s.maSP = c.maSP
GROUP by c.maSP, s.tenSP
HAVING  COUNT(c.maSP)= (SELECT TOP 1  COUNT(c.maSP)as soLanNHap
		FROM dbo.PhieuNhap as p
		JOIN dbo.ChiTietPhieuNhap as c ON c.maPN = p.maPN
		JOIN dbo.SanPham as s  ON s.maSP = c.maSP
		GROUP by c.maSP)


SELECT c.maSP, COUNT(c.maSP)as soLanNHap
FROM dbo.PhieuNhap as p
JOIN dbo.ChiTietPhieuNhap as c ON c.maPN = p.maPN
JOIN dbo.SanPham as s  ON s.maSP = c.maSP
GROUP by c.maSP
HAVING  COUNT(c.maSP)= (SELECT TOP 1  COUNT(c.maSP)as soLanNHap
		FROM  dbo.ChiTietPhieuNhap as c
		JOIN dbo.SanPham as s  ON s.maSP = c.maSP
		GROUP by c.maSP)


--2thống kê những sản phẩm thuộc top 3 bán chạy nhất  (lưu ý không phải 3 dòng – có thể nhiều dòng miễn là đảm bảo nằm trong top 3) è subquery 
-- bán nhiều nhất 
SELECT s.maSP , s.tenSP, SUM(c.soLuongDat) soLanDat
FROM dbo.SanPham as s
JOIN dbo.ChiTietDonHang c ON s.maSP = c.maSP
GROUP BY s.maSP, s.tenSP
HAVING SUM(c.soLuongDat) IN (SELECT  DISTINCT TOP 3 SUM(ct.soLuongDat)
						FROM dbo.ChiTietDonHang as ct
						GROUP BY maSP
						ORDER BY sum(ct.soLuongDat) DESC)
order by sum(c.soLuongDat) DESC


--3thống kê những sản phẩm chưa bán được cái nào  (not in) s
SELECT s.* 
FROM dbo.SanPham as s 
LEFT JOIN dbo.ChiTietDonHang as c on s.maSP = c.maSP
WHERE maHD IS NULL 

-- cách 2: 
SELECT * FROM dbo.SanPham 
WHERE maSP NOT IN(SELECT maSP 
					FROM dbo.ChiTietDonHang)

-- Câu 4: 4hiển thị những đơn hàng giao thành công và thông tin cụ thể của người giao hàng (position) 
select nv.*
from dbo.DonDatHang_HoaDon as dhd, dbo.NhanVien as nv
WHERE dhd.maNV = nv.maNV and dhd.ngayGiaoHang is NOT NULL
and trangThaiDonHang ='BT'

-- cách 2: 
SELECT nv.* FROM dbo.DonDatHang_HoaDon as dhd
JOIN dbo.NhanVien as nv ON dhd.maNV= nv.maNV
WHERE dhd.ngayGiaoHang IS NOT NULL 
and dhd.trangThaiDonHang ='BT'


--câu 7những tháng có doanh thu trên 2000000 (có tham số là định mức tiền) tháng của năm 
SELECT 
    MONTH(ngayThanhToan) AS Thang,
    YEAR(ngayThanhToan) AS Nam,
    SUM(ctdh.donGia*soLuongDat) AS DoanhThu
FROM dbo.DonDatHang_HoaDon dhhd
JOIN dbo.ChiTietDonHang ctdh ON dhhd.maHD = ctdh.maHD
WHERE dhhd.trangThaiDonHang = 'BT'
and dhhd.ngayThanhToan is not null
GROUP BY MONTH(ngayThanhToan), YEAR(ngayThanhToan)
HAVING SUM(ctdh.donGia*soLuongDat) > 2000000;


SELECT MONTH(dhd.ngayThanhToan) as Thang, YEAR(dhd.ngayThanhToan) as Nam, SUM(c.donGia*c.soLuongDat) AS TongThu
FROM dbo.ChiTietDonHang as c
JOIN dbo.DonDatHang_HoaDon as dhd 
ON dhd.maHD = c.maHD 
WHERE dhd.trangThaiDonHang ='BT'
and dhd.ngayThanhToan IS NOT NULL
GROUP BY MONTH(dhd.ngayThanhToan),YEAR(dhd.ngayThanhToan)
HAVING SUM(c.donGia * c.soLuongDat) >2000000

-- cách 2: 

SELECT MONTH(dhd.ngayThanhToan) , YEAR(dhd.ngayThanhToan) ,  SUM(c.donGia*c.soLuongDat) 
FROM dbo.ChiTietDonHang as c, dbo.DonDatHang_HoaDon as dhd
WHERE c.maHD = dhd.maHD 
and dhd.ngayThanhToan IS NOT NULL
and dhd.trangThaiDonHang = 'BT'
GROUP BY MONTH(dhd.ngayThanhToan) , YEAR(dhd.ngayThanhToan) 
HAVING SUM(c.donGia*c.soLuongDat) >2000000
select * from dbo.DonDatHang_HoaDon

