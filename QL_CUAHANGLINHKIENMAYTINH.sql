CREATE DATABASE QL_CUA_HANG_LINH_KIEN_MAY_TINH
USE QL_CUA_HANG_LINH_KIEN_MAY_TINH

CREATE TABLE LOAISP
(
  MaLoai  INT IDENTITY(1,1),
  TenLoai NVARCHAR(50),
  CONSTRAINT PK_LoaiSP PRIMARY KEY (MaLoai)
);

CREATE TABLE NHACUNGCAP
(
  MaNCC INT IDENTITY(1,1),
  TenNCC NVARCHAR(50),
  SDT CHAR(12),
  Email NVARCHAR(30),
  DiaChi NVARCHAR(100),
  CONSTRAINT PK_NHACC PRIMARY KEY (MaNCC)
);

CREATE TABLE SANPHAM
(
  MaSP INT IDENTITY(1,1),
  TenSP NVARCHAR(50),
  SoLuongSP INT,
  NgaySX DATE,
  GiaBan FLOAT,
  GiaNhap float,
  ImageSP varbinary(Max),
  MoTa NVARCHAR(200),
  TrangThai NVARCHAR(20),
  MaLoai INT,
  MaNCC INT,
  CONSTRAINT PK_SP PRIMARY KEY (MaSP),
  CONSTRAINT FK_SP_LOAISP FOREIGN KEY (MaLoai) REFERENCES LOAISP(MaLoai),
  CONSTRAINT FK_SP_NCC FOREIGN KEY (MaNcc) REFERENCES NHACUNGCAP(MaNCC)
);

CREATE TABLE KHACHHANG
(
  MaKH INT IDENTITY(1,1),
  TenKH NVARCHAR(50),
  DiaChi NVARCHAR(100),
  SDT CHAR(12),
  GioiTinh NCHAR(5),
  CONSTRAINT PK_KH PRIMARY KEY (MaKH)
);

CREATE TABLE NHANVIEN
(
  MaNV INT IDENTITY(1,1),
  TenNV NVARCHAR(50),
  Anh IMAGE,
  SDT CHAR(12),
  DiaChi NVARCHAR(100),
  GioiTinh NCHAR(5),
  NgaySinh DATE,
  ChucVu NVARCHAR(20),
  CONSTRAINT PK_NV PRIMARY KEY (MaNV)
);

CREATE TABLE TAIKHOAN
( 
  MaNV INT,
  Username NVARCHAR(50) NOT NULL,
  Password NVARCHAR(50) NOT NULL,
  CONSTRAINT PK_TK PRIMARY KEY (Username),
  CONSTRAINT FK_TK_NV FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);

CREATE TABLE HOADON
(
  MaHD INT IDENTITY(1,1),
  MaKH INT,
  MaNV INT,
  NgayXuatHD DATE,
  TongTien FLOAT,
  CONSTRAINT PK_HD PRIMARY KEY (MaHD),
  CONSTRAINT FK_HD_KH FOREIGN KEY (MaKH) REFERENCES KHACHHANG(MaKH),
  CONSTRAINT FK_HD_NV FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);


CREATE TABLE CHITIETHD
(
  MaHD INT,
  MaSP INT,
  SoLuongBan INT,
  ThanhTien FLOAT,
  CONSTRAINT PK_CTHD PRIMARY KEY (MaHD, MaSP),
  CONSTRAINT FK_CTHD_HD FOREIGN KEY (MaHD) REFERENCES HOADON(MaHD),
  CONSTRAINT FK_CTHD_SP FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);

CREATE TABLE PHIEUNHAPHANG
(
  MaPhieu INT IDENTITY(1,1),
  MaNV INT,
  NgayNhap DATE,
  GhiChu NVARCHAR(100),
  TongTienNhap FLOAT,
  CONSTRAINT PK_PNH PRIMARY KEY (MaPhieu),
  CONSTRAINT FK_PNH_NV FOREIGN KEY (MaNV) REFERENCES NHANVIEN(MaNV)
);

-- Tạo bảng CHITIETPN
CREATE TABLE CHITIETPN
(
  MaPhieu INT,
  MaSP INT,
  SoLuongNhap INT,
  DonGiaNhap FLOAT,
  ThanhTien FLOAT,
  CONSTRAINT PK_CTPN PRIMARY KEY (MaPhieu, MaSP),
  CONSTRAINT FK_CTPN_PN FOREIGN KEY (MaPhieu) REFERENCES PHIEUNHAPHANG(MaPhieu),
  CONSTRAINT FK_CTPN_SP FOREIGN KEY (MaSP) REFERENCES SANPHAM(MaSP)
);

 SET DATEFORMAT DMY

--------------RÀNG BUỘC TOÀN VẸN DÙNG TRIGGER-----------------

