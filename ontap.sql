
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

--8thống kê số lượng khách theo từng tỉnh/thành phố (sắp xếp giảm dần) 
		---(count – group by - order by) dựa trên việc bổ sung 3 thực thể: Phường_Xã, Quận_Huyện, Tỉnh_ThànhPhố
SELECT dhd.diaChiGiaoHang , COUNT (k.maKH)as soLuong
FROM dbo.DonDatHang_HoaDon as dhd
JOIN dbo.KhachHang as k ON k.maKH = dhd.maKH
GROUP BY dhd.diaChiGiaoHang 
ORDER BY COUNT(k.maKH) desc
--9thống kê giá trung bình, giá max, giá min nhập hàng cho mỗi sản phẩm 

SELECT s.tenSP,s.maSP,
	AVG(giaNhap) AS TB , MAX(giaNhap) AS CaoNhat , MIN(giaNhap) AS thapNhat
FROM dbo.SanPham AS s
JOIN dbo.ChiTietPhieuNhap AS c ON s.maSP = c.maSP
GROUP BY  s.tenSP,s.maSP

select * from dbo.ChiTietPhieuNhap 
WHERE maSP ='2225014024'

--10hiển thị giá trung bình, giá max, giá min bán ra cho mỗi sản phẩm (lưu ý, mỗi mức giá bán ra của sản phẩm chỉ tính 1 lần)
		---(giá sản phẩm sẽ thay đổi theo thời gian – được lưu lại trong bảng ChiTietDonHang 
		-- lấy mức giá bán ra khác biệt với từ khóa distinct) 

SELECT 
	s.maSP ,s.tenSP,
	MAX(DISTINCT(CTDH.donGia))AS GiaMAX,MIN(DISTINCT(CTDH.donGia))AS GiaMIN,AVG(DISTINCT(CTDH.donGia))AS GiaAVG
FROM dbo.ChiTietDonHang AS	CTDH 
JOIN dbo.SanPham AS s ON CTDH.maSP = s.maSP
GROUP BY s.maSP,s.tenSP
	

--11thống kê số lần khách hàng mua hàng của từng khách hàng (sắp xếp giảm dần)  group by – order by \
-- Cach1: voi join 
SELECT K.maKH, K.tenKH , COUNT(DHD.maHD) SOLANMUA
FROM dbo.DonDatHang_HoaDon AS DHD
JOIN dbo.KhachHang AS K ON DHD.maKH = K.maKH
GROUP BY K.maKH,K.tenKH
ORDER BY COUNT(DHD.maHD)  DESC

-- cach 2: voi where 
SELECT K.tenKH,K.maKH , COUNT(DHD.maHD) SOLANMUA
FROM dbo.DonDatHang_HoaDon AS DHD, KhachHang AS K
WHERE DHD.maKH = K.maKH
GROUP BY K.tenKH,K.maKH 
ORDER BY COUNT(DHD.maHD) DESC

--12hiển thị thông tin chi tiết của các sản phẩm mà có số lần nhập hàng nhiều nhất 
			---(lưu ý trường hợp những sản phẩm cùng giá trị) with ties, hoặc có thể dùng subquery Select top 1 with ties …. 

SELECT s.maSP, s.tenSP , COUNT(C.maPN) SOLANNHAP
FROM dbo.SanPham AS s
JOIN dbo.ChiTietPhieuNhap AS C ON s.maSP = C.maSP
GROUP BY s.maSP, s.tenSP
HAVING COUNT(C.maPN) = (SELECT TOP 1 COUNT(CT.maPN) 
					FROM dbo.ChiTietPhieuNhap AS CT 
					JOIN dbo.SanPham AS sp ON sp.maSP = CT.maSP
					GROUP BY sp.maSP
					ORDER BY COUNT(CT.maPN) DESC)
--13hiển thị thông tin chi tiết của các nhà cung cấp mà có số lần nhập hàng lớn hơn 2 count – group - having 

SELECT n.maNCC , n.tenNCC , Count(p.maPN) 
FROM dbo.NhaCungCap AS n
JOIN dbo.PhieuNhap AS p ON n.maNCC = p.maNCC 
GROUP BY n.maNCC , n.tenNCC
HAVING COUNT(p.maPN) >2;


-------------
/*Câu 1:Hãy viết câu truy vấn hiển thị số lượng còn của sản phẩm,
bổ sung thêm cột có tên "Cảnh báo" để hiển thị: nếu số lượng còn <5 thì hiển thị "Nhập hàng gấp", 
ngược lại hiển thị "Hàng còn đủ dùng"*/
SELECT s.maSP ,s.tenSP,
	CASE
		WHEN s.soLuongHienCon>5 THEN N'Con nhieu' 
		ELSE N'Con it'
	END AS TinhTrang
FROM dbo.SanPham AS s

