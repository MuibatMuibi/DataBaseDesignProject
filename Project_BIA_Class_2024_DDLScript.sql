USE Project;
GO

/*********************************************************/
/******************    Schema DDL       ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'dim' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA dim AUTHORIZATION dbo;'
END
;

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'stg' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA stg AUTHORIZATION dbo;'
END
;

GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'f' ) 
BEGIN
	EXEC sp_executesql N'CREATE SCHEMA f AUTHORIZATION dbo;'
END
;

GO

--- Brought in the tables using dax studio to the created stg schema0


/*********************************************************/
/******************   DIM DDL   ******************/
/*********************************************************/


/*********************************************************/
/******************  Calendar Dim DDL   ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Calendar')
BEGIN

CREATE TABLE dim.Calendar
(
    --pkdate_id INT IDENTITY(1000,1) NOT NULL,
	[OrderDate] [datetime2](0) NOT NULL,
	[Year] [int] NOT NULL,
	[Quarter] [int] NOT NULL,
	[Month] [int] NOT NULL,
	[MonthName] [varchar](10) NOT NULL
);
 
	ALTER TABLE dim.Calendar
	ADD CONSTRAINT PK_Calendar_Julian PRIMARY KEY([OrderDate]);
 
	--ALTER TABLE dim.Calendar
    --ADD CONSTRAINT UC_Calendar UNIQUE (Year);
END
 
GO

/*********************************************************/
/******************  Customer DIM DDL   ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Customers')
BEGIN
	
    CREATE TABLE [dim].[Customers](
	[CustomerKey] [int] NOT NULL,
	[Full Name] [nvarchar](max) NOT NULL,
	[BirthDate] [nvarchar](max) NULL,
	[Gender] [nvarchar](max) NULL,
	[EmailAddress] [nvarchar](max) NULL,
	[TotalChildren] [nvarchar](25) NULL,
	[EducationLevel] [nvarchar](max) NULL,
	[Occupation] [nvarchar](max) NULL,
	[HomeOwner] [nvarchar](max) NULL,
	[Parent] [nvarchar](max) NULL,
	[Customer priority] [nvarchar](max) NULL,
	[Income Level] [nvarchar](max) NULL,
	[Education Level] [nvarchar](max) NULL,
	)
	;

	ALTER TABLE dim.Customers
    ADD CONSTRAINT PK_Cus_Key PRIMARY KEY (CustomerKey);

END;

GO

/*********************************************************/
/******************  Product Categories DIM DDL    ******************/
/*********************************************************/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Product_Categories')
BEGIN

CREATE TABLE dim.Product_Categories
(
    ProductCategoryKey int NOT NULL,
	CategoryName nvarchar(max) NOT NULL,
	
);
ALTER TABLE dim.Product_Categories
ADD CONSTRAINT PK_Prodcat PRIMARY KEY(ProductCategoryKey);

END;
GO


/*********************************************************/
/******************  Product DIM DDL   ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Product')
BEGIN
    CREATE TABLE dim.Product(
	--pkProdId bigint NOT NULL,
	ProductKey int NOT NULL,
	ProductSubcategoryKey int NOT NULL,
	ProductName nvarchar(max) NOT NULL,
	ProductColor nvarchar(max) NOT NULL,
	ProductCost money NULL,
	ProductPrice money NOT NULL,
	[Discount Price] decimal NOT NULL

);

ALTER TABLE dim.Product
ADD CONSTRAINT PK_Prod PRIMARY KEY(ProductKey);
	

END

GO
/*********************************************************/
/******************  Products DIM DDL   ******************/
/*********************************************************/

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Products')
BEGIN
    CREATE TABLE dim.Products(
	--pkProdId int NOT NULL,
	ProductKey int NOT NULL,
	ProductSubcategoryKey int NOT NULL,
	ProductName nvarchar(max) NOT NULL,
	ProductColor nvarchar(max) NOT NULL,
	ProductCost money NULL,
	ProductPrice money NOT NULL,
	[Discount Price] decimal NOT NULL

);

ALTER TABLE dim.Products
ADD CONSTRAINT PK_Prods PRIMARY KEY(ProductKey);
	

END

GO



/*********************************************************/
/******************  Territory DIM DDL    ******************/
/*********************************************************/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Territory')
BEGIN