--- *** Họ Tên: Nguyễn Thị Thu Hà
--TRIGGER CẬP NHẬT TRẠNG THÁI SẢN PHẨM
CREATE TRIGGER update_TrangThai_SP
ON SANPHAM
AFTER INSERT, UPDATE
AS
BEGIN
-- Cập nhật trạng thái cho sản phẩm
	IF UPDATE(soluongSP)
    UPDATE SANPHAM
    SET TrangThai = 
        CASE
            WHEN SANPHAM.SoLuongSP >= 10 THEN N'Đang bán'
            WHEN SANPHAM.SoLuongSP < 10  AND  SANPHAM.SoLuongSP >0 THEN  N'Sắp hết hàng'
			WHEN SANPHAM.SoLuongSP <= 0 THEN N'Tạm hết hàng'
            ELSE N'Ngừng bán'
        END
    FROM SANPHAM
    INNER JOIN inserted ON SANPHAM.MaSP = inserted.MaSP
END


-- *** Họ Tên: Đỗ Bảo Toàn
--Cập nhật số lượng sản phẩm khi bán
CREATE TRIGGER	Update_SL_SP
ON ChiTietHD
AFTER INSERT
AS 
BEGIN
	DECLARE @SLSP INT
	SET @SLSP=(SELECT SoLuongSP FROM dbo.SANPHAM WHERE MaSP=(SELECT MaSP FROM inserted))-(SELECT SoLuongBan FROM inserted)
    UPDATE dbo.SANPHAM
	SET SoLuongSP=@SLSP
	WHERE MaSP=(SELECT MaSP FROM inserted)
END

-- *** Họ Tên: Trần Ngọc Thanh
--Cập nhật thành tiền của chi tiết phiếu nhập
CREATE TRIGGER Update_ThanhTien_PhieuNhap
ON ChiTietPN
FOR INSERT
AS 
BEGIN
    UPDATE ChiTietPN
	SET ThanhTien=(SELECT SoLuongNhap FROM inserted)*(SELECT DonGiaNhap FROM inserted)
	WHERE MaPhieu=(SELECT MaPhieu FROM inserted)
END

drop trigger Update_ThanhTien_PhieuNhap

-- *** Họ Tên: Nguyễn Phương Điền
--Cập nhật tổng thành tiền của phiếu nhập
--CREATE TRIGGER Update_TongTien_PhieuNhap
--ON CHITIETPN
--FOR INSERT,update
--AS 
--BEGIN
--    UPDATE dbo.PHIEUNHAPHANG
--	SET TongTienNhap=(SELECT SUM(ThanhTien) FROM dbo.CHITIETPN WHERE MaPhieu=(SELECT MaPhieu FROM inserted))
--	WHERE MaPhieu=(SELECT MaPhieu FROM inserted)
--END

drop TRIGGER Update_TongTien_PhieuNhap


---------------------------------CÁC RÀNG BUỘC-----------------------
------------RÀNG BUỘC KIỂM TRA MIỀN GIÁ TRỊ(CHECK CONSTRAINT)-----------------
----1.BẢNG SẢN PHẨM---

ALTER TABLE SANPHAM
ADD CONSTRAINT CK_GIABAN CHECK(GiaBan>0)

-----2.BẢNG CHITIETHD---
ALTER TABLE CHITIETHD
ADD CONSTRAINT CK_SOLUONG CHECK(SoLuongBan>0)


-----3.BẢNG  CHITIETPN---
ALTER TABLE  CHITIETPN
ADD CONSTRAINT CK_SOLUONGNHAP CHECK(SoLuongNhap>0)

ALTER TABLE  CHITIETPN
ADD CONSTRAINT CK_DONGIANHAP CHECK(DonGiaNhap>0)

-----4.BẢNG  KHACHHANG---
ALTER TABLE KHACHHANG
ADD CONSTRAINT CK_GIOITINH_KH CHECK(GioiTinh IN(N'Nam', N'Nữ'))

-----5.BẢNG  KHACHHANG---
ALTER TABLE NHANVIEN
ADD CONSTRAINT CK_GIOITINH_NV CHECK(GioiTinh IN(N'Nam', N'Nữ'))

ALTER TABLE NHANVIEN
ADD CONSTRAINT CK_CHUCVU CHECK(ChucVu IN(N'Quản lý',N'Nhân viên'))

--------RÀNG BUỘC KIỂM TRA TÍNH DUY NHẤT (UNIQUE CONSTRAINT)-----------------

----1.BẢNG LOAISP---
ALTER TABLE LOAISP
ADD CONSTRAINT UNI_TENLOAI UNIQUE(TenLoai)

----2.BẢNG NHACUNGCAP---
ALTER TABLE NHACUNGCAP
ADD CONSTRAINT UNI_TENNCC UNIQUE(TenNcc)

----3.BẢNG SANPHAM---
ALTER TABLE SANPHAM
ADD CONSTRAINT UNI_TENSP UNIQUE(TenSP)

----4.BẢNG SANPHAM---
ALTER TABLE TAIKHOAN
ADD CONSTRAINT UNI_MANV UNIQUE(MaNV)

