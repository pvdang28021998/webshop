USE [master]
GO
/****** Object:  Database [SnackShopDB]    Script Date: 3/20/2021 8:27:30 PM ******/
CREATE DATABASE [SnackShopDB]

GO
ALTER DATABASE [SnackShopDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SnackShopDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SnackShopDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SnackShopDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SnackShopDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [SnackShopDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SnackShopDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SnackShopDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SnackShopDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SnackShopDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SnackShopDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SnackShopDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SnackShopDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SnackShopDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SnackShopDB] SET  ENABLE_BROKER 
GO
ALTER DATABASE [SnackShopDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SnackShopDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SnackShopDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SnackShopDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SnackShopDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SnackShopDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SnackShopDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [SnackShopDB] SET RECOVERY FULL 
GO
ALTER DATABASE [SnackShopDB] SET  MULTI_USER 
GO
ALTER DATABASE [SnackShopDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SnackShopDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [SnackShopDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [SnackShopDB] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE [SnackShopDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [SnackShopDB] SET QUERY_STORE = OFF
GO
USE [SnackShopDB]
GO
/****** Object:  UserDefinedFunction [dbo].[DoanhThu]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

--10 thống kê danh sách các mặt hàng bán hôm '12/24/2019' và doanh thu của chúng
	create function [dbo].[DoanhThu](@date date)
	 returns @tk Table (		
		Ten_Hang nvarchar(50),
		Doanh_Thu int
	) AS
	begin
		insert into @tk(
			Ten_Hang,
			Doanh_Thu )
		select TenHang, sum(Lai_theo_LO.Tong_Lai) as Doanh_Thu from 
			(select Lai_theo_GiaNhap.MaLoHang, Lai_theo_GiaNhap.MaHang, Lai_theo_GiaNhap.TenHang, sum(Lai_theo_GiaNhap.Lai) as Tong_Lai from 
				(select LoHang.MaLoHang, MatHang.MaHang, MatHang.TenHang, sum(DongHoaDon.SoLuong)*MatHang.DonGia as Lai  from MatHang, LoHang, DongHoaDon, HoaDon 
					where MatHang.MaHang=LoHang. MaHang and LoHang.MaLoHang= DongHoaDon.MaLoHang  and DongHoaDon.MaHD = HoaDon.MaHD and
						@date = CONVERT(date, HoaDon.ThoiGian)
					Group by LoHang.MaLoHang, MatHang.DonGia, MatHang.MaHang, MatHang.TenHang
				) 
				as Lai_theo_GiaNhap
				group by Lai_theo_GiaNhap.MaLoHang, Lai_theo_GiaNhap.MaHang, Lai_theo_GiaNhap.TenHang
			)
		as Lai_theo_LO
		group by MaHang, TenHang
		--order by Doanh_Thu DESC			
		return
	end

GO
/****** Object:  UserDefinedFunction [dbo].[ThongKe]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

 -- 9 thống kê mức độ bán chạy của các mặt hàng trong từng khoảng thời giam

		create function [dbo].[ThongKe](@start date, @end date)
		returns @tk Table (		
			TenHang nvarchar(50),
			daban int
		) AS
		begin
			insert into @tk(
				TenHang,
				daban )
			select MatHang.TenHang, sum(sumLo) from MatHang, 
					(select LoHang.MaLoHang, MaHang, sum(DongHoaDon.SoLuong) as sumLo from LoHang 
					inner join DongHoaDon on LoHang.MaLoHang = DongHoaDon.MaLoHang
					inner join HoaDon on DongHoaDon.MaHD = HoaDon.MaHD and HoaDon.ThoiGian between @start and @end
					group by LoHang.MaLoHang, MaHang
					) 
			as AsTongLo
			where MatHang.MaHang = AsTongLo.MaHang
			group by MatHang.MaHang, MatHang.TenHang
				
		return
	end

GO
/****** Object:  Table [dbo].[Bill]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Bill](
	[id_bill] [int] IDENTITY(1,1) NOT NULL,
	[subtotal] [decimal](12, 0) NULL,
	[total] [decimal](12, 0) NULL,
	[creatDate] [datetime] NULL,
	[id_customer] [int] NULL,
	[discountCode] [varchar](20) NULL,
	[discount] [decimal](12, 0) NULL,
	[address] [nvarchar](500) NULL,
	[phone] [char](10) NULL,
	[id_status] [int] NULL,
 CONSTRAINT [PK_Bill] PRIMARY KEY CLUSTERED 
(
	[id_bill] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillDetail]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillDetail](
	[id_bill] [int] NOT NULL,
	[id_product] [int] NOT NULL,
	[price] [decimal](10, 0) NULL,
	[amount] [int] NULL,
	[intoMoney] [decimal](12, 0) NULL,
	[discriptionProductDetail] [nvarchar](max) NULL,
 CONSTRAINT [PK_BillDetail] PRIMARY KEY CLUSTERED 
(
	[id_bill] ASC,
	[id_product] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[BillStatus]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BillStatus](
	[id_status] [int] IDENTITY(1,1) NOT NULL,
	[status] [nvarchar](50) NULL,
 CONSTRAINT [PK_BillStatus] PRIMARY KEY CLUSTERED 
(
	[id_status] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Cart]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Cart](
	[id_cart] [int] IDENTITY(1,1) NOT NULL,
	[subtotal] [decimal](12, 0) NULL,
	[total] [decimal](12, 0) NULL,
	[id_discountCode] [varchar](20) NULL,
	[id_customer] [int] NULL,
 CONSTRAINT [PK_Cart] PRIMARY KEY CLUSTERED 
(
	[id_cart] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[CartDetail]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CartDetail](
	[id_cart] [int] NOT NULL,
	[id_product] [int] NOT NULL,
	[price] [decimal](10, 0) NULL,
	[amount] [int] NULL,
	[intoMoney] [decimal](12, 0) NULL,
	[discriptionProductDetail] [nvarchar](max) NULL,
 CONSTRAINT [PK_CartDetail_1] PRIMARY KEY CLUSTERED 
(
	[id_cart] ASC,
	[id_product] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Category]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Category](
	[id_category] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](200) NULL,
	[photo] [varchar](100) NULL,
 CONSTRAINT [PK_Category] PRIMARY KEY CLUSTERED 
(
	[id_category] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Credential]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Credential](
	[id_role] [varchar](50) NOT NULL,
	[id_userGroup] [varchar](20) NOT NULL,
	[expire] [datetime] NULL,
 CONSTRAINT [PK_Credential] PRIMARY KEY CLUSTERED 
(
	[id_role] ASC,
	[id_userGroup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Customer]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Customer](
	[id_customer] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](50) NULL,
	[phone] [char](10) NULL,
	[address] [nvarchar](200) NULL,
	[userName] [varchar](50) NOT NULL,
	[password] [varchar](50) NOT NULL,
	[subtotalCart] [decimal](12, 0) NULL,
	[totalCart] [decimal](12, 0) NULL,
	[avatar] [varchar](100) NULL,
	[id_discountCode] [varchar](20) NULL,
	[createDate] [datetime] NULL,
 CONSTRAINT [PK_Customer] PRIMARY KEY CLUSTERED 
(
	[id_customer] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DiscountCode]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DiscountCode](
	[id_discountCode] [varchar](20) NOT NULL,
	[discount] [decimal](12, 0) NULL,
 CONSTRAINT [PK_DiscountCode] PRIMARY KEY CLUSTERED 
(
	[id_discountCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Product]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Product](
	[id_product] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](200) NULL,
	[description] [nvarchar](max) NULL,
	[information] [nvarchar](max) NULL,
	[review] [nvarchar](max) NULL,
	[view] [int] NULL,
	[availability] [bit] NOT NULL,
	[price] [decimal](10, 0) NULL,
	[salePercent] [int] NULL,
	[salePrice] [decimal](10, 0) NULL,
	[rate] [float] NULL,
	[mainPhoto] [varchar](100) NULL,
	[photo1] [varchar](100) NULL,
	[photo2] [varchar](100) NULL,
	[photo3] [varchar](100) NULL,
	[photo4] [varchar](100) NULL,
	[updated] [date] NULL,
	[id_category] [int] NULL,
 CONSTRAINT [PK_Product] PRIMARY KEY CLUSTERED 
(
	[id_product] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ProductDetail]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ProductDetail](
	[id_productDetail] [int] IDENTITY(1,1) NOT NULL,
	[name] [nvarchar](200) NULL,
	[amount] [int] NULL,
	[availability] [bit] NOT NULL,
	[extraPrice] [decimal](10, 0) NULL,
	[id_product] [int] NULL,
 CONSTRAINT [PK_ProductDetail] PRIMARY KEY CLUSTERED 
(
	[id_productDetail] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Role]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Role](
	[id_role] [varchar](50) NOT NULL,
	[name] [nvarchar](50) NULL,
 CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED 
(
	[id_role] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[User]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[User](
	[id_user] [int] IDENTITY(1,1) NOT NULL,
	[userName] [varchar](50) NOT NULL,
	[password] [varchar](50) NOT NULL,
	[name] [nvarchar](50) NULL,
	[email] [varchar](50) NULL,
	[status] [bit] NULL,
	[createDate] [datetime] NULL,
	[id_userGroup] [varchar](20) NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
(
	[id_user] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserGroup]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserGroup](
	[id_userGroup] [varchar](20) NOT NULL,
	[name] [nvarchar](50) NULL,
 CONSTRAINT [PK_UserGroup] PRIMARY KEY CLUSTERED 
(
	[id_userGroup] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[Bill] ON 

INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (36, CAST(265000 AS Decimal(12, 0)), CAST(1235000 AS Decimal(12, 0)), CAST(N'2020-07-03T09:10:38.683' AS DateTime), 2, N'10', CAST(50000 AS Decimal(12, 0)), N'HN', N'1111      ', 4)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (37, CAST(265000 AS Decimal(12, 0)), CAST(1235000 AS Decimal(12, 0)), CAST(N'2020-07-03T09:10:51.750' AS DateTime), 2, N'20', CAST(50000 AS Decimal(12, 0)), N'HD', N'2222      ', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (38, CAST(265000 AS Decimal(12, 0)), CAST(1235000 AS Decimal(12, 0)), CAST(N'2020-07-03T09:11:11.200' AS DateTime), 2, N'30', CAST(50000 AS Decimal(12, 0)), N'HY', N'3333      ', 4)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (39, CAST(265000 AS Decimal(12, 0)), CAST(1235000 AS Decimal(12, 0)), CAST(N'2020-07-03T09:11:12.027' AS DateTime), 2, N'30', CAST(50000 AS Decimal(12, 0)), N'HY', N'3333      ', 4)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (40, CAST(265000 AS Decimal(12, 0)), CAST(1235000 AS Decimal(12, 0)), CAST(N'2020-07-03T09:11:18.780' AS DateTime), 2, N'40', CAST(50000 AS Decimal(12, 0)), N'HY', N'3333      ', 2)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (41, CAST(265000 AS Decimal(12, 0)), CAST(1235000 AS Decimal(12, 0)), CAST(N'2020-07-03T09:11:22.830' AS DateTime), 2, N'40', CAST(50000 AS Decimal(12, 0)), N'HY', N'5555      ', 2)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (42, CAST(265000 AS Decimal(12, 0)), CAST(1235000 AS Decimal(12, 0)), CAST(N'2020-07-03T09:11:49.897' AS DateTime), 1, N'40', CAST(50000 AS Decimal(12, 0)), N'HY', N'5555      ', 2)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (43, CAST(265000 AS Decimal(12, 0)), CAST(1235000 AS Decimal(12, 0)), CAST(N'2020-07-03T09:12:32.647' AS DateTime), 1, N'40', CAST(50000 AS Decimal(12, 0)), N'HY', N'5555      ', 2)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (44, CAST(265000 AS Decimal(12, 0)), CAST(1235000 AS Decimal(12, 0)), CAST(N'2020-07-03T09:12:42.280' AS DateTime), 2, N'40', CAST(50000 AS Decimal(12, 0)), N'HY', N'5555      ', 3)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (45, CAST(79000 AS Decimal(12, 0)), CAST(79000 AS Decimal(12, 0)), CAST(N'2020-07-20T17:05:04.807' AS DateTime), 2, NULL, NULL, N'Thanh Thủy, Thanh Liêm, Hà Nam', N'0815396662', 3)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (46, CAST(79000 AS Decimal(12, 0)), CAST(79000 AS Decimal(12, 0)), CAST(N'2020-07-20T17:07:30.257' AS DateTime), 2, NULL, NULL, N'117 Trần Cung', N'0322220125', 3)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (47, CAST(158000 AS Decimal(12, 0)), CAST(138000 AS Decimal(12, 0)), CAST(N'2020-07-20T18:09:09.877' AS DateTime), 2, N'0120110026', CAST(20000 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 3)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (48, CAST(328000 AS Decimal(12, 0)), CAST(328000 AS Decimal(12, 0)), CAST(N'2020-07-21T17:51:45.153' AS DateTime), 1, N'', CAST(0 AS Decimal(12, 0)), N'230 Nguyễn Văn Giáp', N'0328887832', 3)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (49, CAST(849000 AS Decimal(12, 0)), CAST(849000 AS Decimal(12, 0)), CAST(N'2020-07-21T18:07:03.517' AS DateTime), 9, N'', CAST(0 AS Decimal(12, 0)), N'1 Nguyễn Cơ Thạch', N'0358884512', 3)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (50, CAST(849000 AS Decimal(12, 0)), CAST(849000 AS Decimal(12, 0)), CAST(N'2020-07-21T18:08:13.127' AS DateTime), 9, N'', CAST(0 AS Decimal(12, 0)), N'1 Nguyễn Cơ Thạch', N'0358884512', 4)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (51, CAST(237000 AS Decimal(12, 0)), CAST(237000 AS Decimal(12, 0)), CAST(N'2020-07-21T18:13:42.967' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'http://192.168.1.43:8083/CustomerLogin/Index', N'0322220125', 4)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (52, CAST(237000 AS Decimal(12, 0)), CAST(237000 AS Decimal(12, 0)), CAST(N'2020-07-21T18:14:45.903' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 5)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (53, CAST(158000 AS Decimal(12, 0)), CAST(158000 AS Decimal(12, 0)), CAST(N'2020-07-21T18:15:50.113' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 6)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (54, CAST(158000 AS Decimal(12, 0)), CAST(158000 AS Decimal(12, 0)), CAST(N'2020-07-21T18:16:14.077' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 6)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (55, CAST(95000 AS Decimal(12, 0)), CAST(95000 AS Decimal(12, 0)), CAST(N'2020-07-23T09:46:05.257' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 6)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (56, CAST(185000 AS Decimal(12, 0)), CAST(185000 AS Decimal(12, 0)), CAST(N'2020-07-23T09:48:25.653' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 6)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (57, CAST(79000 AS Decimal(12, 0)), CAST(79000 AS Decimal(12, 0)), CAST(N'2020-07-23T09:49:57.567' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (58, CAST(79000 AS Decimal(12, 0)), CAST(79000 AS Decimal(12, 0)), CAST(N'2020-07-23T09:50:58.950' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (59, CAST(79000 AS Decimal(12, 0)), CAST(79000 AS Decimal(12, 0)), CAST(N'2020-07-23T09:55:53.077' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (60, CAST(39000 AS Decimal(12, 0)), CAST(39000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:22:56.517' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (61, CAST(39000 AS Decimal(12, 0)), CAST(39000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:24:10.330' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (62, CAST(185000 AS Decimal(12, 0)), CAST(185000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:31:57.630' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (63, CAST(454000 AS Decimal(12, 0)), CAST(454000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:33:31.627' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (64, CAST(454000 AS Decimal(12, 0)), CAST(454000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:33:51.453' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (65, CAST(94000 AS Decimal(12, 0)), CAST(94000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:38:14.683' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (66, CAST(158000 AS Decimal(12, 0)), CAST(158000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:39:00.467' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (67, CAST(79000 AS Decimal(12, 0)), CAST(79000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:44:32.040' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (68, CAST(94000 AS Decimal(12, 0)), CAST(94000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:56:23.630' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (69, CAST(94000 AS Decimal(12, 0)), CAST(94000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:56:45.213' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (70, CAST(94000 AS Decimal(12, 0)), CAST(94000 AS Decimal(12, 0)), CAST(N'2020-07-23T10:57:03.157' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (73, CAST(255000 AS Decimal(12, 0)), CAST(255000 AS Decimal(12, 0)), CAST(N'2020-07-23T11:30:23.797' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (77, CAST(494000 AS Decimal(12, 0)), CAST(474000 AS Decimal(12, 0)), CAST(N'2020-07-26T17:30:12.877' AS DateTime), 2, N'1201445202', CAST(20000 AS Decimal(12, 0)), N'Thanh Thủy, Thanh Liêm, Hà Nam', N'0815396662', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (78, CAST(158000 AS Decimal(12, 0)), CAST(158000 AS Decimal(12, 0)), CAST(N'2020-07-27T08:18:21.983' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (79, CAST(158000 AS Decimal(12, 0)), CAST(158000 AS Decimal(12, 0)), CAST(N'2020-07-27T08:19:02.667' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (80, CAST(158000 AS Decimal(12, 0)), CAST(158000 AS Decimal(12, 0)), CAST(N'2020-07-27T08:19:18.777' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (81, CAST(158000 AS Decimal(12, 0)), CAST(158000 AS Decimal(12, 0)), CAST(N'2020-07-27T08:21:14.110' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (82, CAST(237000 AS Decimal(12, 0)), CAST(237000 AS Decimal(12, 0)), CAST(N'2020-07-27T08:23:01.240' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (83, CAST(316000 AS Decimal(12, 0)), CAST(316000 AS Decimal(12, 0)), CAST(N'2020-07-27T08:29:34.490' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (84, CAST(136000 AS Decimal(12, 0)), CAST(136000 AS Decimal(12, 0)), CAST(N'2020-07-27T10:05:26.467' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (86, CAST(329600 AS Decimal(12, 0)), CAST(329600 AS Decimal(12, 0)), CAST(N'2020-07-30T20:00:12.010' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (87, CAST(12000 AS Decimal(12, 0)), CAST(12000 AS Decimal(12, 0)), CAST(N'2020-07-31T16:27:14.143' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'15 nghĩa tân, cầu giấy, hn', N'0993382733', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1088, CAST(131200 AS Decimal(12, 0)), CAST(131200 AS Decimal(12, 0)), CAST(N'2020-10-20T22:26:06.393' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0369520662', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1089, CAST(136000 AS Decimal(12, 0)), CAST(136000 AS Decimal(12, 0)), CAST(N'2020-10-20T22:33:32.630' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0396520662', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1090, CAST(178000 AS Decimal(12, 0)), CAST(178000 AS Decimal(12, 0)), CAST(N'2020-10-20T22:36:33.207' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1091, CAST(152000 AS Decimal(12, 0)), CAST(152000 AS Decimal(12, 0)), CAST(N'2020-10-20T22:38:07.100' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0845228466', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1092, CAST(378000 AS Decimal(12, 0)), CAST(378000 AS Decimal(12, 0)), CAST(N'2020-10-20T22:50:22.130' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1093, CAST(282000 AS Decimal(12, 0)), CAST(282000 AS Decimal(12, 0)), CAST(N'2020-10-20T22:53:33.823' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1094, CAST(103200 AS Decimal(12, 0)), CAST(103200 AS Decimal(12, 0)), CAST(N'2020-10-20T22:57:32.263' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 2)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1095, CAST(148000 AS Decimal(12, 0)), CAST(148000 AS Decimal(12, 0)), CAST(N'2020-10-20T23:00:13.343' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 2)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1096, CAST(388400 AS Decimal(12, 0)), CAST(388400 AS Decimal(12, 0)), CAST(N'2021-03-09T15:30:38.530' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1097, CAST(142400 AS Decimal(12, 0)), CAST(142400 AS Decimal(12, 0)), CAST(N'2021-03-15T23:27:29.200' AS DateTime), 6, N'', CAST(0 AS Decimal(12, 0)), N'21 Nguyễn Trãi', N'0034425501', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1098, CAST(68000 AS Decimal(12, 0)), CAST(68000 AS Decimal(12, 0)), CAST(N'2021-03-16T00:03:03.917' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1099, CAST(178400 AS Decimal(12, 0)), CAST(178400 AS Decimal(12, 0)), CAST(N'2021-03-16T00:06:08.667' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1100, CAST(123200 AS Decimal(12, 0)), CAST(123200 AS Decimal(12, 0)), CAST(N'2021-03-16T00:07:39.490' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1101, CAST(123200 AS Decimal(12, 0)), CAST(123200 AS Decimal(12, 0)), CAST(N'2021-03-16T00:13:39.997' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1102, CAST(265600 AS Decimal(12, 0)), CAST(265600 AS Decimal(12, 0)), CAST(N'2021-03-16T00:20:27.703' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'36 ngõ 112 Trần Cung, Cổ Nhuế 1, Bắc Từ Liêm, Hà Nội', N'0322220125', 1)
INSERT [dbo].[Bill] ([id_bill], [subtotal], [total], [creatDate], [id_customer], [discountCode], [discount], [address], [phone], [id_status]) VALUES (1103, CAST(265600 AS Decimal(12, 0)), CAST(265600 AS Decimal(12, 0)), CAST(N'2021-03-16T00:22:03.727' AS DateTime), 2, N'', CAST(0 AS Decimal(12, 0)), N'117 Trần Cung', N'0322220125', 1)
SET IDENTITY_INSERT [dbo].[Bill] OFF
GO
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (39, 4, CAST(250 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (39, 20, CAST(250 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (39, 21, CAST(250 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (39, 22, CAST(250 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (39, 23, CAST(250 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (39, 24, CAST(250 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (39, 25, CAST(250 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (39, 26, CAST(250 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (39, 27, CAST(250 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (41, 4, CAST(2000 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (42, 4, CAST(2000 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (44, 4, CAST(2000 AS Decimal(10, 0)), 2, CAST(400 AS Decimal(12, 0)), N'none')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (45, 1, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (47, 1, CAST(79000 AS Decimal(10, 0)), 2, CAST(158000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (48, 1, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (48, 2, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (49, 1, CAST(79000 AS Decimal(10, 0)), 9, CAST(711000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (50, 1, CAST(79000 AS Decimal(10, 0)), 9, CAST(711000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (51, 1, CAST(79000 AS Decimal(10, 0)), 3, CAST(237000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (52, 1, CAST(79000 AS Decimal(10, 0)), 3, CAST(237000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (53, 1, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (53, 2, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (54, 1, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (54, 2, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (57, 2, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (58, 2, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (59, 2, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (60, 30, CAST(39000 AS Decimal(10, 0)), 1, CAST(39000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (61, 30, CAST(39000 AS Decimal(10, 0)), 1, CAST(39000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (62, 11, CAST(185000 AS Decimal(10, 0)), 1, CAST(185000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (63, 7, CAST(95000 AS Decimal(10, 0)), 1, CAST(95000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (63, 15, CAST(359000 AS Decimal(10, 0)), 1, CAST(359000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (64, 7, CAST(95000 AS Decimal(10, 0)), 1, CAST(95000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (64, 15, CAST(359000 AS Decimal(10, 0)), 1, CAST(359000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (65, 27, CAST(94000 AS Decimal(10, 0)), 1, CAST(94000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (66, 2, CAST(79000 AS Decimal(10, 0)), 2, CAST(158000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (67, 1, CAST(79000 AS Decimal(10, 0)), 1, CAST(79000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (68, 27, CAST(94000 AS Decimal(10, 0)), 1, CAST(94000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (69, 27, CAST(94000 AS Decimal(10, 0)), 1, CAST(94000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (70, 27, CAST(94000 AS Decimal(10, 0)), 1, CAST(94000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (73, 3, CAST(85000 AS Decimal(10, 0)), 3, CAST(255000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (77, 14, CAST(359000 AS Decimal(10, 0)), 1, CAST(359000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (77, 71, CAST(27000 AS Decimal(10, 0)), 5, CAST(135000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (78, 2, CAST(79000 AS Decimal(10, 0)), 2, CAST(158000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (79, 2, CAST(79000 AS Decimal(10, 0)), 2, CAST(158000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (80, 2, CAST(79000 AS Decimal(10, 0)), 2, CAST(158000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (81, 2, CAST(79000 AS Decimal(10, 0)), 2, CAST(158000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (82, 1, CAST(79000 AS Decimal(10, 0)), 3, CAST(237000 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (83, 2, CAST(79000 AS Decimal(10, 0)), 4, CAST(316000 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (84, 3, CAST(68000 AS Decimal(10, 0)), 2, CAST(136000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (86, 1, CAST(63200 AS Decimal(10, 0)), 2, CAST(126400 AS Decimal(12, 0)), N'1 7up lon
1 coca lon
1 pepsi lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (86, 5, CAST(55200 AS Decimal(10, 0)), 1, CAST(55200 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (86, 11, CAST(148000 AS Decimal(10, 0)), 1, CAST(148000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (87, 76, CAST(12000 AS Decimal(10, 0)), 1, CAST(12000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1088, 7, CAST(76000 AS Decimal(10, 0)), 1, CAST(76000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1089, 3, CAST(68000 AS Decimal(10, 0)), 2, CAST(136000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1090, 4, CAST(89000 AS Decimal(10, 0)), 2, CAST(178000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1091, 7, CAST(76000 AS Decimal(10, 0)), 2, CAST(152000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1092, 18, CAST(189000 AS Decimal(10, 0)), 2, CAST(378000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1093, 27, CAST(94000 AS Decimal(10, 0)), 3, CAST(282000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1094, 8, CAST(103200 AS Decimal(10, 0)), 1, CAST(103200 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1095, 11, CAST(148000 AS Decimal(10, 0)), 1, CAST(148000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1096, 2, CAST(63200 AS Decimal(10, 0)), 2, CAST(126400 AS Decimal(12, 0)), N'3 miếng hot wiings
1 khoai tây chiên (lớn)
1 pepsi lon
1 pepsi lon
1 coca lon
')
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1097, 6, CAST(71200 AS Decimal(10, 0)), 2, CAST(142400 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1098, 3, CAST(68000 AS Decimal(10, 0)), 1, CAST(68000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1099, 3, CAST(68000 AS Decimal(10, 0)), 1, CAST(68000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1100, 3, CAST(68000 AS Decimal(10, 0)), 1, CAST(68000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1101, 3, CAST(68000 AS Decimal(10, 0)), 1, CAST(68000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1101, 5, CAST(55200 AS Decimal(10, 0)), 1, CAST(55200 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1102, 3, CAST(68000 AS Decimal(10, 0)), 1, CAST(68000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1102, 5, CAST(55200 AS Decimal(10, 0)), 1, CAST(55200 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1102, 6, CAST(71200 AS Decimal(10, 0)), 2, CAST(142400 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1103, 3, CAST(68000 AS Decimal(10, 0)), 1, CAST(68000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1103, 5, CAST(55200 AS Decimal(10, 0)), 1, CAST(55200 AS Decimal(12, 0)), NULL)
INSERT [dbo].[BillDetail] ([id_bill], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1103, 6, CAST(71200 AS Decimal(10, 0)), 2, CAST(142400 AS Decimal(12, 0)), NULL)
GO
SET IDENTITY_INSERT [dbo].[BillStatus] ON 

INSERT [dbo].[BillStatus] ([id_status], [status]) VALUES (1, N'Chờ xác nhận')
INSERT [dbo].[BillStatus] ([id_status], [status]) VALUES (2, N'Chờ lấy hàng')
INSERT [dbo].[BillStatus] ([id_status], [status]) VALUES (3, N'Đang giao')
INSERT [dbo].[BillStatus] ([id_status], [status]) VALUES (4, N'Đã giao')
INSERT [dbo].[BillStatus] ([id_status], [status]) VALUES (5, N'Đã hủy')
INSERT [dbo].[BillStatus] ([id_status], [status]) VALUES (6, N'Trả hàng')
SET IDENTITY_INSERT [dbo].[BillStatus] OFF
GO
SET IDENTITY_INSERT [dbo].[Cart] ON 

INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (1, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'', 1)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (2, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 2)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (3, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 3)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (4, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 4)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (5, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 5)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (6, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 6)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (7, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 7)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (8, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 8)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (9, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 9)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (10, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 10)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (11, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 11)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (12, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 12)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (13, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, 13)
INSERT [dbo].[Cart] ([id_cart], [subtotal], [total], [id_discountCode], [id_customer]) VALUES (14, CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL)
SET IDENTITY_INSERT [dbo].[Cart] OFF
GO
INSERT [dbo].[CartDetail] ([id_cart], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (1, 4, CAST(89000 AS Decimal(10, 0)), 2, CAST(178000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[CartDetail] ([id_cart], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (2, 3, CAST(68000 AS Decimal(10, 0)), 1, CAST(68000 AS Decimal(12, 0)), NULL)
INSERT [dbo].[CartDetail] ([id_cart], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (2, 5, CAST(55200 AS Decimal(10, 0)), 1, CAST(55200 AS Decimal(12, 0)), NULL)
INSERT [dbo].[CartDetail] ([id_cart], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (2, 6, CAST(71200 AS Decimal(10, 0)), 2, CAST(142400 AS Decimal(12, 0)), NULL)
INSERT [dbo].[CartDetail] ([id_cart], [id_product], [price], [amount], [intoMoney], [discriptionProductDetail]) VALUES (6, 6, CAST(71200 AS Decimal(10, 0)), 1, CAST(71200 AS Decimal(12, 0)), NULL)
GO
SET IDENTITY_INSERT [dbo].[Category] ON 

INSERT [dbo].[Category] ([id_category], [name], [photo]) VALUES (1, N'Pizza 1 người', N'ctgr_3132021_photo.png')
INSERT [dbo].[Category] ([id_category], [name], [photo]) VALUES (2, N'Pizza nhóm', N'c15.jpg')
INSERT [dbo].[Category] ([id_category], [name], [photo]) VALUES (3, N'Pizza thượng hạn', N'sp18.png')
INSERT [dbo].[Category] ([id_category], [name], [photo]) VALUES (5, N'Pizza sang chảnh', N's19.jpg')
INSERT [dbo].[Category] ([id_category], [name], [photo]) VALUES (6, N'Thức ăn nhẹ', N's35.jpg')
INSERT [dbo].[Category] ([id_category], [name], [photo]) VALUES (7, N'Tráng miệng', N'ctgr_3132021_photo.png')
INSERT [dbo].[Category] ([id_category], [name], [photo]) VALUES (8, N'Đồ uống', N'ctgr_3132021_photo.jpg')
SET IDENTITY_INSERT [dbo].[Category] OFF
GO
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'ADD_CATEGORY', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'ADD_CATEGORY', N'SALE', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'ADD_CUSTOMER', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'ADD_DISCOUNTCODE', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'ADD_PRODUCT', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'ADD_PRODUCT', N'SALE', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'ADD_USER', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'ADD_USER', N'MEMBER', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'CHANGE_STATUS_BILL', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'CHANGE_STATUS_BILL', N'SALE', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'DELETE_BILL', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'DELETE_BILL', N'SALE', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'DELETE_CATEGORY', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'DELETE_CUSTOMER', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'DELETE_PRODUCT', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'DELETE_PRODUCT', N'SALE', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'DELETE_USER', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'DELETE_USER', N'MEMBER', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'EDIT_CATEGORY', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'EDIT_CUSTOMER', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'EDIT_DISCOUNTCODE', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'EDIT_PRODUCT', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'EDIT_PRODUCT', N'SALE', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'EDIT_USER', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'EDIT_USER', N'MEMBER', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'VIEW_BILL', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'VIEW_BILL', N'SALE', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'VIEW_CATEGORY', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'VIEW_CUSTOMER', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'VIEW_DISCOUNTCODE', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'VIEW_PRODUCT', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'VIEW_USER', N'ADMIN', NULL)
INSERT [dbo].[Credential] ([id_role], [id_userGroup], [expire]) VALUES (N'VIEW_USER', N'MEMBER', NULL)
GO
SET IDENTITY_INSERT [dbo].[Customer] ON 

INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1, N'Nguyễn Đức Hưng', N'0328887832', N'230 Nguyễn Văn Giáp', N'ndhung', N'0000', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'ctm_3132021_avatar.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (2, N'Vũ Minh Hiếu', N'0322220125', N'117 Trần Cung', N'vmhieu', N'0000', NULL, NULL, N'kh2.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (3, N'Nguyễn Hữu Tiến', N'0352220122', N'231 Trần Cung', N'nhtien', N'0000', NULL, NULL, N'kh3.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (4, N'Phùng Văn Trường', N'0201125038', N'23 Nguyễn Khánh Toàn', N'pvtruong', N'0000', NULL, NULL, N'kh4.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (5, N'Cao Văn Huy', N'0320015246', N'17 Trần Khánh Dư', N'cvhuy', N'0000', NULL, NULL, N'kh5.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (6, N'Tạ Hữu Sơn', N'0034425501', N'21 Nguyễn Trãi', N'thson', N'0000', NULL, NULL, N'kh6.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (7, N'Lã Minh Đức', N'0750015896', N'110 Kim Mã', N'lmduc', N'0000', NULL, NULL, N'ctm_3142021_avatar.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (8, N'Lâm Đức Hoàng', N'0322220125', N'187 Hồ Tùng Mậu', N'ldhoang', N'0000', NULL, NULL, N'ctm_3142021_avatar.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (9, N'Phạm Văn Dáng', N'0358884512', N'1 Nguyễn Cơ Thạch', N'pvdang', N'0000', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'kh9.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (10, N'Trần Đức Dũng', N'0520012310', N'224 Láng', N'tddung', N'0000', NULL, NULL, N'kh10.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (11, N'Vũ Thị Hải Yến', N'0374657937', N'62 Văn Hội', N'vthaiyen', N'0000', NULL, NULL, N'kh11.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (12, N'Nguyễn Thị Thuỳ Linh', N'0322201110', N'100 Cổ Nhuế', N'ntthuylinh', N'0000', NULL, NULL, N'kh12.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (13, N'Lê Thị Ngọc', N'0360012547', N'231 Phùng Chí Kiên', N'ltngoc', N'0000', NULL, NULL, N'kh13.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (15, N'Đỗ Thị Nguyệt Mai', N'0250034521', N'117 Khương Đình', N'ndnguyetmai', N'0000', NULL, NULL, N'kh15.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (16, N'Bùi Thị Hạnh', N'0324875942', N'323 Hoàng Hoa Thám', N'bthanh', N'0000', NULL, NULL, N'ctm_3132021_avatar.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (17, N'Hà Ngọc Linh', N'0245687510', N'12 Lê Quang Đạo', N'hnlinh', N'0000', NULL, NULL, N'kh17.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (18, N'Nguyễn Thị Loan', N'0324865120', N'180 Khuất Duy Tiến', N'ntloan', N'0000', NULL, NULL, N'kh18.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (19, N'Ngô Thị Huyền', N'0231457854', N'10 Nguyễn Chí Công', N'nthuyen', N'0000', NULL, NULL, N'kh19.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (20, N'Lê Thị Hương Trang', N'012453201 ', N'222 Lạc Long Quân', N'lthuongtrang', N'0000', NULL, NULL, N'kh20.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (21, N'Đinh Thị Diệu Linh', NULL, NULL, N'linhlinh', N'16091999', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'kh20.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (24, NULL, NULL, NULL, N'hieumta', N'hieu', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (27, N'Được 1', N'123456789 ', N'Hà Nam', N'd1', N'd1', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (28, N'được 3', N'123456789 ', N'Hà Nội', N'd3', N'd3', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (29, N'taolao', N'123456789 ', N'Ha Bac', N'taolao', N'taolao', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (30, N'taothao', N'123       ', N'Nguy', N'taothao', N'taothao', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_30_8122020.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (32, N'duoc', N'123       ', N'124', N'duoc', N'duoc', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (33, N'Có thể', N'1478954236', N'CÓ THỂ', N'ct', N'ct', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (34, N'Có thể', N'1478954236', N'CÓ THỂ', N'ct', N'ct', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (35, N'Có thể', N'1478954236', N'CÓ THỂ', N'ct', N'ct', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (36, N'Có thể', N'1478954236', N'CÓ THỂ', N'ct', N'ct', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (37, N'Có thể', N'1478954236', N'CÓ THỂ', N'ct', N'ct', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (38, N'Có thể', N'1478954236', N'CÓ THỂ', N'ct', N'ct', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (39, N'', N'          ', N'', N'taothao', N'taothao', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (40, N'', N'          ', N'', N'taothao', N'taothao', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (41, N'Trần Quốc Hoàn', N'0245157026', N'', N'Hoan9999', N'1234', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (42, N'sss', N'111       ', N'sss', N'sss', N'sss', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (43, N'zz', N'          ', N'zz', N'zz', N'zz', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_43_8122020', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (44, N'sd', N'          ', N'sd', N'sd', N'sd', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_44_8122020', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (45, N'sd', N'          ', N'sd', N'sd', N'sd', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (46, N'sd', N'          ', N'sd', N'sd', N'sd', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (47, N'asd', N'          ', N'asd', N'asd', N'asd', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_47_8122020', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (48, N'asd', N'          ', N'asd', N'asd', N'asd', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (49, N'dkz', N'          ', N'dkz', N'dkz', N'dkz', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_49_8122020', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (50, N'dkz', N'          ', N'dkz', N'dkz', N'dkz', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (51, N'ddd', N'          ', N'ddd', N'ddd', N'ddd', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_51_8122020', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (52, N'ddd', N'          ', N'ddd', N'ddd', N'ddd', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (53, N'qwe', N'          ', N'qwe', N'qwe', N'qwe', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (54, N'qwe', N'          ', N'qwe', N'qwe', N'qwe', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (63, N'89', N'89        ', N'', N'89', N'89', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (64, N'10', N'10        ', N'10', N'10', N'10', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (65, N'10', NULL, N'10', N'10', N'10', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'ctm_3132021_avatar.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (66, N'20', N'20        ', N'20', N'20', N'20', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (67, N'fh', N'          ', N'fh', N'fh', N'fh', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (68, N'dddd', N'          ', N'dddd', N'dddd', N'dddd', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (69, N'ssss', N'          ', N'ssss', N'ssss', N'ssss', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (70, N'qqq', N'          ', N'qqq', N'qqq', N'qqq', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (71, N'eee', N'          ', N'eee', N'eee', N'eeee', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (72, N'123321', N'123321    ', N'123321', N'123321', N'123321', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (73, N'ty', N'          ', N'ty', N'ty', N'y', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_73_8122020', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (111, N'Finish', N'0887254985', N'Success', N'ok', N'ok012', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_111_8122020.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (112, N'55', N'          ', N'55', N'55', N'55', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_112_8122020.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (113, N'99', N'99        ', N'99', N'99', N'99', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (114, N'88', N'88        ', N'88', N'88', N'88', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (115, N'77', N'77        ', N'77', N'77', N'77', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_115_8122020.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (116, N'qwer', N'          ', N'e', N'w', N'e', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_116_8122020.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (118, N'kkl', N'          ', N'kkl', N'kkl', N'kkl', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (119, N'oop', N'          ', N'oop', N'oop', N'oop', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_119_8122020.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (122, N'gggh', N'5567      ', N'ghjk', N'ughgj', N'678', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'cus_122_8202020.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (123, N'1231234', N'12341234  ', N'12341234', N'12341234', N'12341234', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (125, N'Bé Na', N'0125154264', N'236 hoàng quốc việtttttttt', N'bé na', N'bena', CAST(5 AS Decimal(12, 0)), CAST(5 AS Decimal(12, 0)), N'ctm_9222020_avatar.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (126, N'Nguyễn Đức Hưng', N'0328887832', N'230 Nguyễn Văn Giáp', N'ndhung', N'0000', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'kh1.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (127, N'Nguyễn Đức Hưng', N'0328887832', N'230 Nguyễn Văn Giáp', N'ndhung', N'0000', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'kh1.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (132, N'Nguyễn Đức Hưng', N'0328887832', N'230 Nguyễn Văn Giáp', N'ndhung', N'0000', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'kh1.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (133, N'Nguyễn Đức Hưng', N'0328887832', N'230 Nguyễn Văn Giáp', N'ndhung', N'0000', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'kh1.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (134, N'Nguyễn Đức Hưng', N'0328887832', N'230 Nguyễn Văn Giáp', N'ndhung', N'0000', CAST(0 AS Decimal(12, 0)), CAST(0 AS Decimal(12, 0)), N'kh1.png', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1135, N'tala', N'0123456789', N'Thanh Tâm', N'tala', N'tala', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1136, N'tala', N'0123456789', N'Thanh Tâm', N'tala1', N'tala1', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1137, N'talan', N'022       ', N'Thanh Tâm', N'tala1', N'tala1', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1138, N'talan', N'022       ', N'Thanh Tâm', N'tala1', N'tala1', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1139, N'talan', N'022       ', N'Thanh Tâm', N'tala1', N'tala1', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1142, N'talaExample', N'1924520   ', N'CityLine', N'TalaCity', N'0000', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1143, N'talaExample', N'1924520   ', N'CityLine', N'TalaCity', N'0000', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1144, N'talaExample', N'1924520   ', N'CityLine', N'TalaCity', N'0000', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1145, N'valuate', N'1111      ', N'1111', N'1121', N'1121', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1146, N'valuate', N'1111      ', N'1111', N'1121', N'1121', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1147, N'valuate', N'1111      ', N'1111', N'1121', N'1121', NULL, NULL, NULL, NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
INSERT [dbo].[Customer] ([id_customer], [name], [phone], [address], [userName], [password], [subtotalCart], [totalCart], [avatar], [id_discountCode], [createDate]) VALUES (1154, N'BeNaComeBack', NULL, N'Hà Nam', N'NaOneTop', N'2222', NULL, NULL, N'ctm_1282020_avatar.jpg', NULL, CAST(N'2021-03-10T09:10:38.683' AS DateTime))
SET IDENTITY_INSERT [dbo].[Customer] OFF
GO
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'111', CAST(213 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'123', CAST(123 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'12323', CAST(2424 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'13234', CAST(436 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'143', CAST(6464654 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'2', CAST(2440000 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'2132', CAST(30000 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'222', CAST(21312 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'234', CAST(85678 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'23423', CAST(3465456 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'2345', CAST(2412 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'23452', CAST(2342 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'23523', CAST(23432 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'aa', CAST(245 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'af', CAST(23452345 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'dsfg', CAST(23452345 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'ea', CAST(2435243 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'qe', CAST(57486 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'sdf', CAST(235 AS Decimal(12, 0)))
INSERT [dbo].[DiscountCode] ([id_discountCode], [discount]) VALUES (N'sdg', CAST(5786 AS Decimal(12, 0)))
GO
SET IDENTITY_INSERT [dbo].[Product] ON 

INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (1, N'PIZZA 4 VỊ (BIG 4)', N'2 miếng gà giòn + 1 pepsi lon', NULL, NULL, 31, 1, CAST(79000 AS Decimal(10, 0)), 0, CAST(79000 AS Decimal(10, 0)), 5, N'c1.jpg', N'c1.jpg', N'c1.jpg', N'c1.jpg', N'c1.jpg', CAST(N'2020-08-07' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (2, N'PRIME BEEF - PIZZA BÒ MÊ-HI-CÔ THƯỢNG HẠNG', N'3 miếng hot wings + 1 khoai tây chiên (lớn) + 1 pepsi lon', N'', NULL, 19, 1, CAST(79000 AS Decimal(10, 0)), 20, CAST(63200 AS Decimal(10, 0)), 5, N'c2.jpg', N'c2.jpg', N'c2.jpg', N'c2.jpg', N'c2.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (3, N'PIZZA HẢI SẢN XỐT CAY KIỂU SINGAPORE', N'1 miếng gà giòn cay + 1 burger tôm + 1 pepsi lon', N'', NULL, 8, 1, CAST(85000 AS Decimal(10, 0)), 20, CAST(68000 AS Decimal(10, 0)), 5, N'c3.jpg', N'c3.jpg', N'c3.jpg', N'c3.jpg', N'c3.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (4, N'PIZZA VẸM XANH - MUSSEL PESTO PIZZA', N'1 miếng gà giòn + 1 burger gà quay + 1 pepsi lon', N'', NULL, 2, 1, CAST(89000 AS Decimal(10, 0)), 20, CAST(89000 AS Decimal(10, 0)), 5, N'c4.jpg', N'c4.jpg', N'c4.jpg', N'c4.jpg', N'c4.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (5, N'PIZZAMIN SEA - HẢI SẢN NHIỆT ĐỚI XỐT TIÊU', N'1 cơm gà giòn + 1 súp gà + 1 pepsi lon', N'', NULL, 3, 1, CAST(69000 AS Decimal(10, 0)), 20, CAST(55200 AS Decimal(10, 0)), 5, N'c5.jpg', N'c5.jpg', N'c5.jpg', N'c5.jpg', N'c5.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (6, N'HALF - HALF', N'1 cơm gà giòn + 1 miếng gà giòn + 1 pepsi lon', NULL, NULL, 2, 1, CAST(89000 AS Decimal(10, 0)), 20, CAST(71200 AS Decimal(10, 0)), 5, N'c6.jpg', N'c6.jpg', N'c6.jpg', N'c6.jpg', N'c6.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (7, N'TERIYAKI CHICKEN - GÀ XỐT TƯƠNG KIỂU NHẬT', N'1 cơm gà giòn + 1 burger gà quay + 1 pepsi lon', N'', NULL, 2, 1, CAST(95000 AS Decimal(10, 0)), 20, CAST(76000 AS Decimal(10, 0)), 5, N'c7.jpg', N'c7.jpg', N'c7.jpg', N'c7.jpg', N'c7.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (8, N'PEPPERONI FEAST - PIZZA XÚC XÍCH Ý TRUYỀN THỐNG', N'2 miếng gà giòn + 1 burger tôm + 2 pepsi lon', N'', NULL, 2, 1, CAST(129000 AS Decimal(10, 0)), 20, CAST(103200 AS Decimal(10, 0)), 5, N'c8.jpg', N'c8.jpg', N'c8.jpg', N'c8.jpg', N'c8.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (9, N'SEAFOOD DELIGHT - HẢI SẢN XỐT CÀ CHUA', N'3 miếng gà giòn + 1 khoai tây chiên (lớn) +  2 pepsi lon', N'', NULL, 1, 1, CAST(149000 AS Decimal(10, 0)), 20, CAST(119200 AS Decimal(10, 0)), 5, N'c9.jpg', N'c9.jpg', N'c9.jpg', N'c9.jpg', N'c9.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (10, N'OCEAN MANIA - HẢI SẢN XỐT MAYONNAISE', N'4 miếng gà giòn + 1 khoai tây chiên (lớn) + 2 pepsi lon', N'', NULL, 4, 1, CAST(185000 AS Decimal(10, 0)), 20, CAST(148000 AS Decimal(10, 0)), 5, N'c10.jpg', N'c10.jpg', N'c10.jpg', N'c10.jpg', N'c10.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (11, N'MEAT LOVERS - PIZZA 5 LOẠI THỊT THƯỢNG HẠNG', N'2 miếng gà giòn + 1 miếng gà quay + 1 khoai tây chiên (lớn) + 2 pepsi lon', N'', NULL, 0, 1, CAST(185000 AS Decimal(10, 0)), 20, CAST(148000 AS Decimal(10, 0)), 5, N'c11.jpg', N'c11.jpg', N'c11.jpg', N'c11.jpg', N'c11.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (12, N'EXTRAVAGANZA - PIZZA THẬP CẨM THƯỢNG HẠNG', N'3 miếng gà giòn + 1 burger gà quay + 1 khoai tây chiên (lớn) + 2 pepsi lon', N'', NULL, 0, 1, CAST(199000 AS Decimal(10, 0)), 20, CAST(159200 AS Decimal(10, 0)), 5, N'c12.jpg', N'c12.jpg', N'c12.jpg', N'c12.jpg', N'c12.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (13, N'CHEESY CHICKEN BACON - PIZZA GÀ PHÔ MAI THỊT HEO XÔNG KHÓI', N'3 miếng gà giòn + 1 popcorn (lớn) + 1 khoai tây chiên (lớn) + 2 pepsi lon', N'', NULL, 1, 1, CAST(205000 AS Decimal(10, 0)), 20, CAST(164000 AS Decimal(10, 0)), 5, N'c13.jpg', N'c13.jpg', N'c13.jpg', N'c13.jpg', N'c13.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (14, N'CHEESE MANIA - PIZZA PHÔ MAI HẢO HẠNG', N'8 miếng gà giòn + 2 khoai tây chiên (lớn) + 4 pepsi lon', N'', NULL, 0, 1, CAST(359000 AS Decimal(10, 0)), 20, CAST(287200 AS Decimal(10, 0)), 5, N'c14.jpg', N'c14.jpg', N'c14.jpg', N'c14.jpg', N'c14.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (15, N'HAWAIIAN - PIZZA DĂM BÔNG DỨA KIỂU HAWAII', N'5 miếng gà giòn + 2 burger gà quay + 2 khoai tây chiên (lớn) + 3 pepsi lon', N'', NULL, 0, 1, CAST(359000 AS Decimal(10, 0)), 20, CAST(287200 AS Decimal(10, 0)), 5, N'c15.jpg', N'c15.jpg', N'c15.jpg', N'c15.jpg', N'c15.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (16, N'KID MANIA - PIZZA TRỨNG CÚT XỐT PHÔ MAI', N'1 miếng gà hoàng kim + 1 khoai tây chiên (vừa) + 1 pepsi lon', N'', NULL, 0, 1, CAST(63000 AS Decimal(10, 0)), 0, CAST(63000 AS Decimal(10, 0)), 5, N'sp1.png', N'sp1.png', N'sp1.png', N'sp1.png', N'sp1.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (17, N'VEGGIE MANIA - PIZZA RAU CỦ THẬP CẨM (CHAY)', N'2 miếng gà hoàng kim + 1 khoai tây chiên (vừa) + 1 pepsi lon', N'', NULL, 0, 1, CAST(94000 AS Decimal(10, 0)), 0, CAST(94000 AS Decimal(10, 0)), 5, N'sp2.png', N'sp2.png', N'sp2.png', N'sp2.png', N'sp2.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (18, N'Combo Gà hoàng kim HDC', N'4 miếng gà hoàng kim + 1 popcorn (vừa) + 2 pepsi lon', N'', NULL, 0, 1, CAST(189000 AS Decimal(10, 0)), 0, CAST(189000 AS Decimal(10, 0)), 5, N'sp3.png', N'sp3.png', N'sp3.png', N'sp3.png', N'sp3.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (19, N'Gà hoàng kim (1 miếng)', N'1 miếng gà hoàng kim', N'', NULL, 0, 1, CAST(39000 AS Decimal(10, 0)), 0, CAST(39000 AS Decimal(10, 0)), 5, N'sp4.png', N'sp4.png', N'sp4.png', N'sp4.png', N'sp4.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (20, N'Gà hoàng kim (2 miếng)', N'2 miếng gà hoàng kim', N'', NULL, 0, 1, CAST(72000 AS Decimal(10, 0)), 0, CAST(72000 AS Decimal(10, 0)), 5, N'sp5.png', N'sp5.png', N'sp5.png', N'sp5.png', N'sp5.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (21, N'Gà hoàng kim (3 miếng)', N'3 miếng gà hoàng kim', N'', NULL, 0, 1, CAST(108000 AS Decimal(10, 0)), 0, CAST(108000 AS Decimal(10, 0)), 5, N'sp6.png', N'sp6.png', N'sp6.png', N'sp6.png', N'sp6.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (22, N'Gà hoàng kim (6 miếng)', N'6 miếng gà hoàng kim', N'', NULL, 0, 1, CAST(211000 AS Decimal(10, 0)), 0, CAST(211000 AS Decimal(10, 0)), 5, N'sp7.png', N'sp7.png', N'sp7.png', N'sp7.png', N'sp7.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (23, N'Gà hoàng kim (9 miếng)', N'9 miếng gà hoàng kim', N'', NULL, 1, 1, CAST(312000 AS Decimal(10, 0)), 0, CAST(312000 AS Decimal(10, 0)), 5, N'sp8.png', N'sp8.png', N'sp8.png', N'sp8.png', N'sp8.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (24, N'Thanh bí phô-mai (2 thanh)', N'2 thanh bí phô-mai', N'', NULL, 0, 1, CAST(26000 AS Decimal(10, 0)), 0, CAST(26000 AS Decimal(10, 0)), 5, N'sp9.png', N'sp9.png', N'sp9.png', N'sp9.png', N'sp9.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (25, N'Thanh bí phô-mai (3 thanh)', N'3 thanh bí phô-mai', N'', NULL, 0, 1, CAST(32000 AS Decimal(10, 0)), 0, CAST(32000 AS Decimal(10, 0)), 5, N'sp10.png', N'sp10.png', N'sp10.png', N'sp10.png', N'sp10.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (26, N'Thanh bí phô-mai (5 thanh)', N'5 thanh bí phô-mai', N'', NULL, 0, 1, CAST(52000 AS Decimal(10, 0)), 0, CAST(52000 AS Decimal(10, 0)), 5, N'sp11.png', N'sp11.png', N'sp11.png', N'sp11.png', N'sp11.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (27, N'Combo thanh bí phô-mai HDA', N'2 miếng gà giòn + 2 thanh bí phô-mai + 1 pepsi lon', N'', NULL, 0, 1, CAST(94000 AS Decimal(10, 0)), 0, CAST(94000 AS Decimal(10, 0)), 5, N'sp12.png', N'sp12.png', N'sp12.png', N'sp12.png', N'sp12.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (28, N'Combo thanh bí phô-mai HDB', N'1 burger gà quay + 2 thanh bí phô-mai + 1 pepsi lon', N'', NULL, 0, 1, CAST(74000 AS Decimal(10, 0)), 0, CAST(74000 AS Decimal(10, 0)), 5, N'sp13.png', N'sp13.png', N'sp13.png', N'sp13.png', N'sp13.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (29, N'Combo thanh bí phô-mai HDC', N'4 miếng gà giòn + 4 thanh bí phô-mai + 2 pepsi lon', N'', NULL, 0, 1, CAST(189000 AS Decimal(10, 0)), 0, CAST(189000 AS Decimal(10, 0)), 5, N'sp14.png', N'sp14.png', N'sp14.png', N'sp14.png', N'sp14.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (30, N'Gà bít-tết với cơm', N'1 phần gà bít-tết với cơm', N'', NULL, 0, 1, CAST(39000 AS Decimal(10, 0)), 0, CAST(39000 AS Decimal(10, 0)), 5, N'sp15.png', N'sp15.png', N'sp15.png', N'sp15.png', N'sp15.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (31, N'Gà bít-tết với khoai tây chiên', N'1 phần gà bít-tết với khoai tây chiên', N'', NULL, 0, 1, CAST(39000 AS Decimal(10, 0)), 0, CAST(39000 AS Decimal(10, 0)), 5, N'sp16.png', N'sp16.png', N'sp16.png', N'sp16.png', N'sp16.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (32, N'Combo gà bít-tết HDA', N'1 phần gà bít-tết với khoai tây chiên + 1 miếng gà giòn + 1 pepsi lon', N'', NULL, 0, 1, CAST(81000 AS Decimal(10, 0)), 0, CAST(81000 AS Decimal(10, 0)), 5, N'sp17.png', N'sp17.png', N'sp17.png', N'sp17.png', N'sp17.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (33, N'Combo gà bít-tết HDB', N'1 phần gà bít-tết với cơm + 1 miếng gà giòn + 1 pepsi lon', N'', NULL, 0, 1, CAST(81000 AS Decimal(10, 0)), 0, CAST(81000 AS Decimal(10, 0)), 5, N'sp18.png', N'sp18.png', N'sp18.png', N'sp18.png', N'sp18.png', CAST(N'2020-06-17' AS Date), 3)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (34, N'Gà rán (1 miếng)', N'1 miếng gà giòn', N'', NULL, 0, 1, CAST(36000 AS Decimal(10, 0)), 0, CAST(36000 AS Decimal(10, 0)), 5, N's1.jpg', N's1.jpg', N's1.jpg', N's1.jpg', N's1.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (35, N'Gà rán (2 miếng)', N'2 miếng gà giòn', N'', NULL, 0, 1, CAST(68000 AS Decimal(10, 0)), 0, CAST(68000 AS Decimal(10, 0)), 5, N's2.jpg', N's2.jpg', N's2.jpg', N's2.jpg', N's2.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (36, N'Gà rán (3 miếng)', N'3 miếng gà giòn', N'', NULL, 0, 1, CAST(99000 AS Decimal(10, 0)), 0, CAST(99000 AS Decimal(10, 0)), 5, N's3.jpg', N's3.jpg', N's3.jpg', N's3.jpg', N's3.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (37, N'Gà rán (6 miếng)', N'6 miếng gà giòn', N'', NULL, 0, 1, CAST(195000 AS Decimal(10, 0)), 0, CAST(195000 AS Decimal(10, 0)), 5, N's4.jpg', N's4.jpg', N's4.jpg', N's4.jpg', N's4.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (38, N'Gà rán (9 miếng)', N'9 miếng gà giòn', N'', NULL, 0, 1, CAST(289000 AS Decimal(10, 0)), 0, CAST(289000 AS Decimal(10, 0)), 5, N's5.jpg', N's5.jpg', N's5.jpg', N's5.jpg', N's5.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (39, N'Gà rán (12 miếng)', N'12 miếng gà giòn', N'', NULL, 0, 1, CAST(379000 AS Decimal(10, 0)), 0, CAST(379000 AS Decimal(10, 0)), 5, N's6.jpg', N's6.jpg', N's6.jpg', N's6.jpg', N's6.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (40, N'Gà quay (1 miếng)', N'1 miếng gà quay', N'', NULL, 0, 1, CAST(68000 AS Decimal(10, 0)), 0, CAST(68000 AS Decimal(10, 0)), 5, N's7.jpg', N's7.jpg', N's7.jpg', N's7.jpg', N's7.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (41, N'Phần hot wings (3 miếng)', N'3 miếng hot wings', N'', NULL, 0, 1, CAST(49000 AS Decimal(10, 0)), 0, CAST(49000 AS Decimal(10, 0)), 5, N's8.jpg', N's8.jpg', N's8.jpg', N's8.jpg', N's8.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (42, N'Phần hot wings (5 miếng)', N'5 miếng hot wings', N'', NULL, 0, 1, CAST(71000 AS Decimal(10, 0)), 0, CAST(71000 AS Decimal(10, 0)), 5, N's9.jpg', N's9.jpg', N's9.jpg', N's9.jpg', N's9.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (43, N'Combo Tekami 1', N'1 phần tekami', N'', NULL, 0, 1, CAST(34000 AS Decimal(10, 0)), 0, CAST(34000 AS Decimal(10, 0)), 5, N's10.png', N's10.png', N's10.png', N's10.png', N's10.png', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (44, N'Combo Tekami A', N'2 phần tekami', N'', NULL, 0, 1, CAST(61000 AS Decimal(10, 0)), 0, CAST(61000 AS Decimal(10, 0)), 5, N's11.png', N's11.png', N's11.png', N's11.png', N's11.png', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (45, N'Combo Tekami B', N'1 phần tekami + 1 miếng gà giòn + 1 pepsi lon', N'', NULL, 0, 1, CAST(83000 AS Decimal(10, 0)), 0, CAST(83000 AS Decimal(10, 0)), 5, N's12.png', N's12.png', N's12.png', N's12.png', N's12.png', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (46, N'Combo Tekami C', N'2 phần tekami + 1 khoai tây chiên (vừa) + 1 pepsi lon', N'', NULL, 0, 1, CAST(86000 AS Decimal(10, 0)), 0, CAST(86000 AS Decimal(10, 0)), 5, N's13.png', N's13.png', N's13.png', N's13.png', N's13.png', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (47, N'Combo Tekami D', N'3 phần tekami + 3 miếng gà giòn + 2 pepsi lon', N'', NULL, 0, 1, CAST(199000 AS Decimal(10, 0)), 0, CAST(199000 AS Decimal(10, 0)), 5, N's14.png', N's14.png', N's14.png', N's14.png', N's14.png', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (48, N'Cơm gà truyền thống', N'1 phần cơm gà truyền thống', N'', NULL, 1, 1, CAST(41000 AS Decimal(10, 0)), 0, CAST(41000 AS Decimal(10, 0)), 5, N's15.jpg', N's15.jpg', N's15.jpg', N's15.jpg', N's15.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (49, N'Cơm gà giòn cay', N'1 phần cơm gà giòn cay', N'', NULL, 0, 1, CAST(41000 AS Decimal(10, 0)), 0, CAST(41000 AS Decimal(10, 0)), 5, N's16.jpg', N's16.jpg', N's16.jpg', N's16.jpg', N's16.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (50, N'Cơm gà giòn không cay', N'1 phần cơm gà giòn không cay', N'', NULL, 0, 1, CAST(41000 AS Decimal(10, 0)), 0, CAST(41000 AS Decimal(10, 0)), 5, N's17.jpg', N's17.jpg', N's17.jpg', N's17.jpg', N's17.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (51, N'Cơm phi lê gà quay tiêu', N'1 phần cơm phi lê gà quay tiêu', N'', NULL, 0, 1, CAST(41000 AS Decimal(10, 0)), 0, CAST(41000 AS Decimal(10, 0)), 5, N's18.jpg', N's18.jpg', N's18.jpg', N's18.jpg', N's18.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (52, N'Cơm phi lê gà quay flava', N'1 phần cơm phi lê gà quay flava', N'', NULL, 0, 1, CAST(41000 AS Decimal(10, 0)), 0, CAST(41000 AS Decimal(10, 0)), 5, N's19.jpg', N's19.jpg', N's19.jpg', N's19.jpg', N's19.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (53, N'Cơm gà xào sốt Nhật', N'1 phần cơm gà xào sốt Nhật', N'', NULL, 0, 1, CAST(41000 AS Decimal(10, 0)), 0, CAST(41000 AS Decimal(10, 0)), 5, N's20.jpg', N's20.jpg', N's20.jpg', N's20.jpg', N's20.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (54, N'Cơm phi lê gà giòn', N'1 phần cơm phi lê gà giòn', N'', NULL, 0, 1, CAST(41000 AS Decimal(10, 0)), 0, CAST(41000 AS Decimal(10, 0)), 5, N's21.jpg', N's21.jpg', N's21.jpg', N's21.jpg', N's21.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (55, N'Cơm gà xiên que', N'1 phần cơm gà xiên que', N'', NULL, 0, 1, CAST(41000 AS Decimal(10, 0)), 0, CAST(41000 AS Decimal(10, 0)), 5, N's22.jpg', N's22.jpg', N's22.jpg', N's22.jpg', N's22.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (56, N'Burger tôm', N'1 burger tôm', N'', NULL, 0, 1, CAST(42000 AS Decimal(10, 0)), 0, CAST(42000 AS Decimal(10, 0)), 5, N's23.jpg', N's23.jpg', N's23.jpg', N's23.jpg', N's23.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (57, N'Burger gà quay flava', N'1 burger gà quay flava', N'', NULL, 0, 1, CAST(47000 AS Decimal(10, 0)), 0, CAST(47000 AS Decimal(10, 0)), 5, N's24.jpg', N's24.jpg', N's24.jpg', N's24.jpg', N's24.jpg', CAST(N'2020-06-17' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (58, N'Burger zinger', N'1 burgre zinger', N'', NULL, 0, 1, CAST(51000 AS Decimal(10, 0)), 0, CAST(51000 AS Decimal(10, 0)), 5, N's25.jpg', N's25.jpg', N's25.jpg', N's25.jpg', N's25.jpg', CAST(N'2020-06-17' AS Date), 5)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (59, N'Popcorn (vừa)', N'1 phần popconrn (vừa)', N'', NULL, 0, 1, CAST(37000 AS Decimal(10, 0)), 0, CAST(37000 AS Decimal(10, 0)), 5, N's26.jpg', N's26.jpg', N's26.jpg', N's26.jpg', N's26.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (60, N'Popcorn (lớn)', N'1 phần popcorn (lớn)', N'', NULL, 0, 1, CAST(57000 AS Decimal(10, 0)), 0, CAST(57000 AS Decimal(10, 0)), 5, N's27.jpg', N's27.jpg', N's27.jpg', N's27.jpg', N's27.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (61, N'Phô mai viên (4 viên)', N'4 viên phô mai', N'', NULL, 0, 1, CAST(29000 AS Decimal(10, 0)), 0, CAST(29000 AS Decimal(10, 0)), 5, N's28.jpg', N's28.jpg', N's28.jpg', N's28.jpg', N's28.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (62, N'Phô mai viên (6 viên)', N'6 viên phô mai', N'', NULL, 0, 1, CAST(39000 AS Decimal(10, 0)), 0, CAST(39000 AS Decimal(10, 0)), 5, N's29.jpg', N's29.jpg', N's29.jpg', N's29.jpg', N's29.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (63, N'Mashies nhân Gravy (3 viên)', N'3 viên mashies nhân gravy', N'', NULL, 0, 1, CAST(19000 AS Decimal(10, 0)), 0, CAST(19000 AS Decimal(10, 0)), 5, N's30.jpg', N's30.jpg', N's30.jpg', N's30.jpg', N's30.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (64, N'Mashies nhân Gravy (5 viên)', N'5 viên mashies nhân gravy', N'', NULL, 0, 1, CAST(29000 AS Decimal(10, 0)), 0, CAST(29000 AS Decimal(10, 0)), 5, N's31.jpg', N's31.jpg', N's31.jpg', N's31.jpg', N's31.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (65, N'Mashies nhân rau củ (3 viên)', N'3 viên mahies nhân rau củ', N'', NULL, 0, 1, CAST(25000 AS Decimal(10, 0)), 0, CAST(25000 AS Decimal(10, 0)), 5, N's32.jpg', N's32.jpg', N's32.jpg', N's32.jpg', N's32.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (66, N'Mashies nhân rau củ (5 viên)', N'5 viên mashies nhân rau củ', N'', NULL, 0, 1, CAST(35000 AS Decimal(10, 0)), 0, CAST(35000 AS Decimal(10, 0)), 5, N's33.jpg', N's33.jpg', N's33.jpg', N's33.jpg', N's33.jpg', CAST(N'2020-06-17' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (67, N'Cá thanh (3 thanh)', N'3 thanh cá', N'', NULL, 0, 1, CAST(41000 AS Decimal(10, 0)), 0, CAST(41000 AS Decimal(10, 0)), 5, N's34.jpg', N's34.jpg', N's34.jpg', N's34.jpg', N's34.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (68, N'Xà Lách KFC', N'1 xuất xà lách KFC', N'', NULL, 1, 1, CAST(20000 AS Decimal(10, 0)), 0, CAST(20000 AS Decimal(10, 0)), 5, N's36.jpg', N's36.jpg', N's36.jpg', N's36.jpg', N's36.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (69, N'Gà xiên que (2 thanh)', N'2 thanh gà xiên que', N'', NULL, 5, 1, CAST(31000 AS Decimal(10, 0)), 0, CAST(31000 AS Decimal(10, 0)), 5, N's37.jpg', N's37.jpg', N's37.jpg', N's37.jpg', N's37.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (70, N'Khoai tây chiên (vừa)', N'1 xuất khoai tây chiên (vừa)', N'', NULL, 0, 1, CAST(14000 AS Decimal(10, 0)), 0, CAST(14000 AS Decimal(10, 0)), 5, N's38.jpg', N's38.jpg', N's38.jpg', N's38.jpg', N's38.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (71, N'Khoai tây chiên (lớn)', N'1 xuất khoai tây chiên (lớn)', N'', NULL, 1, 1, CAST(27000 AS Decimal(10, 0)), 0, CAST(27000 AS Decimal(10, 0)), 5, N's39.jpg', N's39.jpg', N's39.jpg', N's39.jpg', N's39.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (72, N'Khoai tây chiên (đại)', N'1 xuất khoai tây chiên (đại)', N'', NULL, 1, 1, CAST(37000 AS Decimal(10, 0)), 0, CAST(37000 AS Decimal(10, 0)), 5, N's40.jpg', N's40.jpg', N's40.jpg', N's40.jpg', N's40.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (73, N'Bắp cải trộn (vừa)', N'1 xuất bắp cải trộn (vừa)', N'', NULL, 0, 1, CAST(12000 AS Decimal(10, 0)), 0, CAST(12000 AS Decimal(10, 0)), 5, N's41.jpg', N's41.jpg', N's41.jpg', N's41.jpg', N's41.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (74, N'Bắp cải trộn (lớn)', N'1 xuất bắp cải trộn (lớn)', N'', NULL, 0, 1, CAST(22000 AS Decimal(10, 0)), 0, CAST(22000 AS Decimal(10, 0)), 5, N's41.jpg', N's41.jpg', N's41.jpg', N's41.jpg', N's41.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (75, N'Bắp cải trộn (đại)', N'1 xuất bắp cải trộn (đại)', N'', NULL, 0, 1, CAST(32000 AS Decimal(10, 0)), 0, CAST(32000 AS Decimal(10, 0)), 5, N's43.jpg', N's43.jpg', N's43.jpg', N's43.jpg', N's43.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (76, N'Khoai tây nghiền (vừa)', N'1 xuất khoai tây nghiền (vừa)', N'', NULL, 1, 1, CAST(12000 AS Decimal(10, 0)), 0, CAST(12000 AS Decimal(10, 0)), 5, N's44.jpg', N's44.jpg', N's44.jpg', N's44.jpg', N's44.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (77, N'Khoai tây nghiền (lớn)', N'1 xuất khoai tây nghiền (lớn)', N'', NULL, 0, 1, CAST(22000 AS Decimal(10, 0)), 0, CAST(22000 AS Decimal(10, 0)), 5, N's45.jpg', N's45.jpg', N's45.jpg', N's45.jpg', N's45.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (78, N'Khoai tây nghiền (đại)', N'1 xuất khoai tây nghiền (đại)', N'', NULL, 0, 1, CAST(32000 AS Decimal(10, 0)), 0, CAST(32000 AS Decimal(10, 0)), 5, N's46.jpg', N's46.jpg', N's46.jpg', N's46.jpg', N's46.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (79, N'Cơm trắng', N'1 xuất cơm trắng', N'', NULL, 0, 1, CAST(10000 AS Decimal(10, 0)), 0, CAST(10000 AS Decimal(10, 0)), 5, N's47.jpg', N's47.jpg', N's47.jpg', N's47.jpg', N's47.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (80, N'Súp gà', N'1 xuất súp gà', N'', NULL, 0, 1, CAST(12000 AS Decimal(10, 0)), 0, CAST(12000 AS Decimal(10, 0)), 5, N's48.jpg', N's48.jpg', N's48.jpg', N's48.jpg', N's48.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (81, N'Mochi trà xanh (1 cái)', N'1 bánh mochi trà xanh', N'', NULL, 0, 1, CAST(17000 AS Decimal(10, 0)), 0, CAST(17000 AS Decimal(10, 0)), 5, N's49.png', N's49.png', N's49.png', N's49.png', N's49.png', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (82, N'Mochi trà xanh (3 cái)', N'3 bánh mochi trà xanh', N'', NULL, 0, 1, CAST(42000 AS Decimal(10, 0)), 0, CAST(42000 AS Decimal(10, 0)), 5, N's50.png', N's50.png', N's50.png', N's50.png', N's50.png', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (83, N'Mochi socola (1 cái)', N'1 bánh mochi socola', N'', NULL, 0, 1, CAST(17000 AS Decimal(10, 0)), 0, CAST(17000 AS Decimal(10, 0)), 5, N's51.png', N's51.png', N's51.png', N's51.png', N's51.png', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (84, N'Mochi socola (3 cái)', N'3 bánh mochi socola', N'', NULL, 0, 1, CAST(42000 AS Decimal(10, 0)), 0, CAST(42000 AS Decimal(10, 0)), 5, N's52.png', N's52.png', N's52.png', N's52.png', N's52.png', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (85, N'Pepsi lon', N'1 lon pepsi', N'', NULL, 0, 1, CAST(17000 AS Decimal(10, 0)), 0, CAST(17000 AS Decimal(10, 0)), 5, N's53.png', N's53.png', N's53.png', N's53.png', N's53.png', CAST(N'2020-06-18' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (86, N'7Up lon', N'1 lon 7Up', N'', NULL, 0, 1, CAST(17000 AS Decimal(10, 0)), 0, CAST(17000 AS Decimal(10, 0)), 5, N's54.png', N's54.png', N's54.png', N's54.png', N's54.png', CAST(N'2020-06-18' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (87, N'Pepsi Diet lon', N'1 lon pepsi diet', N'', NULL, 0, 1, CAST(17000 AS Decimal(10, 0)), 0, CAST(17000 AS Decimal(10, 0)), 5, N's55.jpg', N's55.jpg', N's55.jpg', N's55.jpg', N's55.jpg', CAST(N'2020-06-18' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (88, N'Sữa Milo', N'1 hộp sữa Milo', N'', NULL, 0, 1, CAST(19000 AS Decimal(10, 0)), 0, CAST(19000 AS Decimal(10, 0)), 5, N's56.jpg', N's56.jpg', N's56.jpg', N's56.jpg', N's56.jpg', CAST(N'2020-06-18' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (89, N'Aquafina', N'1 chai nước lọc Aquafina', N'', NULL, 0, 1, CAST(15000 AS Decimal(10, 0)), 0, CAST(15000 AS Decimal(10, 0)), 5, N's57.jpg', N's57.jpg', N's57.jpg', N's57.jpg', N's57.jpg', CAST(N'2020-06-18' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (90, N'Twister lon', N'1 lon twister', N'', NULL, 0, 1, CAST(17000 AS Decimal(10, 0)), 0, CAST(17000 AS Decimal(10, 0)), 5, N's58.png', N's58.png', N's58.png', N's58.png', N's58.png', CAST(N'2020-06-18' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (91, N'Trà đào', N'1 cốc trà đào', N'', NULL, 0, 1, CAST(24000 AS Decimal(10, 0)), 0, CAST(24000 AS Decimal(10, 0)), 5, N's59.jpg', N's59.jpg', N's59.jpg', N's59.jpg', N's59.jpg', CAST(N'2020-06-18' AS Date), 2)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (92, N'Bánh trứng (1 cái)', N'1 bánh trứng', N'', NULL, 0, 1, CAST(17000 AS Decimal(10, 0)), 0, CAST(17000 AS Decimal(10, 0)), 5, N's60.jpg', N's60.jpg', N's60.jpg', N's60.jpg', N's60.jpg', CAST(N'2020-06-18' AS Date), 1)
INSERT [dbo].[Product] ([id_product], [name], [description], [information], [review], [view], [availability], [price], [salePercent], [salePrice], [rate], [mainPhoto], [photo1], [photo2], [photo3], [photo4], [updated], [id_category]) VALUES (93, N'Bánh trứng (4 cái)', N'4 bánh trứng', N'', NULL, 0, 1, CAST(50000 AS Decimal(10, 0)), 0, CAST(50000 AS Decimal(10, 0)), 5, N's61.jpg', N's61.jpg', N's61.jpg', N's61.jpg', N's61.jpg', CAST(N'2020-06-18' AS Date), 1)
SET IDENTITY_INSERT [dbo].[Product] OFF
GO
SET IDENTITY_INSERT [dbo].[ProductDetail] ON 

INSERT [dbo].[ProductDetail] ([id_productDetail], [name], [amount], [availability], [extraPrice], [id_product]) VALUES (1, N'miếng hot wiings', 3, 1, CAST(20000 AS Decimal(10, 0)), 2)
INSERT [dbo].[ProductDetail] ([id_productDetail], [name], [amount], [availability], [extraPrice], [id_product]) VALUES (2, N'khoai tây chiên (lớn)', 1, 1, CAST(40000 AS Decimal(10, 0)), 2)
INSERT [dbo].[ProductDetail] ([id_productDetail], [name], [amount], [availability], [extraPrice], [id_product]) VALUES (3, N'pepsi lon', 1, 1, CAST(15000 AS Decimal(10, 0)), 2)
INSERT [dbo].[ProductDetail] ([id_productDetail], [name], [amount], [availability], [extraPrice], [id_product]) VALUES (4, N'pepsi lon', 1, 0, CAST(15000 AS Decimal(10, 0)), 2)
INSERT [dbo].[ProductDetail] ([id_productDetail], [name], [amount], [availability], [extraPrice], [id_product]) VALUES (5, N'coca lon', 1, 0, CAST(15000 AS Decimal(10, 0)), 2)
INSERT [dbo].[ProductDetail] ([id_productDetail], [name], [amount], [availability], [extraPrice], [id_product]) VALUES (6, N'7up lon', 1, 1, CAST(15000 AS Decimal(10, 0)), 1)
INSERT [dbo].[ProductDetail] ([id_productDetail], [name], [amount], [availability], [extraPrice], [id_product]) VALUES (7, N'coca lon', 1, 1, CAST(15000 AS Decimal(10, 0)), 1)
INSERT [dbo].[ProductDetail] ([id_productDetail], [name], [amount], [availability], [extraPrice], [id_product]) VALUES (8, N'pepsi lon', 1, 1, CAST(15000 AS Decimal(10, 0)), 1)
SET IDENTITY_INSERT [dbo].[ProductDetail] OFF
GO
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'ADD_CATEGORY', N'Thêm loại sản phẩm')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'ADD_CUSTOMER', N'Thêm khách hàng')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'ADD_DISCOUNTCODE', N'Thêm mã giảm giá')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'ADD_PRODUCT', N'Thêm sản phẩm')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'ADD_USER', N'Thêm user')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'CHANGE_STATUS_BILL', N'Sửa trạng thái hóa đơn')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'DELETE_BILL', N'Xóa đơn hàng')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'DELETE_CATEGORY', N'Xóa loại sản phẩm')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'DELETE_CUSTOMER', N'Xóa khách hàng')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'DELETE_DISCOUNTCODE', N'Xóa mã giảm giá')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'DELETE_PRODUCT', N'Xóa sản phẩm')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'DELETE_USER', N'Xóa user')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'EDIT_CATEGORY', N'Sửa loại sản phẩm')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'EDIT_CUSTOMER', N'Sửa khách hàng')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'EDIT_DISCOUNTCODE', N'Sửa mã giảm giá')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'EDIT_PRODUCT', N'Sửa sản phẩm')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'EDIT_USER', N'Sửa user')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'VIEW_BILL', N'Xem đơn hàng')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'VIEW_CATEGORY', N'Xem loại sản phẩm')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'VIEW_CUSTOMER', N'Xem khách hàng')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'VIEW_DISCOUNTCODE', N'Xem mã giảm giá')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'VIEW_PRODUCT', N'Xem sản phẩm')
INSERT [dbo].[Role] ([id_role], [name]) VALUES (N'VIEW_USER', N'Xem user')
GO
SET IDENTITY_INSERT [dbo].[User] ON 

INSERT [dbo].[User] ([id_user], [userName], [password], [name], [email], [status], [createDate], [id_userGroup]) VALUES (1, N'hieumta', N'hieu', N'Vũ Minh Hiếu', N'vuhieupro1999@gmail.com', NULL, CAST(N'2020-06-16T00:00:00.000' AS DateTime), N'ADMIN')
INSERT [dbo].[User] ([id_user], [userName], [password], [name], [email], [status], [createDate], [id_userGroup]) VALUES (6, N'tienmta', N'202CB962AC59075B964B07152D234B70', N'Nguyễn Hữu Tiến', N'tiennguyenhuu1999@gmail.com', NULL, NULL, N'ADMIN')
INSERT [dbo].[User] ([id_user], [userName], [password], [name], [email], [status], [createDate], [id_userGroup]) VALUES (7, N'tienmta1', N'202CB962AC59075B964B07152D234B70', N'Nguyễn Hữu Tiến 2', N'tien@gmail.com', NULL, NULL, N'ADMIN')
INSERT [dbo].[User] ([id_user], [userName], [password], [name], [email], [status], [createDate], [id_userGroup]) VALUES (8, N'tienmta2', N'202CB962AC59075B964B07152D234B70', N'Nguyễn Hữu Tiến', N'tien@gmail.com', NULL, NULL, NULL)
SET IDENTITY_INSERT [dbo].[User] OFF
GO
INSERT [dbo].[UserGroup] ([id_userGroup], [name]) VALUES (N'ADMIN', N'Quản trị')
INSERT [dbo].[UserGroup] ([id_userGroup], [name]) VALUES (N'MEMBER', N'Thành viên')
INSERT [dbo].[UserGroup] ([id_userGroup], [name]) VALUES (N'SALE', N'Nhân viên bán hàng')
GO
ALTER TABLE [dbo].[Bill] ADD  CONSTRAINT [DF_Bill_subtotal]  DEFAULT ((0)) FOR [subtotal]
GO
ALTER TABLE [dbo].[Bill] ADD  CONSTRAINT [DF_Bill_total]  DEFAULT ((0)) FOR [total]
GO
ALTER TABLE [dbo].[Bill] ADD  CONSTRAINT [DF_Bill_discount]  DEFAULT ((0)) FOR [discount]
GO
ALTER TABLE [dbo].[Bill] ADD  CONSTRAINT [DF_Bill_status]  DEFAULT ((1)) FOR [id_status]
GO
ALTER TABLE [dbo].[BillDetail] ADD  CONSTRAINT [DF_BillDetail_price]  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[BillDetail] ADD  CONSTRAINT [DF_BillDetail_amount]  DEFAULT ((0)) FOR [amount]
GO
ALTER TABLE [dbo].[BillDetail] ADD  CONSTRAINT [DF_BillDetail_intoMoney]  DEFAULT ((0)) FOR [intoMoney]
GO
ALTER TABLE [dbo].[Cart] ADD  CONSTRAINT [DF_Cart_subtotal]  DEFAULT ((0)) FOR [subtotal]
GO
ALTER TABLE [dbo].[Cart] ADD  CONSTRAINT [DF_Cart_total]  DEFAULT ((0)) FOR [total]
GO
ALTER TABLE [dbo].[CartDetail] ADD  CONSTRAINT [DF_CartDetail_price]  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[CartDetail] ADD  CONSTRAINT [DF_CartDetail_amount]  DEFAULT ((0)) FOR [amount]
GO
ALTER TABLE [dbo].[CartDetail] ADD  CONSTRAINT [DF_CartDetail_intoMoney]  DEFAULT ((0)) FOR [intoMoney]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_subtotalCart]  DEFAULT ((0)) FOR [subtotalCart]
GO
ALTER TABLE [dbo].[Customer] ADD  CONSTRAINT [DF_Customer_total]  DEFAULT ((0)) FOR [totalCart]
GO
ALTER TABLE [dbo].[DiscountCode] ADD  CONSTRAINT [DF_DiscountCode_discount]  DEFAULT ((0)) FOR [discount]
GO
ALTER TABLE [dbo].[Product] ADD  CONSTRAINT [DF_Product_review]  DEFAULT ((0)) FOR [view]
GO
ALTER TABLE [dbo].[Product] ADD  CONSTRAINT [DF_Product_availability]  DEFAULT ((1)) FOR [availability]
GO
ALTER TABLE [dbo].[Product] ADD  CONSTRAINT [DF_Product_price]  DEFAULT ((0)) FOR [price]
GO
ALTER TABLE [dbo].[Product] ADD  CONSTRAINT [DF_Product_salePercent]  DEFAULT ((0)) FOR [salePercent]
GO
ALTER TABLE [dbo].[Product] ADD  CONSTRAINT [DF_Product_salePrice]  DEFAULT ((0)) FOR [salePrice]
GO
ALTER TABLE [dbo].[ProductDetail] ADD  CONSTRAINT [DF_ProductDetail_amount]  DEFAULT ((0)) FOR [amount]
GO
ALTER TABLE [dbo].[ProductDetail] ADD  CONSTRAINT [DF_ProductDetail_availability]  DEFAULT ((1)) FOR [availability]
GO
ALTER TABLE [dbo].[ProductDetail] ADD  CONSTRAINT [DF_ProductDetail_extraPrice]  DEFAULT ((0)) FOR [extraPrice]
GO
ALTER TABLE [dbo].[Bill]  WITH CHECK ADD  CONSTRAINT [FK_Bill_BillStatus] FOREIGN KEY([id_status])
REFERENCES [dbo].[BillStatus] ([id_status])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Bill] CHECK CONSTRAINT [FK_Bill_BillStatus]
GO
ALTER TABLE [dbo].[Bill]  WITH CHECK ADD  CONSTRAINT [FK_Bill_Customer] FOREIGN KEY([id_customer])
REFERENCES [dbo].[Customer] ([id_customer])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Bill] CHECK CONSTRAINT [FK_Bill_Customer]
GO
ALTER TABLE [dbo].[BillDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillDetail_Bill] FOREIGN KEY([id_bill])
REFERENCES [dbo].[Bill] ([id_bill])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BillDetail] CHECK CONSTRAINT [FK_BillDetail_Bill]
GO
ALTER TABLE [dbo].[BillDetail]  WITH CHECK ADD  CONSTRAINT [FK_BillDetail_Product] FOREIGN KEY([id_product])
REFERENCES [dbo].[Product] ([id_product])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[BillDetail] CHECK CONSTRAINT [FK_BillDetail_Product]
GO
ALTER TABLE [dbo].[Cart]  WITH CHECK ADD  CONSTRAINT [FK_Cart_Customer] FOREIGN KEY([id_customer])
REFERENCES [dbo].[Customer] ([id_customer])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Cart] CHECK CONSTRAINT [FK_Cart_Customer]
GO
ALTER TABLE [dbo].[CartDetail]  WITH CHECK ADD  CONSTRAINT [FK_CartDetail_Cart] FOREIGN KEY([id_cart])
REFERENCES [dbo].[Cart] ([id_cart])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CartDetail] CHECK CONSTRAINT [FK_CartDetail_Cart]
GO
ALTER TABLE [dbo].[CartDetail]  WITH CHECK ADD  CONSTRAINT [FK_CartDetail_Product] FOREIGN KEY([id_product])
REFERENCES [dbo].[Product] ([id_product])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[CartDetail] CHECK CONSTRAINT [FK_CartDetail_Product]
GO
ALTER TABLE [dbo].[Credential]  WITH CHECK ADD  CONSTRAINT [FK_Credential_Role] FOREIGN KEY([id_role])
REFERENCES [dbo].[Role] ([id_role])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Credential] CHECK CONSTRAINT [FK_Credential_Role]
GO
ALTER TABLE [dbo].[Credential]  WITH CHECK ADD  CONSTRAINT [FK_Credential_UserGroup] FOREIGN KEY([id_userGroup])
REFERENCES [dbo].[UserGroup] ([id_userGroup])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Credential] CHECK CONSTRAINT [FK_Credential_UserGroup]
GO
ALTER TABLE [dbo].[Customer]  WITH CHECK ADD  CONSTRAINT [FK_Customer_DiscountCode] FOREIGN KEY([id_discountCode])
REFERENCES [dbo].[DiscountCode] ([id_discountCode])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Customer] CHECK CONSTRAINT [FK_Customer_DiscountCode]
GO
ALTER TABLE [dbo].[Product]  WITH CHECK ADD  CONSTRAINT [FK_Product_Category] FOREIGN KEY([id_category])
REFERENCES [dbo].[Category] ([id_category])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Product] CHECK CONSTRAINT [FK_Product_Category]
GO
ALTER TABLE [dbo].[ProductDetail]  WITH CHECK ADD  CONSTRAINT [FK_ProductDetail_Product] FOREIGN KEY([id_product])
REFERENCES [dbo].[Product] ([id_product])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[ProductDetail] CHECK CONSTRAINT [FK_ProductDetail_Product]
GO
ALTER TABLE [dbo].[User]  WITH CHECK ADD  CONSTRAINT [FK_User_UserGroup] FOREIGN KEY([id_userGroup])
REFERENCES [dbo].[UserGroup] ([id_userGroup])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[User] CHECK CONSTRAINT [FK_User_UserGroup]
GO
/****** Object:  StoredProcedure [dbo].[Statictis]    Script Date: 3/20/2021 8:27:30 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[Statictis]
AS
BEGIN
	declare @statictis table(total int)
	DECLARE @total INT
	DECLARE @Counter INT 
	SET @Counter=1
	WHILE ( @Counter <= 12)
	BEGIN
		select @total=SUM(total)  from Bill where MONTH(creatDate) = @Counter
		insert @statictis values(@total)
		SET @Counter = @Counter + 1
	END
	select * from @statictis
END
GO
USE [master]
GO
ALTER DATABASE [SnackShopDB] SET  READ_WRITE 
GO