/*
Câu 2:Hãy viết câu truy vấn để xuất câu thông báo:
"Không đủ số lượng đặt" nếu tồn tại một sản phẩm có số lượng đặt vượt quá số lượng 
còn đối với đơn hàng có mã đơn hàng là 'DH05' (hoặc tùy mã theo dữ liệu bạn đã nhập), 
ngược lại hiển thị câu thông báo "Đặt hàng thành công!"
*/
if exists(SELECT *
	FROM dbo.SanPham AS S 
	JOIN dbo.ChiTietDonHang AS C ON S.maSP = C.maSP
	JOIN dbo.DonDatHang_HoaDon AS DHD ON DHD.maHD = C.maHD 
	WHERE DHD.maHD ='2225001324'AND C.soLuongDat>S.soLuongHienCon)
	print N'Khong du so luong dat'
else 
	print N'Dat hang thanh cong'





	-----	-----	-----	-----	-----	-----	-----	-----
	--1Hãy xuất dạng Text giá tiền của những sản phẩm có giá tiền lớn nhất 
SELECT CONCAT(N'Sản phẩm ',maSP,N' có giá bán là ',FORMAT(donGiaBan,'C', 'vi-VN')) AS GiaTien
FROM dbo.SanPham 
WHERE donGiaBan = (SELECT MAX(donGiaBan) FROM dbo.SanPham) 
	--2 hãy xuất dang text giá bán lớn Nhap của sản phẩm  cho xuât dạng text có tên sản phẩm và mã sản phẩm 
SELECT distinct CONCAT(N'Sản phẩm có mã sản phẩm ',S.maSP, N' có tên sản phẩm là ',S.tenSP , N' có giá bán là: ',FORMAT(giaNhap,'C','vi-VN')) AS GiaNhapMax
FROM dbo.SanPham AS S
JOIN dbo.ChiTietPhieuNhap AS CT ON S.maSP = CT.maSP
WHERE CT.giaNhap = (SELECT MAX(giaNhap) FROM dbo.ChiTietPhieuNhap)


--2Hãy viết đoạn lệnh để tìm giá trị id tiếp theo của bảng sản phẩm, và chèn dữ liệu vào bảng sản phẩm 


CREATE FUNCTION dbo.fn_NextID()
RETURNS CHAR(10) 
AS 
BEGIN 
	DECLARE @IdNext bigint;
	SELECT @IdNext = convert(decimal,max(maSP) )+1 FROM dbo.SanPham
	RETURN @IdNext;
END
INSERT INTO SanPham ( maSP, tenSP, donGiaBan, soLuongHienCon, soLuongCanDuoi)
VALUES (dbo.fn_NextId(), N'Bánh kẹo hải hà', 10000, 50, 10);
select * from dbo.SanPham

-- Nếu maSP có cả chữ thì phải làm như thế nào 
CREATE FUNCTION dbo.fn_NextID()
RETURNS CHAR(10) 
AS 
BEGIN 
    DECLARE @IdNext bigint;
    
    -- Lấy phần số từ chuỗi maSP (giả sử maSP có dạng "ABC123")
    SELECT @IdNext = ISNULL(MAX(CAST(SUBSTRING(maSP, PATINDEX('%[0-9]%', maSP), LEN(maSP)) AS BIGINT)), 0) + 1
    FROM dbo.SanPham;

    -- Nếu không tìm thấy số, sử dụng giá trị mặc định là 1
    IF @IdNext IS NULL
        SET @IdNext = 1;

    RETURN CONVERT(CHAR(10), @IdNext);
END;



--2.1Hãy viết đoạn lệnh để tìm giá trị id tiếp theo của bảng nhan vien, và chèn dữ liệu vào bảng nhanvien

CREATE FUNCTION dbo.fn_IdNextNhanVien ()
RETURNS CHAR(10) 
AS
BEGIN 
	DECLARE @idNext decimal;
	SELECT @idNext = CONVERT(DECIMAL,MAX(maNV))+1 FROM dbo.NhanVien
	RETURN @idNext;
END;
select * from dbo.NhanVien
set dateformat dmy
INSERT INTO dbo.NhanVien
VALUES 
	(dbo.fn_IdNextNhanVien (),N'Nguyễn Văn Linh','0033456089','h23@gmail.com','F','21/12/2001',205000)

	--2.2Hãy viết đoạn lệnh để tìm giá trị id tiếp theo của bảng khach hang, và chèn dữ liệu vào bảng khach hang

CREATE FUNCTION dbo.Fn_IdnextKhachHang()
RETURNS Char(10)
AS
BEGIN 
	DECLARE @idNext decimal;
	SELECT @idNext = CONVERT(DECIMAL,MAX(maKH) ) +1 FROM dbo.KhachHang
	RETURN @idNext;
END;

		-- check 
INSERT INTO dbo.KhachHang
VALUES
	(dbo.Fn_IdnextKhachHang(),N'Nguyễn Văn Linh',N'Hải Châu','0123458789','h4@gmail.com',200000)
----------------------------------- --------------------
--3Hãy viết đoạn lệnh để đếm số lần mua hàng của từng khách hàng,
		--nếu số lần mua lớn hơn hoặc bằng 10 thì ghi ‘Khách hàng thân thiết’, ngược lại ghi ‘Khách hàng tiềm năng’ 