--------RÀNG BUỘC KIỂM TRA GIÁ TRỊ MẶC ĐỊNH (DEFAULT CONSTRAINT)-----------------
 ----1.BẢNG NHANVIEN---
 ALTER TABLE NHANVIEN
 ADD CONSTRAINT DF_DIACHI_NV DEFAULT N'Chưa xác định' FOR DiaChi

----2.BẢNG KHACHHANG---
ALTER TABLE KHACHHANG
ADD CONSTRAINT DF_DIACHI_KH DEFAULT N'Chưa xác định' FOR DiaChi

----3.BẢNG NHACUNGCAP---
ALTER TABLE NHACUNGCAP
ADD CONSTRAINT DF_DIACHI_NCC DEFAULT N'Chưa xác định' FOR DiaChi



-------------------******************** THÊM DỮ LIỆU *********************************-----------------------------

--<** Loại Sản Phẩm **>--
INSERT INTO LOAISP
VALUES
( N'Chuột'),
( N'Màn Hình'),
(N'Bàn Phím'),
( N'CPU'),
( N'Tai Nghe')

--<** Loại Sản Phẩm **>--
INSERT INTO NHACUNGCAP
VALUES 
(N'SamSung','0988558234','SamSung@gmail.com',N'123 Lê Trọng Tấn,Tân Phú,TP.HCM'),
(N'Asus','0982839123','Asus@gmail.com',N'24/157 Nguyễn Trãi,Tân Đông,Quận 3,TP.HCM'),
(N'Dell','0388838223','Dell@gmail.com',N'40B Lê Lợi,Tân Hưng Thuận,Hà Nội'),
(N'Razer','0983774723','Razer@gmail.com',N'98 Nguyễn Diệu,Hội An,TP Đà Nẵng'),
(N'Logitech','0983772133','Logitech@gmail.com',N'293/43 Nguyễn Văn Minh, TP.HCM'),
(N'HyperX','0375674783','HyperX@gmail.com',N'40/12/22 Hoàng Sa,Phường 3, Bình Thạnh,TP HCM'),
(N'Gigabyte','0387645321','Giagabyte@gmail.com',N'430/12/1 CMT8,Phường 5, Tân Bình, TP.HCM'),
(N'Corsair','097644552','Corsair@gmail.com',N'250 Bùi Xuân Phái, Tây Thạnh, Tân Phú, TP.HCM'),
(N'Acer','09322111233','Acer@gmail.com',N'330/20/11A, Nguyễn Đình Chiểu, Phường 3 Tân Bình, TP.HCM')

--<** Loại Sản Phẩm **>--
INSERT INTO SANPHAM
VALUES
(N'Chuột Logitech G102 LightSync Black',0, '12-09-2022',200000, NULL, NULL,NULL,NUll,1,1),
(N'PC GVN Intel i5-13400F/ VGA RTX 4060 Ti',0, '09-10-2019',150000, NULL, NULL, NULL,NULL,2,1),
(N'Bàn phím cơ ASUS ROG Strix Flare II Nx Red Switch',0, '09-10-2019',150000, NULL, NULL, NULL,NULL,1,2),
(N'Màn hình ASUS VA27EHF 27" IPS 100Hz viền mỏng',0, '09-10-2019',1200000, NULL, NULL, NULL,NUll,3,2)

select * from SANPHAM

delete SANPHAM where MaSP = 23

--<** Khách Hàng **>--
INSERT INTO KHACHHANG
VALUES
( N'Nguyễn Thu Tâm', N'Tây Ninh', '0989751723',N'Nữ'),
( N'Đinh Bảo Lộc', N'Lâm Đồng', '0918234654',N'Nam'),
( N'Trần Thanh Diệu', N'TP.HCM', '0978123765',N'Nữ'),
( N'Nguyễn Văn Thanh', N'Quảng Nam', '0918373790',N'Nam'),
( N'Nguyễn Trần Khánh Vân', N'TP.HCM', '0746902764',N'Nữ'),
( N'Đỗ Minh Hải', N'Quảng Bình', '0397238143',N'Nam'),
( N'Nguyễn Hải Yến', N'Cà Mau', '0398571209',N'Nữ'),
( N'Hà Đức Tài', N'TP.Vinh', '0554970710',N'Nam'),
( N'Ngô Minh Hải', N'Nghệ An', '0387238143',N'Nam'),
( N'Đỗ Thị Tường Vy', N'Hà Nội', '0559708156',N'Nữ'),
( N'Hồ Lê Khoa', N'Quảng Ngãi', '0327890456',N'Nữ'),
( N'Nguyễn Khánh Hữu', N'TP.HCM', '0778990399',N'Nam'),
( N'Trần Minh Hải', N'TP.HCM', '035278910',N'Nữ')

