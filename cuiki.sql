set dateformat dmy
select maHD, maSP, soLuongDat,
    format(donGia,'##,#\ VNĐ','es-ES') as 'Đơn Giá',
    format(dbo.Fn_ThanhTien(donGia, soLuongDat),'C0','vn-VN') as 'Thành tiền'
from ChiTietDonHang
order by maHD
-- FUNCTION 
	-- BAI TAP NGAY 28/11
	/*
Viết các đoạn lệnh để thực hiện các công việc sau: */
--1Hãy xuất dạng Text giá tiền của những sản phẩm có giá tiền lớn nhất 

SELECT CONCAT(N'Sản phẩm ', maSP, N' có giá tiền là ', FORMAT(donGiaBan, 'C', 'vi-VN')) AS GiaTien
FROM SanPham
WHERE donGiaBan = (SELECT MAX(donGiaBan) FROM SanPham);


SELECT CONCAT(N'Sản phẩm ', maSP, N' có giá tiền là ', FORMAT(donGiaBan, 'C', 'vi-VN')) AS GiaTien
FROM dbo.SanPham 
WHERE donGiaBan = (SELECT MAX(donGiaBan) FROM SanPham) 

--2Hãy viết đoạn lệnh để tìm giá trị id tiếp theo của bảng sản phẩm, và chèn dữ liệu vào bảng sản phẩm 
-- Tìm giá trị id tiếp theo


ALTER FUNCTION fn_IdAuto
()
returns char(10)
as
begin 
	-- tinh id tiep theo
	Declare @idNext bigint;
	select @idNext = convert(decimal,max(maSP))+1 from dbo.SanPham
	return convert(char,format(@idNext,'D10'));
end
SELECT dbo.fn_IdAuto() AS maspnext;
-- Sử dụng hàm trong truy vấn SELECT
select * from dbo.ChiTietDonHang

CREATE FUNCTION idNextSP ()
RETURNS CHAR(10)
AS
BEGIN 
	-- tinh id tiếp theo 
	DECLARE @idNext bigint;-- BIGINT
	SELECT @idNext = CONVERT(DECIMAL,max(maSP))+1 FROM dbo.SanPham
	print CONVERT(Char, format(@idNext,'D10'))
END;

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

select * from dbo.DonDatHang_HoaDon 
ORDER BY 


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


ALTER FUNCTION dbo.Fn_tinhTienGiamChoDonHang
(@maHD char(10))
RETURNS MONEY 
AS
BEGIN
	DECLARE @tongTien MONEY, @giam MONEY;
	SET @tongTien = dbo.Fn_TongThanhTienDonHang(@maHD) / 1000000;
	SET @giam = 0;
	SET @giam = @giam + CASE WHEN @tongTien > 1 THEN 10 ELSE 0 END;
	WHILE @tongTien > 2
	BEGIN 
		SET @giam = @giam + 2;
		SET @tongTien = @tongTien - 1;
	END
	IF @giam > 30 
		SET @giam = 30;
	DECLARE @SoTienGiamGia MONEY;
	SET @SoTienGiamGia = @tongTien * (@giam / 100)*1000000
	RETURN @SoTienGiamGia
END;

SELECT maHD,sum(soLuongDat*donGia) as tongTien,  dbo.Fn_tinhTienGiamChoDonHang(maHD) as TienGiam, sum(soLuongDat*donGia)-dbo.Fn_tinhTienGiamChoDonHang(maHD) as SoTienPhaiTra
FROM dbo.ChiTietDonHang
GROUP BY maHD


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


SELECT K.tenKH, K.maKH, COUNT(DDH.maHD)AS 'soLanMua',
	CASE
		WHEN COUNT(DDH.maHD)
	END;
FROM dbo.KhachHang AS K
JOIN dbo.DonDatHang_HoaDon AS DDH ON K.maKH = DDH.maKH
GROUP BY DDH.maHD
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
    format(dbo.Fn_TongThanhTienDonHang(maHD), 'C0', 'vi-VN') as 'Tổng thành tiền đơn hàng'
FROM ChiTietDonHang


--tính thành tiền sau khi đã áp dụng khuyến mãi khi biết mã khuyến mãi, số lượng bán, đơn giá 

--> tham số vào là gì? 
CREATE FUNCTION TinhThanhTienSKhuyenMai(
    @KhuyenMai INT,
    @soLuongBan INT,
    @donGia MONEY
)
RETURNS MONEY
AS
BEGIN
    DECLARE @thanhTien MONEY;
	 SET @thanhTien = @soLuongBan * @donGia * (1 - @KhuyenMai);
    RETURN @thanhTien;
