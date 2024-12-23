--QUERY FOR AdventureWorks_Calendar
--Alter AdventureWorks_Calendar table by renaming column header from date to Dates since date is a Datatype.
ALTER TABLE AdventureWorks_Calendar RENAME COLUMN DATE TO DATES;
--DATA CLEANING PROCESS FOR ALL 10 TABLES AND CHECKING FOR DUPLICATES ALSO
--Check for missing values
SELECT *
FROM AdventureWorks_Calendar
WHERE dates is NULL;

--Identifying Duplicates
SELECT MIN(ROWID)
FROM AdventureWorks_Calendar
GROUP BY DATES;

--AdventureWorks_Customers QUERIES
--Check for missing values
PRAGMA table_info(AdventureWorks_Customers);
SELECT *
FROM AdventureWorks_Customers
WHERE (CustomerKey IS NULL OR Prefix IS NULL OR FirstName IS NULL OR LastName IS NULL OR BirthDate IS NULL OR MaritalStatus IS NULL OR Gender IS NULL OR EmailAddress IS NULL OR AnnualIncome IS NULL OR TotalChildren IS NULL OR EducationLevel IS NULL OR Occupation IS NULL OR HomeOwner IS NULL);

--Replace rows with null values in the table AdventureWorks_Customers (They're 130 rows with null value in the Gender column)

UPDATE AdventureWorks_Customers
SET PREFIX = 'NA'
WHERE Prefix IS NULL;

--AdventureWorks_Product_Categories Queries
--Check for missing values
PRAGMA table_info(AdventureWorks_Product_Categories);
SELECT *
FROM AdventureWorks_Product_Categories
WHERE (ProductCategoryKey IS NULL OR CategoryName IS NULL);
--No missing values in AdventureWorks_Product_Categories
--Check for Duplicates
SELECT MIN(ROWID)
FROM AdventureWorks_Product_Categories
GROUP BY ProductCategoryKey, CategoryName;
--AdventureWorks_Product_Subcategories
--Check for missing VALUES
PRAGMA table_info(AdventureWorks_Product_Subcategories);
SELECT * 
FROM AdventureWorks_Product_Subcategories
WHERE (ProductSubcategoryKey IS NULL OR SubcategoryName IS NULL OR ProductCategoryKey IS NULL);
--No missing values in AdventureWorks_Product_Subcategories
--Check for Duplicates
SELECT MIN(ROWID)
FROM AdventureWorks_Product_Subcategories
GROUP BY ProductSubcategoryKey, SubcategoryName, ProductCategoryKey;
--AdventureWorks_Product_Subcategories contains duplicates that do not harm the DATABASE (Categorical Variables)

--AdventureWorks_Products Queries
--Check Missing values
PRAGMA table_info(AdventureWorks_Products);
SELECT *
FROM AdventureWorks_Products
WHERE (ProductKey IS NULL OR ProductSubcategoryKey IS NULL OR ProductSKU IS NULL OR ProductName IS NULL OR ModelName IS NULL OR ProductDescription IS NULL OR ProductColor IS NULL OR ProductSize IS NULL OR ProductStyle IS NULL OR ProductCost IS NULL OR PRODUCTPRICE IS NULL);
--No missing values

--AdventureWorks_Returns Queries
--Check Missing VALUES
PRAGMA table_info(AdventureWorks_Returns);
select *
FROM AdventureWorks_Returns 
WHERE (Returndate IS NULL OR TerritoryKey IS NULL OR ProductKey IS NULL OR ReturnQuantity IS NULL);
--No missing values

--AdventureWorks_Sales_2015 Queries
--Checking Missing VALUES
Pragma table_info(AdventureWorks_Sales_2015);
SELECT *
FROM AdventureWorks_Sales_2015
WHERE (OrderDate IS NULL OR StockDate IS NULL OR OrderNumber IS NULL OR ProductKey IS NULL OR CustomerKey IS NULL OR TerritoryKey IS NULL OR OrderLineItem IS NULL OR OrderQuantity IS NULL);
--No missing VALUES

--AdventureWorks_Sales_2016 Queries
--Checking Missing Values
pragma table_info(AdventureWorks_Sales_2016);
select *
from AdventureWorks_Sales_2016
where (OrderDate IS NULL OR STOCKDATE IS NULL OR OrderNumber IS NULL OR ProductKey IS NULL OR CustomerKey IS NULL OR TerritoryKey IS NULL OR OrderLineItem IS NULL OR OrderQuantity IS NULL);
--No missing VALUES

--AdventureWorks_Sales_2017 Queries
--Checking Missing VALUES
pragma table_info(AdventureWorks_Sales_2017);
select *
from AdventureWorks_Sales_2017
where (OrderDate is null or StockDate is null or OrderNumber is null or ProductKey is null or CustomerKey is null or TerritoryKey is null or OrderLineItem is null or OrderQuantity is null);
--No missing VALUES

--AdventureWorks_Territories Queries
--Checking Missing VALUES
pragma table_info(AdventureWorks_Territories);
select *
from AdventureWorks_Territories
where (SalesTerritoryKey is null or Region is null or Country is null or Continent is null);
--No missing values

--Merge the AdventureWorks_Sales_2015, AdventureWorks_Sales_2016 and AdventureWorks_Sales_2017 for easier analysis of DATA

Create Table merged_AdventuresWorks_sales (
	OrderDate TEXT,
	StockDate TEXT,
	OrderNumber TEXT,
	ProductKey INTEGER,
	CustomerKey INTEGER,
	TerritoryKey INTEGER PRIMARY KEY,
	OrderLineItem INTEGER,
	OrderQuantity INTEGER
);

drop table merged_AdventuresWorks_sales;
drop table DimCalendars;

Create Table merged_AdventuresWorks_sales (
	OrderDate TEXT,
	StockDate TEXT,
	OrderNumber TEXT,
	ProductKey INTEGER,
	CustomerKey INTEGER,
	TerritoryKey INTEGER,
	OrderLineItem INTEGER,
	OrderQuantity INTEGER
);

INSERT INTO merged_AdventuresWorks_sales (OrderDate,StockDate, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderLineItem, OrderQuantity)
Select OrderDate, StockDate, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderLineItem, OrderQuantity from AdventureWorks_Sales_2015;

INSERT INTO merged_AdventuresWorks_sales (OrderDate,StockDate, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderLineItem, OrderQuantity)
Select OrderDate, StockDate, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderLineItem, OrderQuantity from AdventureWorks_Sales_2016;

INSERT INTO merged_AdventuresWorks_sales (OrderDate,StockDate, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderLineItem, OrderQuantity)
Select OrderDate, StockDate, OrderNumber, ProductKey, CustomerKey, TerritoryKey, OrderLineItem, OrderQuantity from AdventureWorks_Sales_2017;

Select * 
FROM merged_AdventuresWorks_sales;

--CREATE A DATA STAR SCHEMA WITH RELATIONSHIP BETWEEN TABLES.
/* Star Schema consist of the Fact and dimension table
Fact table in this DATABASE tables is the merged_AdventuresWorks_sales because it contains the sales data and it also references other tables known as the dimension table
while dimension table includes AdventureWorks_Product_Categories,AdventureWorks_Product_Subcategories,AdventureWorks_Territories,AdventureWorks_Calendar*/

--I manually generated a new column containing the ROW_ID column so as to get a Primary key
ALTER TABLE AdventureWorks_Calendar ADD COLUMN DATE_ID INTEGER;
UPDATE AdventureWorks_Calendar SET DATE_ID = ROWID;

--I manually generated a new column containing the ROW_ID column so as to get a Primary key
ALTER TABLE merged_AdventuresWorks_sales ADD COLUMN ROW_ID INTEGER;
UPDATE merged_AdventuresWorks_sales SET ROW_ID = ROWID;

/*I joined the merged_AdventuresWorks_sales to the AdventureWorks_Products table to establish
a relationship with the AdventureWorks_Product_Subcategories and AdventureWorks_Product_Categories table */
pragma table_info(merged_AdventuresWorks_sales);
pragma table_info(AdventureWorks_Products);
SELECT 
	t1.OrderDate,
	t1.StockDate,
	t1.OrderNumber,
	t1.CustomerKey,
	t1.TerritoryKey,
	t1.OrderLineItem,
	t1.OrderQuantity,
	t1.ROW_ID,
	t2.ProductSubcategoryKey,
	t2.ProductSKU,
	t2.ProductName,
	t2.ModelName,
	t2.ProductDescription,
	t2.ProductColor,
	t2.ProductSize,
	t2.ProductStyle,
	t2.ProductCost,
	t2.ProductPrice
FROM
	merged_AdventuresWorks_sales AS t1
JOIN
	AdventureWorks_Products AS t2
ON
	t1.ProductKey = t2.ProductKey;
--I exported the table generated into csv and saved on my local computer
--I added the exported table into the database and linked it to the AdventureWorks_Product_Subcategories table to establish a relationship since there is a common COLUMN
pragma table_info(AdventureWorks_Product_Subcategories);
SELECT 
	t1.OrderDate,
	t1.StockDate,
	t1.OrderNumber,
	t1.CustomerKey,
	t1.TerritoryKey,
	t1.OrderLineItem,
	t1.OrderQuantity,
	t1.ROW_ID,
	t1.ProductSKU,
	t1.ProductName,
	t1.ModelName,
	t1.ProductDescription,
	t1.ProductColor,
	t1.ProductSize,
	t1.ProductStyle,
	t1.ProductCost,
	t1.ProductPrice,	
	t2.SubcategoryName,
	t2.ProductCategoryKey
FROM
	Merged_AdventureWorks_DataandAdventureWorks_Products AS t1
JOIN	
	AdventureWorks_Product_Subcategories AS t2
ON
	t1.ProductSubcategoryKey = t2.ProductSubcategoryKey;
-- Relationship established between all tables now
/* THE FACT TABLE IS THE NEWLY CREATED TABLE Merged_AdventureWorks_Data_ProductsandAdventureWorks_Product_Subcategories, 
IT CONNECTS ALL THE TABLES TOGETHER*/