--<** Nhân Viên **>--
INSERT INTO NHANVIEN
VALUES
(N'Đỗ Bảo Toàn',NULL,'09477223664',N'Quảng Ngãi',N'Nam','19-12-1999',N'Quản lý'),
(N'Nguyễn Thị Thu Hà',NULL,'0988558043',N'TP.HCM',N'Nữ','21-01-2004',N'Nhân viên'),
(N'Trần Ngọc Thanh',NULL,'0647094638',N'TP.HCM',N'Nam','19-09-2003',N'Nhân viên'),
(N'Hồ Tuấn Thành',NULL,'0376103847',N'TP.Đà Nẵng',N'Nam','10-12-2003',N'Nhân viên'),
(N'Bùi Quỳnh Ly',NULL,'0758012637',N'TP.HCM',N'Nam','05-08-2002',N'Nhân viên')

select * from NHANVIEN

--<** Tài Khoản **>--
INSERT INTO TAIKHOAN
VALUES
(1,N'dobaotoan','123'),
(2,N'thuhanguyen','123'),
(3,N'ngocthanh','123')

--<** Hóa Đơn **>--
INSERT INTO HOADON 
VALUES
(3,1,'22-9-2023',60000000),
(1,2,'12-10-2023',400000),
(2,2,'27-08-2023',3000000),
(2,3,'27-10-2023',500000),
(1,1,'29-10-2023',1000000),
(2,2,'11-08-2023',560000),
(1,2,'21-08-2022',460000)

select * from HOADON

--<** Chi Tiết Hóa Đơn **>--

INSERT INTO CHITIETHD
VALUES 
(2,1, 10, 0),
(2,3, 1, 0),
(3,4, 2, 0),
(3,1, 1, 0),
(4,2, 1, 0),
(1,3, 1, 0),
(4,1, 1, 0)

--<** Phiếu Nhập Hàng **>--
INSERT INTO PHIEUNHAPHANG
VALUES
(2,'21-09-2022','NULL',20000000),
(2,'21-09-2022','NULL',10000000),
(3,'21-09-2022','NULL',20000000),
(4,'21-09-2022','NULL',15000000)

--<** Chi Tiết Phiếu Nhập Hàng **>--
INSERT INTO CHITIETPN
VALUES
(1,1,10,200000,0),
(2,2,15,100000,0),
(3,4,9,100000,0),
(4,1,7,100000,0),
(3,1,6,100000,0)


--------------------- **************  VIẾT THỦ TỤC THƯỜNG TRÚ  ************** ---------------------
---------PROC XEM CHI TIẾT PHIẾU NHẬP--------------------------
  CREATE PROC Data_CTPhieuNhap
 AS
	SELECT *
	FROM CHITIETPN 

----------PROC XEM HÓA ĐƠN--------------------------
 CREATE PROC Data_HoaDon
 AS
	SELECT *
	FROM HOADON
---------PROC XEM CHI TIẾT HÓA ĐƠN--------------------------
  CREATE PROC Data_CTHoaDon
 AS
	SELECT *
	FROM CHITIETHD 
--- <*** PROC LOẠI SẢN PHẨM ***> ----
--1. Data loại sản phẩm
create Proc Data_LoaiSanPham
 AS
	SELECT *
	FROM LOAISP 
----------SROTED PROCEDURE UPDATE LOẠI SẢN PHẨM	----------------------------
CREATE PROCEDURE updateLoaiSanPham
@MaLoai INT,
@TenLoai NVARCHAR(100)
AS
BEGIN

	    UPDATE LOAISP
    SET TenLoai = @TenLoai     
   WHERE MaLoai = @MaLoai
END
--------SROTED PROCEDURE XÓA LOẠI SẢN PHẨM ------------------------------
CREATE PROCEDURE DeleteLoaiSanPham
@MaLoai INT
AS    
    IF EXISTS (SELECT 1 FROM SANPHAM WHERE MaLoai = @MaLoai)        
			Return -1
	Else
    DELETE FROM LOAISP WHERE MaLoai = @MaLoai;
--------SROTED PROCEDURE THÊM LOẠI SẢN PHẨM MỚI	----------------------------
CREATE PROC insertLoaiSanPham
  @TenLoai NVARCHAR(50)
AS
BEGIN
  INSERT INTO LOAISP(TenLoai)
  VALUES (@TenLoai)  
  PRINT N'SẢN PHẨM ĐÃ ĐƯỢC THÊM'
  return 1;
END
--- <*** PROC NHÀ CUNG CẤP ***> ----

--1. Data nhà cung cấp
  CREATE PROC Data_NhaCungCap
 AS
	SELECT *
	FROM NHACUNGCAP
----------SROTED PROCEDURE UPDATE NHÀ CUNG CẤP----------------------------
CREATE PROCEDURE updateNhaCungCap
@MaNCC INT,
@TenNCC NVARCHAR(100),
@SDT char(12),
@Email char(50),
@DiaChi Nvarchar(100)
AS
BEGIN

	    UPDATE NHACUNGCAP
    SET TenNCC = @TenNCC,
		SDT=@SDT,
		Email=@Email,
		DiaChi=@DiaChi    
   WHERE MaNCC = @MaNCC