END;

select dbo.TinhThanhTienSKhuyenMai(0.2, 30, 1000)
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
CREATE FUNCTION dbo.func_TongTienThuTheoTG (
    @ThangNam VARCHAR(7) = NULL,
    @NgayBatDau DATE = NULL,
    @NgayKetThuc DATE = NULL
)
RETURNS MONEY
AS
BEGIN
    DECLARE @TongTien MONEY;

    SELECT @TongTien = SUM(DonGia * SoLuongDat)
    FROM ChiTietDonHang AS c 
    JOIN dbo.DonDatHang_HoaDon AS d ON c.maHD = d.maHD
    WHERE 
        (@ThangNam IS NOT NULL AND FORMAT(d.ngayThanhToan, 'yyyy-MM') = @ThangNam)
        OR 
        (@NgayBatDau IS NOT NULL AND @NgayKetThuc IS NOT NULL AND ngayThanhToan BETWEEN @NgayBatDau AND @NgayKetThuc);

    RETURN ISNULL(@TongTien, 0);
END;


select * 
    FROM ChiTietDonHang AS c 
    JOIN dbo.DonDatHang_HoaDon AS d ON c.maHD = d.maHD

-- Câu 1 Viết đoạn lệnh để tính khuyến mãi theo điều kiện sau:
--nếu đơn hàng trên 1 triệu thì được giảm 10%, cứ tăng thêm 1 triệu nữa thì được giảm thêm 2% nữa (tối đa giảm 30%) 

ALTER FUNCTION dbo.Fn_tinhTienGiamChoDonHang
(@maHD char(10))
RETURNS MONEY 
AS
BEGIN
	DECLARE @tongTien MONEY, @giam MONEY;
	SET @tongTien = dbo.Fn_TongThanhTienDonHang(@maHD) / 1000000;
	SET @giam = 0;
	SET @giam = @giam + CASE WHEN @tongTien > 1 THEN 10 ELSE 0 END;
	WHILE @tongTien > 2
	BEGIN 
		SET @giam = @giam + 2;
		SET @tongTien = @tongTien - 1;
	END
	IF @giam > 30 
		SET @giam = 30;
	DECLARE @SoTienGiamGia MONEY;
	SET @SoTienGiamGia = @tongTien * (@giam / 100)*1000000
	RETURN @SoTienGiamGia
END;

SELECT DDH.maHD, DDH.maKH,dbo.Fn_ThanhTien(donGia,soLuongDat) TongTien, dbo.Fn_tinhTienGiamChoDonHang(DDH.maHD)GiamGia,dbo.Fn_ThanhTien(donGia,soLuongDat)- dbo.Fn_tinhTienGiamChoDonHang(DDH.maHD)ThanhToan
FROM dbo.DonDatHang_HoaDon AS DDH
JOIN dbo.ChiTietDonHang CT ON DDH.maHD = CT.maHD



-- PROCEDURE















-- PROCEDURE
-- -- Tạo PROCEDURE;
-- câu 7a
ALTER PROCEDURE TinhTienGiamChoDonHangProcedure
    @maHD CHAR(10)
AS
BEGIN
    DECLARE @tongTien MONEY, @giam MONEY, @SoTienGiamGia MONEY;
    SET @tongTien = dbo.Fn_TongThanhTienDonHang(@maHD) / 1000000;
    SET @giam = 0;
    SET @giam = @giam + CASE WHEN @tongTien > 1 THEN 10 ELSE 0 END;
    WHILE @tongTien > 2
    BEGIN 
        SET @giam = @giam + 2;
        SET @tongTien = @tongTien - 1;
    END
    IF @giam > 30 
        SET @giam = 30;
    SET @SoTienGiamGia = @tongTien * (@giam / 100) * 1000000;
	SELECT @SoTienGiamGia
END;
EXEC TinhTienGiamChoDonHangProcedure @maHD = '2225001324';

-- câu 2 a 
CREATE PROCEDURE ThanhTienProcedure
    @donGia MONEY,
    @soLuong INT
AS 
BEGIN 
    SELECT
        @donGia AS DonGia,
        @soLuong AS SoLuong,
        format(@donGia * @soLuong, 'C0', 'vn-VN') AS 'ThanhTien';
END;

EXEC ThanhTienProcedure @donGia = 10000, @soLuong = 5;

