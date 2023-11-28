CREATE DATABASE NguyenVanLinh2225
go
use NguyenVanLinh2225;
CREATE TABLE KhachHang(
	maKH char(10) PRIMARY KEY,
	tenKH nvarchar(50) NOT NULL,
	diaChiKH nvarchar(255) NOT NULL,
	SDT char(10) UNIQUE,
	Email varchar(255) UNIQUE,
	SoDuTaiKhoan money ,
);

ALTER TABLE KhachHang
ADD CONSTRAINT CheckSDTFormat_KhachHang
		CHECK (SDT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CONSTRAINT CheckEmailFormat_KhachHang
		CHECK (
			Email LIKE '[a-z]%@gmail.com' OR
			Email LIKE '[a-z]%@yahoo.com' OR
			Email LIKE '[a-z]%ute.udn.vn'		
	);

CREATE TABLE NhanVien(
	maNV char(10) PRIMARY KEY,
	tenNV nvarchar(50) NOT NULL,
	SDT char(10) UNIQUE,
	Email varchar(255) UNIQUE,
	gioiTinh Char(1) ,
	Dob Date,
	Salary money,
);
ALTER TABLE NhanVien
ADD CONSTRAINT CheckEmailFormat_NhanVien
		CHECK (
        Email LIKE '[a-z]%@gmail.com' OR
        Email LIKE '[a-z]%@yahoo.com' OR
        Email LIKE '[a-z]%@ute.udn.vn'
		),
	CONSTRAINT CheckSDTFormat_NhanVien
		CHECK (SDT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
	CONSTRAINT CheckGioiTinhFormat
		CHECK (gioiTinh IN ('F','M')),
	CONSTRAINT DefaultGioiTinh
		DEFAULT 'F' FOR gioiTinh,
	CONSTRAINT CheckDobFormat
		CHECK(DATEDIFF(YEAR,Dob,GETDATE())>=18);
CREATE TABLE DonDatHang_HoaDon(
	maHD char(10) PRIMARY KEY ,
	maKH char(10) NULL,
	maNV char(10) NULL,
	ngayTaoDH Date NOT NULL,
	diaChiGiaoHang nvarchar(255) NOT NULL,
	SDTGiaoHang char(10) NOT NULL,
	maHoaDonDienTu varchar(10),
	ngayThanhToan Date NULL,
	ngayGiaoHang Date NULL ,
	trangThaiDonHang  char(2) NOT NULL,
	FOREIGN KEY (maKH) REFERENCES KhachHang(maKH) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (maNV) REFERENCES NhanVien(maNV) ON DELETE CASCADE ON UPDATE CASCADE,
);
ALTER TABLE DonDatHang_HoaDon
ADD CONSTRAINT CheckNgayTaoDHFormat
		CHECK (ngayTaoDH<=GETDATE()),
	CONSTRAINT CheckTrangThaiDonHang
		CHECK (trangThaiDonHang IN('BT','ER','LL')),
	CONSTRAINT DefaulTrangThaiDonHang
		DEFAULT 'BT'FOR trangThaiDonHang;

CREATE TABLE NhaCungCap(
	maNCC char(50) PRIMARY KEY,
	tenNCC nvarchar(255)  NOT NULL,
	diaChiNCC nvarchar(255)  NOT NULL,
	SDT char(10) UNIQUE NOT NULL,
	nhanVienLienHe nvarchar(50) NULL,
);
ALTER TABLE NhaCungCap
ADD CONSTRAINT CheckSDTFormat_NhaCungCap
		CHECK (SDT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]');

CREATE TABLE PhieuNhap(
	maPN char(10) PRIMARY KEY,
	maNCC char(50) NOT NULL,
	ngayNhapHang Date  NOT NULL,
	FOREIGN KEY (maNCC) REFERENCES NhaCungCap(maNCC) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE SanPham(
	maSP Char(10) PRIMARY KEY,
	tenSP nvarchar(50) NOT NULL,
	donGiaBan money NOT NULL,
	soLuongHienCon bigint NOT NULL,
	soLuongCanDuoi smallint NOT NULL
);

ALTER TABLE SanPham
ADD CONSTRAINT CheckDonGiaBanFormat 
		CHECK (donGiaBan >= 0),
    CONSTRAINT CheckSoLuongHienConFormat 
		CHECK (soLuongHienCon >= 0),
	CONSTRAINT CheckSoLuongCanDuoi 
		CHECK(soLuongCanDuoi>=0);

CREATE TABLE ChiTietPhieuNhap(
	maPN Char(10) NOT NULL,
	maSP Char(10) NOT NULL,
	soLuongNhap int  NOT NULL ,
	giaNhap money NOT NULL ,
	FOREIGN KEY (maPN) REFERENCES PhieuNhap(maPN) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (maSP) REFERENCES SanPham(maSP) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (maPN, maSP)
);
ALTER TABLE ChiTietPhieuNhap
ADD CONSTRAINT CheckSoluongNhapFormat
		CHECK(soLuongNhap>=0),
	CONSTRAINT CheckGiaNhapFormat
		CHECK(giaNhap>=0);

CREATE TABLE ChiTietDonHang(
	maHD char(10) NOT NULL,
	maSP Char(10)NOT NULL,
	soLuongDat int NOT NULL,
	donGia money NOT NULL,
	PRIMARY KEY(maHD, maSP),
	FOREIGN KEY (maHD) REFERENCES DonDatHang_HoaDon(maHD) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (maSP) REFERENCES SanPham(maSP) ON DELETE CASCADE ON UPDATE CASCADE,
);
ALTER TABLE ChiTietDonHang
ADD CONSTRAINT CheckSoLuongDat_ChiTietDonHang
		CHECK (soLuongDat >= 0),
	CONSTRAINT CheckdonGia_ChiTietDonHang
		CHECK (donGia >= 0);
/*INSERT vào TABLE KhachHang
=>với các trường hợp có thể có(bảng này với các ràng buộc là unique và not null,
thì chỉ có luong la có thể là NULL hoặc bằng 0). Trong trường hợp lỗi hoặc thông tin không đầy đủ,
khi không thể xác định số dư tài khoản của khách hàng.*/
INSERT INTO dbo.KhachHang
VALUES
	('2225000024',N'Nguyễn Văn Linh',N'Hải Châu','0123456789','h@gmail.com',200000),
	('2225000124',N'Nguyễn Văn Linh',N'Hải Châu','0233456789','k@gmail.com',1000000),
	('2225000224',N'Nguyễn Văn Linh',N'Hải Châu','0243456789','l@gmail.com',2560000),
	('2225000324',N'Nguyễn Văn Linh',N'Hải Châu','0253456789','a@gmail.com',NULL),
	('2225000424',N'Nguyễn Văn Linh',N'Hải Châu','0263456789','s@gmail.com',2750000),
	('2225000524',N'Nguyễn Văn Linh',N'Hải Châu','0273456789','d@gmail.com',16525000),
	('2225000624',N'Nguyễn Văn Linh',N'Hải Châu','0283456789','f@gmail.com',0),
	('2225000724',N'Nguyễn Văn Linh',N'Hải Châu','0293456789','g@gmail.com',1800000),
	('2225000824',N'Nguyễn Văn Linh',N'Hải Châu','0313456789','t@gmail.com',2500000),
	('2225000924',N'Nguyễn Văn Linh',N'Hải Châu','0323456789','y@gmail.com',NULL);
--SELECT * FROM dbo.KhachHang;

/*INSERT TABLE NhanVien thêm Nhan Vien ở những trường hợp có đủ hết tất cả các cột*/
set dateformat dmy;
INSERT INTO dbo.NhanVien
VALUES 
	('2225001024',N'Nguyễn Văn Linh','0033456789','h1@gmail.com','F','21/12/2002',20000),
	('2225001124',N'Nguyễn Văn Linh','0333456789','k2@gmail.com','M','02/11/2002',0),
	('2225002224',N'Nguyễn Văn Linh','0343456789','l3@gmail.com',default,'11/02/2002',NULL),
	('2225003324',N'Nguyễn Văn Linh','0353456789','a4@gmail.com','M','21/07/2002',45000),
	('2225004424',N'Nguyễn Văn Linh','0363456789','s5@gmail.com',default,'22/06/2002',0),
	('2225005524',N'Nguyễn Văn Linh','0373456789','d6@gmail.com','M','24/9/2002',NULL),
	('2225006624',N'Nguyễn Văn Linh','0383456789','f7@gmail.com','F',NULL,345000); 
INSERT INTO dbo.NhanVien(maNV,tenNV,SDT,Email,gioiTinh,Dob)
VALUES 
	('2225007724',N'Nguyễn Văn Linh','0393456789','g8@gmail.com',default,'19/7/2002'),
	('2225008824',N'Nguyễn Văn Linh','0403456789','t9@gmail.com','F','1/8/2002');
INSERT INTO dbo.NhanVien(maNV,tenNV,SDT,Email,gioiTinh)
VALUES 
	('2225009924',N'Nguyễn Văn Linh','0413456789','y0@gmail.com',default);
--SELECT * FROM dbo.NhanVien;

-- INSERT TABLE DonDatHang_HoaDon
set dateformat dmy
INSERT INTO dbo.DonDatHang_HoaDon
VALUES
	('2225001328','2225000024','2225001024','23/1/2023',N'Vinh-Nghệ An','0123451234','12345','12/11/2023','14/11/2023','BT'),
	('2225001424','2225000124','2225001124','13/2/2023',N'Nam Đàn-Nghệ An','0123456755','12346','12/11/2023','14/11/2023',default),
	('2225001524','2225000224','2225002224','3/3/2023',N'Tương Dương-Nghệ An','0123456756','12347','12/11/2023','14/11/2023','ER'),
	('2225001624','2225000324','2225003324','25/4/2023',N'Cửa Lò-Nghệ An','0123456757','12348','12/11/2023','14/11/2023','BT'),
	('2225001724','2225000424','2225004424','3/6/2023',N'Gio Linh-Quảng Trị','0123456758','12349','12/11/2023','14/11/2023',default),
	('2225001824','2225000524','2225005524','17/1/2023',N'Hướng Hóa-Quảng Trị','0123456759','12350','12/11/2023','14/11/2023','BT'),
	('2225001924','2225000624','2225006624','05/04/2023',N'Hải Lăng-Quảng Trị','0123456760','12351','12/11/2023','14/11/2023','BT');

INSERT INTO dbo.DonDatHang_HoaDon
VALUES
	('2225002124',NULL,'2225007724','21/07/2023',N'Triệu Phong-Quảng Trị','0123456761','12352',NULL,NULL,default),
	('2225002224','2225000824',NULL,'27/02/2023',N'TX Quảng Trị-Quảng Trị','0123456762',NULL,'12/11/2023','14/11/2023','ER');
INSERT INTO dbo.DonDatHang_HoaDon(maHD,maNV,ngayTaoDH,diaChiGiaoHang,SDTGiaoHang,ngayThanhToan,ngayGiaoHang)
VALUES
	('2225002324','2225009924','02/08/2023',N'Phú Bài-Huế','0123451234','12/11/2023','14/11/2023');
--SELECT * FROM dbo.DonDatHang_HoaDon;

--INSERT TABLE NhaCungCap
INSERT INTO dbo.NhaCungCap
VALUES 
	('2225012024',N'Nguyễn Văn Linh',N'Hải Châu-Đà Nẵng','0123456120',N'Nguyễn Văn Linh'),
	('2225012124',N'Nguyễn Văn Linh',N'Hải Châu-Đà Nẵng','0123456121',N'Nguyễn Văn Linh'),
	('2225012224',N'Nguyễn Văn Linh',N'Gio Linh-Quảng Trị','0123456122',N'Nguyễn Văn Linh'),
	('2225012324',N'Nguyễn Văn Linh',N'Gio Việt-Quảng Trị','0123456123',N'Nguyễn Văn Linh'),
	('2225012424',N'Nguyễn Văn Linh',N'Nha Trang-Khánh Hòa','0123456124',N'Nguyễn Văn Linh'),
	('2225012524',N'Nguyễn Văn Linh',N'Phong Bình-Quảng Bình','0123456125',N'Nguyễn Văn Linh'),
	('2225012624',N'Nguyễn Văn Linh',N'Phong Điền-Thừa Thiên Huế','0123456126',N'Nguyễn Văn Linh'),
	('2225012724',N'Nguyễn Văn Linh',N'Đồng Hới-Quảng Bình','0123456127',N'Nguyễn Văn Linh'),
	('2225012824',N'Nguyễn Văn Linh',N'Phong Nha-Quảng Bình','0123456128',N'Nguyễn Văn Linh');

INSERT INTO dbo.NhaCungCap(maNCC,tenNCC,diaChiNCC,SDT)
VALUES
	('2225012924',N'Nguyễn Văn Linh',N'Thanh Khê-Đà Nẵng','0123456129');
--SELECT * FROM dbo.NhaCungCap;

--INSERT TABLE PhieuNhap
INSERT INTO PhieuNhap
VALUES
	('2225013024','2225012024','13/12/2023'),
	('2225013124','2225012124','10/11/2023'),
	('2225013224','2225012224','25/6/2023'),
	('2225013324','2225012324','21/1/2023'),
	('2225013424','2225012424','9/4/2023'),
	('2225013524','2225012524','16/3/2023'),
	('2225013624','2225012624','27/9/2023');
INSERT INTO PhieuNhap
VALUES
	('2225113024','2225014024','24/02/2023'),
	('2225113124','2225014124','3/2/2023'),
	('2225113224','2225014224','24/5/2023'),
	('2225113324','2225014324','5/11/2023');
INSERT INTO dbo.NhaCungCap
VALUES 
	('2245014024',N'Nguyễn Văn Linh',N'Hải Châu-Đà Nẵng','0123496420',N'Nguyễn Văn Linh'),
	('2245014124',N'Nguyễn Văn Linh',N'Hải Châu-Đà Nẵng','0123496321',N'Nguyễn Văn Linh'),
	('2245014224',N'Nguyễn Văn Linh',N'Gio Linh-Quảng Trị','0129426122',N'Nguyễn Văn Linh'),
	('2245014324',N'Nguyễn Văn Linh',N'Gio Việt-Quảng Trị','0126406123',N'Nguyễn Văn Linh');
INSERT INTO PhieuNhap
VALUES 
	('2220137724','2245014024','11/05/2023'),
	('2225017824','2245014024','07/06/2023'),
	('2225019924','2245014024','12/8/2023');
--SELECT * FROM dbo.PhieuNhap;

--INSERT TABLE SanPham
INSERT INTO SanPham
VALUES
	('2225014024',N'Sản phẩm làm đẹp',20000,200,0),
	('2225014124',N'Sản phẩm làm đẹp',150000,35,55),
	('2225014224',N'Sản phẩm làm đẹp',250000,24,10),
	('2225014324',N'Sản phẩm làm đẹp',40000,20,60),
	('2225014424',N'Sản phẩm làm đẹp',35000,0,100),
	('2225014524',N'Sản phẩm làm đẹp',60000,45,0),
	('2225014624',N'Sản phẩm làm đẹp',1800000,15,50),
	('2225014724',N'Sản phẩm làm đẹp',2000000,0,40),
	('2225014824',N'Sản phẩm làm đẹp',500000,34,20),
	('2225014924',N'Sản phẩm làm đẹp',3500000,100,0);
--SELECT * FROM dbo.SanPham;

--INSERT TABLE ChiTietPHieuNhap
INSERT INTO ChiTietPhieuNhap
VALUES 
	('2225001327','2225014024',0,15000),
	('2225013124','2225014124',55,100000),
	('2225013224','2225014224',10,200000),
	('2225013324','2225014324',60,350000),
	('2225013424','2225014424',100,20000),
	('2225013524','2225014524',0,55000),
	('2225013624','2225014624',50,1650000),
	('2225013724','2225014724',40,1950000),
	('2225013824','2225014824',20,480000),
	('2225013924','2225014924',0,3200000);
SELECT d.maHD FROM dbo.DonDatHang_HoaDon d 
except
SELECT c.maHD FROM dbo.ChiTietDonHang c

--INSERT TABLE ChiTietDonHang
INSERT INTO ChiTietDonHang
VALUES
	('2225001328','2225014024',0,15000),
	('2225033524','2225014024',55,100000),
	('2225001524','2225014224',10,200000),
	('2225001624','2225014324',60,350000),
	('2225001724','2225014424',100,20000),
	('2225001824','2225014524',0,55000),
	('2225001924','2225014624',50,1650000),
	('2225002124','2225014724',40,1950000),
	('2225002224','2225014824',20,480000),
	('2225002324','2225014924',0,3200000);
--SELECT * FROM dbo.ChiTietDonHang;
--1Hãy hiển thị thông tin sản phẩm có số lần nhập hàng về nhiều nhất 
	SELECT TOP 1 c.*
	FROM dbo.ChiTietPhieuNhap  as c 
	ORDER BY soLuongNhap DESC
--2thống kê những sản phẩm thuộc top 3 bán chạy nhất  (lưu ý không phải 3 dòng – có thể nhiều dòng miễn là đảm bảo nằm trong top 3) è subquery 
-- Top 3 sản phẩm bán chạy nhất
-- cách 1:  hoạt động đúng khi chỉ một dơn bán 1 lần kể từ lần thứ 2 trở đi là sẽ hoạt sai.
select * 
from dbo.SanPham 
where maSP in(select maSP
			from dbo.ChiTietDonHang ct
			where soLuongDat
			in(select distinct top (3)
					sum(soluongDat) as total
					from dbo.ChiTietDonHang c 
					group by maHD, maSP
					Order by sum(soLuongDat) DESC)
)

-- cách 2: đúng với mọi trường hợp
select s.maSP, s.tenSP
from dbo.SanPham s, dbo.ChiTietDonHang ct
where s.maSP = ct.maSP
group by s.maSP, s.tenSP
having sum(ct.soLuongDat) in(
	select distinct top 3 sum(c.soLuongDat)
	from dbo.ChiTietDonHang as c
	group by maHD 
	order by  sum(c.soLuongDat) DESC
)
order by sum(ct.soLuongDat);

--3thống kê những sản phẩm chưa bán được cái nào  (not in) 
	select *from dbo.SanPham
	where maSP not in (select maSP from dbo.ChiTietDonHang)


--4hiển thị những đơn hàng giao thành công và thông tin cụ thể của người giao hàng (position) 
	select * from dbo.DonDatHang_HoaDon
	where ngayGiaoHang is not null 
	and maNV is not null
	and maKH is not null
	and trangThaiDonHang is not null;
--5hiển thị những đơn hàng của khách hàng ở Đà Nẵng hoặc Quảng Nam (nên có điều kiện DN và QN, mặc định là DN hoặc QN) 
select  dh.*, k.diaChiKH
from dbo.ChiTietDonHang as ct
	JOIN dbo.DonDatHang_HoaDon dh on ct.maHD = dh.maHD
	JOIN dbo.KhachHang as k on k.maKH = dh.maKH
where k.diaChiKH in ('QN','DN')


--6hiển thị những sản phẩm có giá từ 500k – 2.000k 
SELECT s.*
FROM dbo.SanPham as s
WHERE s.donGiaBan between 500000 and 2000000

--7những tháng có doanh thu trên 2000000 (có tham số là định mức tiền) tháng của năm 

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

--8thống kê số lượng khách theo từng tỉnh/thành phố (sắp xếp giảm dần) 
					---(count – group by - order by) dựa trên việc bổ sung 3 thực thể: Phường_Xã, Quận_Huyện, Tỉnh_ThànhPhố 
	SELECT k.diaChiKH, Count(k.maKH) as soLuong
	FROM dbo.KhachHang k
		JOIN dbo.DonDatHang_HoaDon ddh ON k.maKH= ddh.maKH
	GROUP BY k.diaChiKH
	ORDER BY k.diaChiKH DESC

--9thống kê giá trung bình, giá max, giá min nhập hàng cho mỗi sản phẩm 4
-- Insert thêm dữ liệu 
INSERT INTO ChiTietPhieuNhap
VALUES 
	('2220137724','2225014024',0,10000),
	('2225017824','2225014124',55,1000000),
	('2225019924','2225014224',10,9000000);
INSERT INTO PhieuNhap
VALUES 
	('2220137724','2245014024','11/05/2023'),
	('2225017824','2245014024','07/06/2023'),
	('2225019924','2245014024','12/8/2023');
SELECT
    sp.maSP,sp.tenSP,
    AVG(ctpn.giaNhap) AS GiaTrungBinh,
    MAX(ctpn.giaNhap) AS GiaMax,
    MIN(ctpn.giaNhap) AS GiaMin
FROM dbo.SanPham sp
JOIN dbo.ChiTietPhieuNhap ctpn ON sp.maSP = ctpn.maSP
GROUP BY sp.maSP, sp.tenSP;

--10hiển thị giá trung bình, giá max, giá min bán ra cho mỗi sản phẩm (lưu ý, mỗi mức giá bán ra của sản phẩm chỉ tính 1 lần)
		---(giá sản phẩm sẽ thay đổi theo thời gian – được lưu lại trong bảng ChiTietDonHang 
		-- lấy mức giá bán ra khác biệt với từ khóa distinct) 

SELECT
    sp.maSP,
    sp.tenSP,
    AVG(DISTINCT ctdh.donGia) AS GiaTrungBinh,
    MAX(DISTINCT ctdh.donGia) AS GiaMax,
    MIN(DISTINCT ctdh.donGia) AS GiaMin
FROM dbo.SanPham sp
JOIN dbo.ChiTietDonHang ctdh ON sp.maSP = ctdh.maSP
GROUP BY sp.maSP, sp.tenSP;
--11thống kê số lần khách hàng mua hàng của từng khách hàng (sắp xếp giảm dần)  group by – order by 
INSERT INTO dbo.DonDatHang_HoaDon
VALUES
	('2225030324','2225000024','2225001024','23/1/2023',N'Vinh-Nghệ An','0123451204','12305','12/11/2023','14/11/2023','BT'),
	('2225031424','2225000124','2225001124','13/2/2023',N'Nam Đàn-Nghệ An','0123406755','52346','12/11/2023','14/11/2023',default),
	('2225033524','2225000224','2225002224','3/3/2023',N'Tương Dương-Nghệ An','0103456756','10347','12/11/2023','14/11/2023','ER');
	SELECT kh.maKH, tenKH, COUNT(ddh.maKH)as soLanMua
	FROM dbo.KhachHang as kh
	JOIN dbo.DonDatHang_HoaDon as ddh on kh.maKH = ddh.maKH
	GROUP BY kh.maKH, tenKH
	ORDER BY count(ddh.maKH) DESC;
--12hiển thị thông tin chi tiết của các sản phẩm mà có số lần nhập hàng nhiều nhất 
			---(lưu ý trường hợp những sản phẩm cùng giá trị) with ties, hoặc có thể dùng subquery Select top 1 with ties …. 
SELECT sp.maSP, sp.tenSP
FROM dbo.SanPham as sp
	JOIN dbo.ChiTietPhieuNhap as ct on ct.maSP= sp.maSP
GROUP BY sp.maSP, sp.tenSP
HAVING count(ct.maSP) in (
	SELECT DISTINCT TOP 1 count(ct.maSP)
	FROM dbo.ChiTietPhieuNhap as ct
	GROUP BY maSP
	ORDER BY count(ct.maSP) DESC
);



--13hiển thị thông tin chi tiết của các nhà cung cấp mà có số lần nhập hàng lớn hơn 2 count – group - having 
select * from dbo.NhaCungCap
SELECT ncc.maNCC, ncc.tenNCC, count (pn.maNCC)
FROM dbo.NhaCungCap as ncc
	JOIN dbo.PhieuNhap as pn on pn.maNCC= ncc.maNCC
	JOIN dbo.ChiTietPhieuNhap as ct on ct.maPN = pn.maPN
GROUP BY ncc.maNCC, ncc.tenNCC
HAVING count(pn.maNCC) in (
	SELECT DISTINCT TOP 1 count(p.maNCC)
	FROM dbo.PhieuNhap as p
	GROUP BY p.maNCC
	HAVING count(p.maNCC)>2
);
select * from PhieuNhap
order by maNCC DESC

/*
Câu 1:Hãy viết câu truy vấn hiển thị số lượng còn của sản phẩm,
bổ sung thêm cột có tên "Cảnh báo" để hiển thị: nếu số lượng còn <5 thì hiển thị "Nhập hàng gấp", 
ngược lại hiển thị "Hàng còn đủ dùng"

*/

SELECT sp.*,
	CASE 
		WHEN sp.soLuongHienCon < 5 THEN N'Nhập hàng gấp'
		ELSE  N'Hàng còn đủ dùng'
	END as Canhbao
FROM dbo.SanPham as sp
/*
Câu 2:Hãy viết câu truy vấn để xuất câu thông báo:
"Không đủ số lượng đặt" nếu tồn tại một sản phẩm có số lượng đặt vượt quá số lượng 
còn đối với đơn hàng có mã đơn hàng là 'DH05' (hoặc tùy mã theo dữ liệu bạn đã nhập), 
ngược lại hiển thị câu thông báo "Đặt hàng thành công!"
*/
if exists (SELECT ddh.*
FROM dbo.DonDatHang_HoaDon ddh, dbo.ChiTietDonHang ctdh, SanPham as sp
WHERE ddh.maHD = ctdh.maHD and ctdh.maSP = sp.maSP
and ddh.maHD ='2225001324'
and ctdh.soLuongDat >sp.soLuongHienCon)
	print N'Không đủ sô lượng đặt'
else
	print N'Đăt hàng thành công'





	-- BAI TAP NGAY 28/11
	/*
Viết các đoạn lệnh để thực hiện các công việc sau: */
--1Hãy xuất dạng Text giá tiền của những sản phẩm có giá tiền lớn nhất 

SELECT CONCAT(N'Sản phẩm ', maSP, N' có giá tiền là ', FORMAT(donGiaBan, 'C')) AS GiaTien
FROM SanPham
WHERE donGiaBan = (SELECT MAX(donGiaBan) FROM SanPham);

--2Hãy viết đoạn lệnh để tìm giá trị id tiếp theo của bảng sản phẩm, và chèn dữ liệu vào bảng sản phẩm 
-- Tìm giá trị id tiếp theo
DECLARE @NextId BIGINT; 
SELECT @NextId = (MAX(CAST(SanPham.maSP AS BIGINT))+ 1) FROM SanPham;
-- Chèn bản ghi mới vào bảng SanPham
INSERT INTO SanPham ( maSP, tenSP, donGiaBan, soLuongHienCon, soLuongCanDuoi)
VALUES ( CAST(@NextId AS VARCHAR(10)), N'Bánh kẹo hải hà', 10000, 50, 10);

-- kiểm tra thay đổi 
select * from dbo.SanPham

--3Hãy viết đoạn lệnh để đếm số lần mua hàng của từng khách hàng,
		--nếu số lần mua lớn hơn hoặc bằng 10 thì ghi ‘Khách hàng thân thiết’, ngược lại ghi ‘Khách hàng tiềm năng’ 

SELECT k.tenKH, k.maKH, COUNT(d.maHD) AS 'SoLanMua',
	CASE 
		WHEN COUNT(d.maHD) >=10 THEN N'Khách hàng thân thiết'
		ELSE 'Khach hang tiem nang'
	END AS LoaiKhachhang
FROM dbo.KhachHang k
JOIN dbo.DonDatHang_HoaDon d ON k.maKH = d.maKH
GROUP BY tenKH, k.maKH;

SELECT * FROM DBO.DonDatHang_HoaDon


--4Hãy viết đoạn lệnh để tính tiền cho đơn hàng mới nhất (đơn hàng vừa được mua).  
		--(Đơn hàng mới nhất là đơn hàng có thời gian gần nhất) 
SELECT TOP 1 k.tenKH,k.maKH,d.maHD,d.ngayGiaoHang ,SUM(c.donGia*c.soLuongDat) as 'TongTien'
FROM dbo.DonDatHang_HoaDon d 
JOIN KhachHang k ON d.maKH= k.maKH
JOIN ChiTietDonHang c ON d.maHD =c.maHD
GROUP BY  k.tenKH,k.maKH,d.maHD,d.ngayGiaoHang 
ORDER BY d.ngayGiaoHang DESC


--5Nếu tổng tiền lớn hơn 1.000.000 thì áp dụng giảm 10% và cập nhật lại tổng tiền mới cần trả; 
    --Nếu tổng tiền từ 400.000 đến dưới 1.000.000 thì tổng tiền không cần cộng phí ship;
    --Nếu tổng tiền nhỏ hơn 400.000 thì tổng tiền gồm tổng tiền hàng và phí ship (giả sử phí ship là 40.000) 
SELECT k.tenKH, k.maKH ,d.maHD ,d.ngayGiaoHang , SUM(c.donGia*c.soLuongDat) as 'TongTien' , 
	CASE 
        WHEN SUM(c.donGia * c.soLuongDat) > 1000000 THEN SUM(c.donGia * c.soLuongDat) * 0.9
		WHEN SUM(c.donGia * c.soLuongDat) >= 400000 AND SUM(c.donGia * c.soLuongDat) < 1000000 THEN SUM(c.donGia * c.soLuongDat)
		WHEN SUM(c.donGia * c.soLuongDat) <400000 THEN SUM(c.donGia * c.soLuongDat)+40000
        ELSE SUM(c.donGia * c.soLuongDat)
    END AS GiaSauKhiGiam
FROM dbo.DonDatHang_HoaDon d 
JOIN dbo.KhachHang k ON d.maKH = k.maKH
JOIN dbo.ChiTietDonHang c ON c.maHD = d.maHD
GROUP BY  k.tenKH,k.maKH,d.maHD,d.ngayGiaoHang 



--6Hãy viết đoạn lệnh để thực hiện yêu cầu:
	--kiểm tra xem có đơn hàng nào mà tồn tại số lượng mua lớn hơn số lượng hiện có 
      ---> nếu có thì cập nhật số lượng hiện còn của các sản phẩm nằm trong giỏ hàng mà có số lượng đặt lớn hơn số lượng hiện còn
			--bằng cách gán về số lượng đặt là 0 



DECLARE @maHDToUpdate char(10);
SELECT @maHDToUpdate = d.maHD
FROM dbo.DonDatHang_HoaDon d 
JOIN dbo.ChiTietDonHang c ON d.maHD = c.maHD 
JOIN dbo.SanPham s ON c.maSP = s.maSP
WHERE c.soLuongDat > soLuongHienCon
	AND d.maHD = '2225001324'
	AND ngayGiaoHang IS NULL
	AND trangThaiDonHang IS NULL;

IF @maHDToUpdate IS NOT NULL
BEGIN
	UPDATE dbo.ChiTietDonHang 
	SET soLuongDat = 0  
	WHERE maHD = @maHDToUpdate;
END
ELSE
	PRINT N'Don hang duoc dat thanh cong';

--7Viết đoạn lệnh để tính khuyến mãi theo điều kiện sau: nếu đơn hàng trên 1 triệu thì được giảm 10%,
		--cứ tăng thêm 1 triệu nữa thì được giảm thêm 2% nữa (tối đa giảm 30%) 


SELECT k.tenKH, k.maKH ,d.maHD ,d.ngayGiaoHang , SUM(c.donGia*c.soLuongDat) as 'TongTien' , 
	CASE 
        WHEN SUM(c.donGia * c.soLuongDat) > 1000000 THEN SUM(c.donGia * c.soLuongDat) * 0.9
		WHEN SUM(c.donGia * c.soLuongDat) >2000000 THEN SUM(c.donGia * c.soLuongDat) *0.8
		WHEN SUM(c.donGia * c.soLuongDat) >3000000 THEN SUM(c.donGia * c.soLuongDat)*0.7
        ELSE SUM(c.donGia * c.soLuongDat)
    END AS GiaSauKhiGiam
FROM dbo.DonDatHang_HoaDon d 
JOIN dbo.KhachHang k ON d.maKH = k.maKH
JOIN dbo.ChiTietDonHang c ON c.maHD = d.maHD
GROUP BY  k.tenKH,k.maKH,d.maHD,d.ngayGiaoHang 


--8Viết đoạn lệnh để đếm số lần mua của mỗi khách hàng, nếu số lần mua trên 5 thì hiển thị “Khách Vip”,
		--ngược lại hiển thị “Khách tiềm năng” 

SELECT k.tenKH, k.maKH, COUNT(k.maKH) as 'So lan mua',
	CASE	
		WHEN COUNT(k.maKH)>5 THEN N'Khách Vip'
		ELSE N'Khách tiem năng'
	END AS LoaiKhachHang

FROM dbo.KhachHang k
JOIN dbo.DonDatHang_HoaDon dh ON k.maKH = dh.maKH
JOIN dbo.ChiTietDonHang ct ON ct.maHD = dh.maHD
GROUP BY k.tenKH , k.maKH
    -- mặc dù ở DonDatHang_HoaDon có 17 row nhưng tổng ố lần mua ở đây chỉ có 15 là vì ở trong bảng khách hàng có 2 row
		   -- maKH ==NULL nên nó không thể GROUP BY lại và select được 


--Bai 2Viết các hàm tính: 
--Thành tiền khi biết đơn giá và số lượng đặt 
     --> tham số vào là đơn giá và số lượng đặt

CREATE FUNCTION Fn_ThanhTien(
@donGia MONEY , @soLuong INT )
RETURNS MONEY
AS 
BEGIN 
	RETURN @donGia*@soLuong
END ;

select maHD, maSP, soLuongDat,
    format(donGia,'##,#\ VNĐ','es-ES') as 'Đơn Giá',
    format(dbo.Fn_ThanhTien(donGia, soLuongDat),'C0','vn-VN') as 'Thành tiền'
from ChiTietDonHang
order by maHD

--tổng tiền cho mỗi đơn hàng khi biết mã đơn hàng 
--> tham số vào là mã đơn hàng 
ALTER TABLE dbo.ChiTietDonHang
ALTER COLUMN maHD char(10);
select * from dbo.ChiTietDonHang

CREATE FUNCTION Fn_TongThanhTienDonHang(@maDonHang varchar(255)) 
RETURNS MONEY 
AS
BEGIN 
	DECLARE @tongThanhTien MONEY
	SELECT @tongThanhTien = SUM(dbo.fn_ThanhTien(donGia, soLuongDat) )
	FROM dbo.ChiTietDonHang ct
	WHERE ct.maHD = @maDonHang
	RETURN @tongThanhTien
END 
SELECT 
    maHD,
    format(dbo.Fn_TongThanhTienDonHang(maHD), 'C0', 'vn-VN') as 'Tổng thành tiền đơn hàng'
FROM ChiTietDonHang


--tính thành tiền sau khi đã áp dụng khuyến mãi khi biết mã khuyến mãi, số lượng bán, đơn giá 

--> tham số vào là gì? 
CREATE FUNCTION TinhThanhTienSauKhuyenMai(
    @maKhuyenMai INT,
    @soLuongBan INT,
    @donGia MONEY
)
RETURNS MONEY
AS
BEGIN
    DECLARE @thanhTien MONEY;
	-- thực hiện tính toán 
    RETURN @thanhTien;
END;

-- Giả sử có một bảng tên là KhuyenMai
CREATE FUNCTION TinhThanhTienSauKhuyenMai(
    @maKhuyenMai INT,
    @soLuongBan INT,
    @donGia MONEY
)
RETURNS MONEY
AS
BEGIN
    DECLARE @thanhTien MONEY;

    DECLARE @tyLeKhuyenMai FLOAT;
    SELECT @tyLeKhuyenMai = TyLeKhuyenMai
    FROM BangKhuyenMai 
    WHERE MaKhuyenMai = @maKhuyenMai;
    SET @thanhTien = @soLuongBan * @donGia * (1 - @tyLeKhuyenMai);

    RETURN ISNULL(@thanhTien, 0);
END;

--tổng tiền thu vào theo từng tháng – năm, hoặc từ ngày đến ngày (hoặc ngày bắt đầu và ngày kết thúc) 
-->tham số vào là gì? 
CREATE FUNCTION TinhTongTienThu(
    @thang INT,
    @nam INT,
    @ngayBatDau DATE,
    @ngayKetThuc DATE
)
RETURNS MONEY
AS
BEGIN
    DECLARE @tongTienThu MONEY;
	

    RETURN @tongTienThu;
END;


	