END


--------SROTED PROCEDURE XÓA NHÀ CUNG CẤP ------------------------------
CREATE PROCEDURE DeleteNhaCungCap
@MaNCC INT
AS    
    IF EXISTS (SELECT 1 FROM SANPHAM WHERE MaNCC = @MaNCC)        
			Return -1
	Else
    DELETE FROM NHACUNGCAP WHERE MaNCC = @MaNCC;
--------SROTED PROCEDURE THÊM NHÀ CUNG CẤP MỚI	----------------------------
CREATE PROC insertNhaCungCap
 @TenNCC NVARCHAR(100),
@SDT char(12),
@Email char(50),
@DiaChi Nvarchar(100)
AS
BEGIN
  INSERT INTO NHACUNGCAP(TenNCC,SDT,Email,DiaChi)
  VALUES (@TenNCC,@SDT,@Email,@DiaChi)  
  PRINT N'NHÀ CUNG CẤP ĐÃ ĐƯỢC THÊM'
  return 1;
END
--- <*** PROC SẢN PHẨM ***> ----

--1. Data sản phẩm
CREATE PROC Data_SanPham
 AS
	SELECT *
	FROM SANPHAM
--2. Thêm sản phẩm
CREATE PROC Insert_SanPham
  @TenSP NVARCHAR(50),
  @SoLuongSP INT,
  @NgaySX DATE,
  @GiaBan FLOAT,
  @GiaNhap FLOAT,
  @ImageSP varbinary(max), 
  @MoTa NVARCHAR(200),
  @MaLoai INT,
  @MaNcc INT
AS
BEGIN
  INSERT INTO SANPHAM (TenSP,SoLuongSP,NgaySX,GiaBan,GiaNhap,ImageSP,MoTa,MaLoai,MaNcc)
  VALUES (@TenSP, @SoLuongSP, @NgaySX,@GiaBan,@GiaNhap, @ImageSP,@MoTa,@MaLoai,@MaNcc)
END
----------SROTED PROCEDURE UPDATE SẢN PHẨM	----------------------------
CREATE PROCEDURE updateSanPhams
@MaSP INT,
@TenSP NVARCHAR(100),
@SoLuongSP INT,
@NgaySX DATE,
@GiaNhap FLOAT,
@GiaBan FLOAT,
@ImageSP varbinary(max)=null,
@MoTa NVARCHAR(500),
@MaLoai INT,
@MaNCC INT
AS
BEGIN
	    UPDATE SANPHAM
    SET TenSP = @TenSP, 
        SoLuongSP = @SoLuongSP,
        NgaySX = @NgaySX,
        GiaNhap = @GiaNhap, 
        GiaBan = @GiaBan,
		ImageSP=@ImageSP,
        MoTa = @MoTa,     
        MaLoai = @MaLoai,
        MaNCC = @MaNCC
  WHERE MaSP = @MaSP
END


--------SROTED PROCEDURE XÓA SẢN PHẨM ------------------------------
CREATE PROCEDURE DeleteSanPham
@MaSP INT
AS    
    IF EXISTS (SELECT 1 FROM CHITIETHD WHERE MaSP = @MaSP)
        OR EXISTS (SELECT 1 FROM CHITIETPN WHERE MaSP = @MaSP)       
			Return -1
	Else
    DELETE FROM SANPHAM WHERE MaSP = @MaSP;
--3. Get Max Sản Phẩm
CREATE PROC MAX_MASP
AS
 BEGIN
	SELECT MAX(MaSP) AS MaxMaSP FROM SANPHAM
END
--4. Data sản phẩm_Phiếu Nhập
CREATE PROC Data_SanPham_PhieuNhap
 AS
	SELECT NHACUNGCAP.TenNCC,LOAISP.TenLoai,SanPham.*
	FROM NHACUNGCAP,SANPHAM,LOAISP
	Where NHACUNGCAP.MaNCC = SANPHAM.MaNCC and LOAISP.MaLoai = SANPHAM.MaLoai
--5. Update số lượng sản phẩm
create proc UpdateSanPham
@MaSP int ,@SoLuongSP int
as
update SANPHAM set SoLuongSP = @SoLuongSP where MaSP = @MaSP

--6. Tìm kiếm sản phẩm theo tên
create proc TimKiemSPTheoTen
@TenSP nvarchar(50)
as
	Select * from SanPham where TenSP Like '%' + @TenSP + '%'

--7. Tìm kiếm sản phẩm theo loại
CREATE PROC TimKiemSPTheoLoai
    @MaLoai INT
AS
    SELECT *
    FROM SANPHAM
    WHERE MaLoai = @MaLoai