-- viết function tính thành tiên cho tất cả đơn hàng của bảng chi tiết đơn hàng 
ALTER PROCEDURE ThanhTienProcedure2
AS 
BEGIN 
    SELECT
		ct.maHD,
        format( ct.donGia*ct.soLuongDat , 'C0', 'vi-VN') AS 'ThanhTien'
		FROM dbo.ChiTietDonHang ct
END;

EXEC ThanhTienProcedure2

-- câu 2b
CREATE PROCEDURE TongThanhTienDonHangProcedure
    @maDonHang VARCHAR(255)
AS
BEGIN
    DECLARE @tongThanhTien MONEY;

    SELECT @tongThanhTien = SUM(dbo.fn_ThanhTien(donGia, soLuongDat))
    FROM dbo.ChiTietDonHang ct
    WHERE ct.maHD = @maDonHang;

    SELECT @tongThanhTien AS 'TongThanhTien';
END;

-- tính cho tất cả đơn hàng

CREATE PROCEDURE TongThanhTienDonHangProcedure2
AS
BEGIN

    SELECT ct.maHD, FORMAT(SUM(donGia*soLuongDat),'C0','vi-VN')
    FROM dbo.ChiTietDonHang ct
	GROUP BY ct.maHD, ct.donGia, ct.soLuongDat
END;

EXEC TongThanhTienDonHangProcedure2 



-- câu 2 c
CREATE PROCEDURE ThanhTienKhuyenMaiProcedure
    @KhuyenMai INT,
    @soLuongBan INT,
    @donGia MONEY
AS
BEGIN
    DECLARE @thanhTien MONEY;

    SET @thanhTien = @soLuongBan * @donGia * (1 - @KhuyenMai);

    SELECT @thanhTien AS 'ThanhTien';
END;


EXEC dbo.ThanhTienKhuyenMaiProcedure
 @KhuyenMai = 0.2,
    @soLuongBan= 30,
    @donGia =1000;

-- PROCEDURE-- câu 2 d ;
CREATE PROCEDURE dbo.pro_TongTienThuTheoTG (
    @ThangNam VARCHAR(7) = NULL,
    @NgayBatDau DATE = NULL,
    @NgayKetThuc DATE = NULL
)
AS
BEGIN
    DECLARE @TongTien MONEY;

    SELECT @TongTien = SUM(DonGia * SoLuongDat)
    FROM ChiTietDonHang as c 
	JOIN dbo.DonDatHang_HoaDon as d ON c.maHD = d.maHD
    WHERE 
        (@ThangNam IS NOT NULL AND FORMAT(d.ngayThanhToan, 'yyyy-MM') = @ThangNam)
        OR 
        (@NgayBatDau IS NOT NULL AND @NgayKetThuc IS NOT NULL AND ngayThanhToan BETWEEN @NgayBatDau AND @NgayKetThuc);

    SELECT ISNULL(@TongTien, 0) AS 'TongTien';
END;

EXEC dbo.pro_TongTienThuTheoTG @ThangNam = '2023-6' ;









-- BÀI TẬP TRIGGER 
/*
1.Viết các trigger để (có kiểm tra số lượng còn với số lượng đặt – có kết hợp với discount): 
 a,Khi insert – update – delete ở bảng ChiTietDonHang 
		i.tăng/giảm số lượng ở bảng SanPham 
       ii .cập nhật đơn giá bán ở bảng ChiTietDonHang theo giá bán hiện tại (được lưu ở bảng SanPham)  
 b,Khi insert – update – delete ở bảng ChiTietPhieuNhap 
     i.tăng/giảm số lượng ở bảng SanPham  
    ii.cập nhật đơn giá bán ở bảng SanPham (lãi 30%) 
Có thể viết riêng các trigger cho từng sự kiện trên 1 table, hoặc gộp lại - đi kèm với câu lệnh IF exists (select từ Inserted hoặc Deleted).

*/
ALTER TRIGGER trig_CTDH
ON dbo.ChiTietDonHang
AFTER INSERT , UPDATE, DELETE 
AS 
BEGIN 
	If not exists(select * from inserted) 
	--➔ đã DELETE data
		BEGIN 
			UPDATE dbo.SanPham 
			SET SanPham.soLuongHienCon = SanPham.soLuongHienCon + d.soLuongDat 
			FROM deleted AS d
			WHERE SanPham.maSP = d.maSP
		END;
	save tran sp1;
	If not exists(select * from deleted) 
	--➔ đã INSERT data 
		BEGIN 
			UPDATE dbo.SanPham 
			SET SanPham.soLuongHienCon = SanPham.soLuongHienCon - i.soLuongDat
			FROM inserted AS i
			WHERE SanPham.maSP = i.maSP;
		END;
	Else
	--➔ có Update data
		BEGIN 
			UPDATE SanPham
			SET SanPham.soLuongHienCon = SanPham.soLuongHienCon +d.soLuongDat -i.soLuongDat
			FROM inserted AS i, deleted AS d 
			WHERE i.maSP = d.maSP and i.maHD = d.maHD
		END;
	UPDATE dbo.ChiTietDonHang 
	SET donGia = P.donGiaBan 
	FROM dbo.SanPham AS P
	WHERE P.maSP = ChiTietDonHang.maSP