CREATE TABLE dim.Territory
(
    TerritoryKey int NOT NULL,
	Region nvarchar(max) NOT NULL,
	Country nvarchar(max) NOT NULL,
	Continent nvarchar(max) NOT NULL
);

ALTER TABLE dim.Territory
ADD CONSTRAINT PK_Territory PRIMARY KEY(TerritoryKey);

END

GO

/*********************************************************/
/******************  Product SubCategories DIM DDL    ******************/
/*********************************************************/
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dim' AND TABLE_NAME = 'Product_SubCategories')
BEGIN

CREATE TABLE dim.Product_SubCategories
(
    ProductSubcategoryKey int NOT NULL,
	SubcategoryName nvarchar(max) NOT NULL,
	ProductCategoryKey int NOT NULL,
	
);
ALTER TABLE dim.Product_SubCategories
ADD CONSTRAINT PK_Prodscat PRIMARY KEY(ProductSubcategoryKey);

END;




/*********************************************************/
/*********************************************************/
/*********************************************************/
/******************  Fact Table Builds  ******************/
/*********************************************************/
/*********************************************************/
/*********************************************************/


/*********************************************************/
/******************  Sales f.Table  ******************/
/*********************************************************/


IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'f' AND TABLE_NAME = 'Sales')
BEGIN 

  DROP TABLE f.Sales;
END;


CREATE TABLE f.Sales(
	OrderDate datetime2(0) NOT NULL,
	--Order Year  int NOT NULL,
	OrderNumber nvarchar(50) NOT NULL,
	ProductKey int NOT NULL,
	CustomerKey int NOT NULL,
	TerritoryKey int NOT NULL,
	ProductCatKey int NULL,
	OrderQuantity int NOT NULL,
	RetailPrice decimal NOT NULL,
	Revenue decimal NOT NULL,

);



ALTER TABLE f.Sales
ADD CONSTRAINT FK_SalestoCAL
	FOREIGN KEY (OrderDate)              -- FROM the LOCAL TABLE
	 REFERENCES  dim.Calendar(OrderDate) -- TO the FOREIGN TABLE
;


ALTER TABLE f.Sales 
ADD CONSTRAINT FK_SalestoCus 
    FOREIGN KEY (CustomerKey) 
	 REFERENCES dim.Customers(CustomerKey);

ALTER TABLE f.Sales
ADD CONSTRAINT FK_SalestoProd
	FOREIGN KEY (ProductKey)      -- FROM the LOCAL TABLE
	 REFERENCES dim.Products(ProductKey)   -- TO the FOREIGN TABLE
;


ALTER TABLE f.Sales
ADD CONSTRAINT FK_Territory
	FOREIGN KEY (TerritoryKey)    -- FROM the LOCAL TABLE
	 REFERENCES dim.Territory(TerritoryKey)  -- TO the FOREIGN TABLE
;


/*********************************************************/
/******************  Returns f.Table  ******************/
/*********************************************************/

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'f' AND TABLE_NAME = 'Returns')
BEGIN 

  DROP TABLE f.Returns;
END;

CREATE TABLE f.Returns(
	ReturnDate datetime2(0) NOT NULL,
	--Order Year  int NOT NULL,
	ProductKey int NOT NULL,
	TerritoryKey int NOT NULL,
	ReturnQuantity int NOT NULL,


);


ALTER TABLE f.Returns
ADD CONSTRAINT FK_ReturnstoCAL
	FOREIGN KEY (ReturnDate)              -- FROM the LOCAL TABLE
	 REFERENCES  dim.Calendar(OrderDate) -- TO the FOREIGN TABLE
;


ALTER TABLE f.Returns
ADD CONSTRAINT FK_ReturnstoProd
	FOREIGN KEY (ProductKey)      -- FROM the LOCAL TABLE
	 REFERENCES dim.Products(ProductKey)   -- TO the FOREIGN TABLE
;


ALTER TABLE f.Returns
ADD CONSTRAINT FK_ReturnsTerritory
	FOREIGN KEY (TerritoryKey)    -- FROM the LOCAL TABLE
	 REFERENCES dim.Territory(TerritoryKey)  -- TO the FOREIGN TABLE

;