--8. Top 5 sản phẩm bán chạy nhất
create proc Top5SanPhamBanChay
as
	  SELECT TOP 5 
        sp.TenSP AS TenSanPham,
        SUM(ct.SoLuongBan) AS TongSoLuongBan
    FROM 
        SANPHAM sp
    INNER JOIN 
        CHITIETHD ct ON sp.MaSP = ct.MaSP
    GROUP BY 
        sp.TenSP
    ORDER BY 
        SUM(ct.SoLuongBan) DESC

exec Top5SanPhamBanChay
--9.get Sản Phẩm Sắp Hết Hàng
CREATE PROCEDURE GetCountSanPhamSapHetHang
AS
BEGIN
    SELECT COUNT(*) AS SoLuongSapHetHang
    FROM SANPHAM
    WHERE TrangThai = N'Sắp hết hàng';
END
--10.get all sp và số lượng
CREATE PROCEDURE GetAllProducts
AS
BEGIN
    SELECT TenSP,SoLuongSP
    FROM SANPHAM;
END

--- <*** PROC KHÁCH HÀNG ***> ----

--1. Data Khách Hàng
Create Proc Get_KhachHang
as
select * from KHACHHANG

--2. Thêm khách hàng
CREATE PROCEDURE InsertKhachHang
    @TenKH NVARCHAR(50),
    @DiaChi NVARCHAR(100),
    @SDT CHAR(12),
    @GioiTinh NCHAR(5)
AS
BEGIN
    INSERT INTO KHACHHANG (TenKH, DiaChi, SDT, GioiTinh)
    VALUES (@TenKH, @DiaChi, @SDT, @GioiTinh)
END
--3. Xóa khách hàng
create procedure DeleteKhachHang
@MaKH int
as
	if exists (Select 1 from HoaDon where MaKH = @MaKH)
		return -1
	else
		delete from KhachHang where MaKH = @MaKH
--4. Sửa khách hàng
Create PROC UpdateKhachHang
 @MaKH int ,@TenKH NVARCHAR(50), @DiaChi NVARCHAR(100), @SDT CHAR(12), @GioiTinh NCHAR(5)
as
  begin
	update KHACHHANG set TenKH = @TenKH , DiaChi =@DiaChi, SDT =@SDT , GioiTinh = @GioiTinh where MaKH = @MaKH
  end	
--5. Tìm mã khách hàng theo số điện thoại
CREATE PROC TimMaKHTheoSDT
@SDT CHAR(12)
AS
	BEGIN
		SELECT MAKH FROM KHACHHANG WHERE SDT=@SDT
	END

	EXEC TimMaKHTheoSDT '0989751723'

--6. Tìm tên khách hàng theo số điện thoại
CREATE PROC TimKhachHangTheoSDT
@SDT CHAR(12)
AS
	BEGIN
		SELECT TenKH FROM KHACHHANG WHERE SDT=@SDT
	END

--- <*** PROC NHÂN VIÊN ***> ----

--1. lấy toàn bộ thông tin của nhân viên---
CREATE PROC GET_NV
AS
BEGIN
     SELECT *FROM NHANVIEN
END
--2.Thêm mới 1 nhân viên--
CREATE PROCEDURE ThemNhanVien
  @TenNV NVARCHAR(50),
  @Anh Image,
  @SDT CHAR(12),
  @DiaChi NVARCHAR(100),
  @GioiTinh NCHAR(5),
  @NgaySinh DATE,
  @ChucVu NVARCHAR(20)
AS
BEGIN
  INSERT INTO NHANVIEN (TenNV,Anh,SDT, DiaChi, GioiTinh, NgaySinh, ChucVu)
  VALUES (@TenNV,@Anh, @SDT, @DiaChi, @GioiTinh, @NgaySinh, @ChucVu)
END
--3.Kiểm tra mã nhân viên có tồn tại hay chưa--
CREATE PROC CHECK_MANV
 @MaNV int
 AS
	BEGIN
		SELECT COUNT(*) FROM NHANVIEN WHERE @MaNV=MaNV
	END
--4.Sửa thông tin nhân viên--
CREATE PROCEDURE UpdateNhanVien
    @MaNV INT,
    @TenNV NVARCHAR(50),
	@Anh image,
    @SDT CHAR(12),
    @GioiTinh NCHAR(5),
    @DiaChi NVARCHAR(100),
    @ChucVu NVARCHAR(20),
    @NgaySinh DATE
AS
BEGIN
    UPDATE NHANVIEN
    SET
        TenNV = @TenNV,
		Anh=@Anh,
        SDT = @SDT,
        GioiTinh = @GioiTinh,
        DiaChi = @DiaChi,
        ChucVu = @ChucVu,
        NgaySinh = @NgaySinh
    WHERE MaNV = @MaNV
END 

--5.Xóa nhân viên--
CREATE PROCEDURE DeleteNhanVien
    @MaNV INT