END;

/*check
select *from dbo.SanPham

select *from dbo.ChiTietDonHang where maHD ='2225002224' and maSP = '2225014024'

INSERT INTO dbo.ChiTietDonHang 
VALUES ('2225002224', '2225014024', 500,NULL)

UPDATE dbo.ChiTietDonHang 
SET soLuongDat = 700 
where maHD ='2225002224' and maSP = '2225014024'

ALTER TABLE dbo.ChiTietDonHang
ALTER COLUMN donGia money NULL;
select * from dbo.DonDatHang_HoaDon

DELETE  dbo.ChiTietDonHang
WHERE maHD ='2225002224' and maSP = '2225014024'

*/
---1. b lãi 30% có nghĩa là nhập thêm một san phẩm thì đơn giá bán sẽ giảm đ
ALTER TRIGGER tr_ChiTietPhieuNhap
ON ChiTietPhieuNhap
AFTER INSERT, DELETE, UPDATE
AS
BEGIN
	BEGIN TRANSACTION

	DECLARE @giaCu MONEY;

	IF NOT EXISTS (SELECT * FROM deleted)
	BEGIN
		-- Hành động insert
		-- Tăng số lượng ở bảng SanPham
		UPDATE SanPham
		SET soLuongHienCon = soLuongHienCon + i.soLuongNhap
		FROM inserted i
		WHERE SanPham.maSP = i.maSP

		-- Cập nhật đơn giá bán ở bảng SanPham (lãi 30%) 
		UPDATE SanPham
		SET @giaCu = donGiaBan, donGiaBan = i.giaNhap * 1.3
		FROM inserted i
		WHERE SanPham.maSP = i.maSP
	END
	ELSE
		IF NOT EXISTS (SELECT * FROM inserted)
		BEGIN
			-- Hành động delete
			-- Giảm số lượng ở bảng SanPham
			UPDATE SanPham
			SET soLuongHienCon = soLuongHienCon - d.soLuongNhap
			FROM deleted d
			WHERE SanPham.maSP = d.maSP

			-- Cập nhật đơn giá bán ở bảng SanPham
			UPDATE SanPham
			SET donGiaBan = (SELECT TOP 1 c.giaNhap
							FROM ChiTietPhieuNhap c, SanPham s
							WHERE c.maSP = s.maSP
							ORDER BY c.maPN DESC
							)
			FROM deleted d
			WHERE SanPham.maSP = d.maSP
		END
		ELSE
		BEGIN
			IF UPDATE(soLuongNhap)
			BEGIN
				-- Hành động update
				-- Thay đổi số lượng ở bảng SanPham
				UPDATE SanPham
				SET soLuongHienCon = soLuongHienCon - d.soLuongNhap + i.soLuongNhap
				FROM deleted d, inserted i
				WHERE SanPham.maSP = d.maSP AND SanPham.maSP = i.maSP

				-- Cập nhật đơn giá bán ở bảng SanPham 
				UPDATE SanPham
				SET donGiaBan = i.giaNhap * 1.3
				FROM inserted i
				WHERE SanPham.maSP = i.maSP

				-- Kiểm tra nếu số lượng nhập nhỏ hơn 1, rollback transaction
				IF EXISTS (SELECT * FROM ChiTietPhieuNhap WHERE soLuongNhap < 1)
					ROLLBACK TRANSACTION
				ELSE
					COMMIT
			END
		END
	ELSE
		ROLLBACK

END

select *  from dbo.SanPham WHERE maSP =2225014024 or maSP=2225014224

INSERT INTO dbo.ChiTietPhieuNhap 
VALUES ('2220345524','2225014024', 200, 100000),
('2220345524','2225014224', 200, 45000000)

INSERT INTO dbo.PhieuNhap
VALUES('2220345524','2225012524','12-2-2023') 

DELETE dbo.ChiTietPhieuNhap
WHERE maPN ='2220345524' and maSP='2225014224'