USE Project
GO


/*********************************************************/
/******************    Loading DML       ******************/
/*********************************************************/

/*********************************************************/
/******************  Load Dim.Calendar Table  ******************/
/*********************************************************/
 
IF (SELECT COUNT(*) FROM dim.Calendar) = 0
BEGIN
    -- Declare variables
    DECLARE @StartDate DATE = '2020-01-01';
    DECLARE @EndDate DATE = DATEADD(year, 3, GETDATE());
    DECLARE @Date DATE = @StartDate;
 
    -- Populate the Calendar table
    WHILE @Date <= @EndDate
    BEGIN
        INSERT INTO dim.Calendar (
            [OrderDate], 
            [Year], 
            [Quarter], 
            [Month], 
            [MonthName]
        )
        VALUES (
            @Date,
            YEAR(@Date),
            DATEPART(QUARTER, @Date),
            MONTH(@Date),
            DATENAME(MONTH, @Date)
        );
 
        -- Increment the date
        SET @Date = DATEADD(DAY, 1, @Date);
    END;
END;
GO

/*********************************************************/
/******************  Load Dim.Customer Table  ******************/
/*********************************************************/
GO

INSERT INTO dim.Customers(CustomerKey, [Full Name], EducationLevel, [Income Level], Occupation)
	SELECT cus.CustomerKey
		  ,cus.[Full Name]
		  ,cus.EducationLevel
		  ,cus.[Income Level]
		  ,cus.Occupation
	FROM stg.[Customer Lookup] cus
	WHERE cus.CustomerKey NOT IN (SELECT CustomerKey FROM dim.Customers)

;
GO

/*********************************************************/
/******************  Load Dim.Product_Categories Table  ******************/
/*********************************************************/
GO

INSERT INTO dim.Product_Categories(ProductCategoryKey, CategoryName)
SELECT pcat.ProductCategoryKey
      ,pcat.CategoryName
FROM stg.[Product Categories Lookup] pcat
WHERE pcat.ProductCategoryKey not in (SELECT ProductcategoryKey FROM dim.Product_categories)
;
GO


/*********************************************************/
/******************  Load Dim.Product Table  ******************/
/*********************************************************/


INSERT INTO dim.Products (ProductKey, ProductSubcategoryKey, ProductName, ProductColor, ProductCost, ProductPrice, [Discount Price])
SELECT 
       TRY_CAST(prod.ProductKey AS INT) AS ProductKey,
       prod.ProductSubcategoryKey,
       prod.ProductName,
       prod.ProductColor,
       prod.ProductCost,
       prod.ProductPrice,
       prod.[Discount Price]
FROM stg.[Product Lookup] prod
WHERE 
    TRY_CAST(prod.ProductKey AS INT) IS NOT NULL -- Ensure only valid numeric values are considered
    AND TRY_CAST(prod.ProductKey AS INT) NOT IN (SELECT ProductKey FROM dim.Products);


GO

/*********************************************************/
/******************  Load Dim.Territory Table  ******************/
/*********************************************************/
GO

INSERT INTO dim.Territory(TerritoryKey,Region,Country,Continent)
SELECT t.SalesTerritoryKey
      ,t.Region
	  ,t.Country
	  ,t.Continent
FROM stg.[Territory Lookup] t
WHERE t.SalesTerritoryKey not in (SELECT TerritoryKey FROM dim.Territory)
;
GO

/*********************************************************/
/******************  Load Dim.Product_Categories Table  ******************/
/*********************************************************/
GO

INSERT INTO dim.Product_SubCategories(ProductSubcategoryKey, SubcategoryName, ProductCategoryKey)
SELECT pscat.ProductSubcategoryKey
      ,pscat.SubcategoryName
	  ,pscat.ProductCategoryKey
FROM stg.[Product Subcategories Lookup] pscat
WHERE pscat.ProductSubcategoryKey not in (SELECT ProductSubcategoryKey FROM dim.Product_SubCategories)
;
GO




/*********************************************************/
/******************  Fact TableLoaders  ******************/
/*********************************************************/


/******************  Orders f.Sales Fact   ******************/


INSERT INTO f.Sales(OrderDate, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderQuantity, RetailPrice, Revenue)
SELECT s.OrderDate
	  ,s.OrderNumber
	  ,s.ProductKey
	  ,s.Customerkey
	  ,s.TerritoryKey
	  ,s.OrderQuantity
	  ,s.[Retail Price]
	  ,s.Revenue
FROM stg.[qSales Data] s


;



/******************   f.Returns   ******************/


INSERT INTO Project.f.Returns(ReturnDate, ProductKey, TerritoryKey, ReturnQuantity)
SELECT r.ReturnDate
	  ,r.ProductKey
	  ,r.TerritoryKey
	  ,r.ReturnQuantity
FROM stg.[qReturns Data] r


;