AS
    IF EXISTS (SELECT 1 FROM TAIKHOAN WHERE MaNV = @MaNV)
        OR EXISTS (SELECT 1 FROM HOADON WHERE MaNV = @MaNV)
        OR EXISTS (SELECT 1 FROM PHIEUNHAPHANG WHERE MaNV = @MaNV)
		Return -1
	Else
	  DELETE FROM NHANVIEN WHERE MaNV = @MaNV

--- <*** PROC TÀI KHOẢN ***> ----
--1. Data nhân viên
CREATE PROC GET_TK
AS
	BEGIN
		SELECT TAIKHOAN.MaNV,NHANVIEN.TenNV,TAIKHOAN.Username,TAIKHOAN.Password,NHANVIEN.Anh,NHANVIEN.ChucVu FROM TAIKHOAN,NHANVIEN	WHERE NHANVIEN.MaNV=TAIKHOAN.MaNV
	END

--2.Thêm Tài khoản--
CREATE PROCEDURE ThemTaiKhoan
  @MaNV INT,
  @UserName NVARCHAR(50),
  @PassWord NVARCHAR(50)
 AS
	BEGIN 
		INSERT INTO TAIKHOAN(MaNV,Username,Password)
		VALUES(@MaNV,@UserName,@PassWord)
	END
--3.Kiểm tra tài khoản có tồn tại hay chưa
CREATE PROC CHECK_USERNAME
 @UserName	NVARCHAR(50)
 AS
	BEGIN
		SELECT COUNT(*) FROM TAIKHOAN WHERE Username=@UserName
	END
--4.Xóa Tài Khoản--
CREATE PROC DELETE_TK
@UserName NVARCHAR(50)
AS
	BEGIN
		DELETE FROM TAIKHOAN WHERE Username=@UserName 
	END

--5. Update Tài Khoản Đổi mật khẩu
CREATE PROCEDURE UpdatePassword
    @Username NVARCHAR(50),
    @NewPassword NVARCHAR(50)
AS
BEGIN
    UPDATE TAIKHOAN
    SET Password = @NewPassword
    WHERE Username = @Username;
END;

--- <*** PROC HÓA ĐƠN ***> ----
--1. Thêm Hóa Đơn
CREATE PROCEDURE InsertHD
    @MaKH INT,
    @MaNV INT,
    @NgayXuatHD DATETIME,
	@TongTien FLOAT
    
AS
BEGIN
    INSERT INTO HOADON(MaKH,MaNV,NgayXuatHD,TongTien)
    VALUES (@MaKH, @MaNV, @NgayXuatHD,@TongTien)
END
--2.Lấy max mã hd
CREATE PROC MAX_MAHD
AS
 BEGIN
	SELECT MAX(MaHD) AS MaxMaHD FROM HOADON
END
--- <*** PROC CHI TIẾT HÓA ĐƠN ***> ----
--1. Insert chi tiết hóa đơn
CREATE PROCEDURE InsertCTHD
    @MaHD INT,
    @MaSP INT,
    @SoLuongBan INT,
	@ThanhTien FLOAT  
AS
BEGIN
    INSERT INTO CHITIETHD(MaHD,MaSP,SoLuongBan,ThanhTien)
    VALUES (@MaHD, @MaSP, @SoLuongBan,@ThanhTien)
END
--2. In hóa đơn
create Proc InHoaDon
@MaHD int
as
SELECT HOADON.MaHD, KHACHHANG.TenKH, KHACHHANG.SDT, NHANVIEN.TenNV, HOADON.NgayXuatHD,SANPHAM.TenSP, SANPHAM.GiaBan, CHITIETHD.SoLuongBan, CHITIETHD.ThanhTien,HOADON.TongTien
FROM HOADON,CHITIETHD,KHACHHANG,SANPHAM,NHANVIEN
where SANPHAM.MaSP = CHITIETHD.MaSP and KHACHHANG.MaKH = HOADON.MaKH and HOADON.MaHD = CHITIETHD.MaHD and NHANVIEN.MaNV = HOADON.MaNV and HOADON.MaHD = @MaHD

--2. In phiếu nhập hàng
create proc InPhieuNhap
@MaPhieu int
as
select PHIEUNHAPHANG.MaPhieu,PHIEUNHAPHANG.NgayNhap,PHIEUNHAPHANG.GhiChu,PHIEUNHAPHANG.TongTienNhap,CHITIETPN.SoLuongNhap,CHITIETPN.DonGiaNhap,CHITIETPN.ThanhTien,
SANPHAM.TenSP,NHACUNGCAP.TenNCC,LOAISP.TenLoai,NHANVIEN.TenNV
from PHIEUNHAPHANG,NHANVIEN,SANPHAM,CHITIETPN,NHACUNGCAP,LOAISP
where PHIEUNHAPHANG.MaPhieu = CHITIETPN.MaPhieu and PHIEUNHAPHANG.MaNV = NHANVIEN.MaNV and CHITIETPN.MaSP = SANPHAM.MaSP and SANPHAM.MaNCC = NHACUNGCAP.MaNCC and SANPHAM.MaLoai = LOAISP.MaLoai
and PHIEUNHAPHANG.MaPhieu =@MaPhieu
--- <*** PROC PHIẾU NHẬP ***> ----

--1. Get max mã phiếu
CREATE PROC MAX_MAPN
AS
 BEGIN
	SELECT MAX(MaPhieu) AS MaxMaPN FROM PHIEUNHAPHANG
END

--2. Insert Phiếu Nhập Hàng
create proc insertPhieuNhap
@MaNV int,@NgayNhap Datetime,@GhiChu nvarchar(100),@TongTienNhap float
as
begin
	insert into PHIEUNHAPHANG(MaNV,NgayNhap,GhiChu,TongTienNhap)
	values (@MaNV,@NgayNhap,@GhiChu,@TongTienNhap)
end



--- <*** PROC CHI TIẾT PHIẾU NHẬP ***> ----
create proc insertCTPhieuNhap
@MaPhieu int,@MaSP int,@SoLuong int,@DonGia float, @ThanhTien float
as
begin
	insert into CHITIETPN(MaPhieu,MaSP,SoLuongNhap,DonGiaNhap,ThanhTien)
	values (@MaPhieu,@MaSP,@SoLuong,@DonGia, @ThanhTien)
end

exec insertCTPhieuNhap 34,41,100,20000


----------------------*************************** FUNCTION ****************************--------------------------
--1.Tính tổng tất cả đơn hàng
CREATE FUNCTION TongDonHang()
RETURNS INT
AS
	BEGIN
		DECLARE @count INT
		Select @count = COUNT(*) FROM HOADON
		RETURN @count
	END

 select  dbo.TongDonHang() 

--2.Tính tổng đơn hàng ngày hôm nay
create function TongDonHangHomNay()
returns int
as
	begin
		declare @count int
		declare @dayNow date
		set @dayNow = getdate()
		select @count = Count(*) from HOADON where NgayXuatHD = @dayNow
		return @count
	end

select dbo.TongDonHangHomNay()

--3. Tính tổng doanh thu
create function TongDoanhThu()
returns float
as
	begin 
		declare @sumMoney float
		select @sumMoney = sum(TongTien) from HOADON
		return @sumMoney
	end

select dbo.TongDoanhThu()

--4. Đếm số lượng  nhân viên
create function DemSoNhanVien()
returns int
as
	begin 
		declare @count int
		select @count = COUNT(*) from NHANVIEN where CHUCVU =N'Nhân Viên'
		return @count
	end

select dbo.DemSoNhanVien()

--5 Đếm số lượng khách hàng
create function DemSoKhachHang()
returns int
as
	begin 
		declare @count int
		select @count = COUNT(*) from KHACHHANG 
		return @count
	end

--6 Đếm số lượng sản phẩm
create function DemSoLuongSP()
returns int
as
	begin 
		declare @count int
		select @count = COUNT(*) from SANPHAM 
		return @count
	end
--7 Đếm số lượng sản phẩm sắp hết hàng
create function DemSoLuongSPSapHetHang()
returns int
as
	begin
		declare @count int
		select @count = COUNT(*) from SANPHAM where TrangThai =N'Sắp hết hàng'
		return @count
	end

--//////////////////// DOANH THU ///////////////
-- DOANH THU THEO THÁNG
CREATE PROC GET_DOANHTHUTHEOTHANG
@nam int
AS
 BEGIN 
	select MONTH(HOADON.NgayXuatHD) as Thang, YEAR(HOADON.NgayXuatHD) as Nam, SUM(HOADON.TongTien) as DT from HOADON where  YEAR(NgayXuatHD)=@nam
	group by MONTH(HOADON.NgayXuatHD),YEAR(HOADON.NgayXuatHD)
 END

 --- DOANH THU THEO NGAY
CREATE PROC GET_DOANHTHUTHEONGAY
@thang int,
@nam int
AS
 BEGIN 
	select  DAY(HOADON.NgayXuatHD) as Ngay, MONTH(HOADON.NgayXuatHD) as Thang, YEAR(HOADON.NgayXuatHD) as Nam, SUM(HOADON.TongTien) as DT from HOADON where  MONTH(NgayXuatHD)=@thang and YEAR(NgayXuatHD)=@nam
	group by DAY(HOADON.NgayXuatHD),MONTH(HOADON.NgayXuatHD),YEAR(HOADON.NgayXuatHD)
 END
 
  EXEC GET_DOANHTHUTHEONGAY 11,2023
--- GET DOANH THU (XUẤT EXECL)
CREATE PROC GET_DOANHTHU
AS
	BEGIN
		SELECT  NHANVIEN.TenNV as N' Tên NV',NHANVIEN.ChucVu as N'Chức Vụ',NgayXuatHD as N'Ngày Bán',TongTien N'Tổng Tiền' FROM HOADON,NHANVIEN WHERE NHANVIEN.MaNV=HOADON.MaNV
	END

