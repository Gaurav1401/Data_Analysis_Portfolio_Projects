SELECT *
FROM DiscountMart.dbo.discountmart;

------------------------------------------------------------------------------------------------
-- Converintg Datetime to Date Format
SELECT "Order Date", "Ship Date", CONVERT(DATE, "Order Date"), CONVERT(DATE, "Ship Date")
FROM DiscountMart.dbo.discountmart;

ALTER TABLE DiscountMart.dbo.discountmart
ADD Order_Date DATE;
UPDATE DiscountMart.dbo.discountmart
SET Order_Date = CONVERT(DATE, "Order Date");

ALTER TABLE DiscountMart.dbo.discountmart
ADD Ship_Date DATE;
UPDATE DiscountMart.dbo.discountmart
SET Ship_Date = CONVERT(DATE, "Ship Date");

-- Deleting the datetime columns
ALTER TABLE DiscountMart.dbo.discountmart
DROP COLUMN "Order Date", "Ship Date";

SELECT Ship_Date, Order_Date, "Order Date", "Ship Date"
FROM DiscountMart.dbo.discountmart;

--------------------------------------------------------------------------------------------------------
-- Checking different types of Ship Mode :)
SELECT DISTINCT("Ship Mode") 
FROM DiscountMart.dbo.discountmart; 

-- Checking the number of products having different mode of shipping
SELECT "Ship Mode", COUNT(*) AS "No. of products"
FROM DiscountMart.dbo.discountmart
GROUP BY "Ship Mode"; 

-- Average sales of the products who were shipped differently
ALTER TABLE DiscountMart.dbo.discountmart
ADD Total_Sales FLOAT;
UPDATE DiscountMart.dbo.discountmart
SET Total_Sales = Sales * Quantity;

SELECT Total_Sales
FROM DiscountMart.dbo.discountmart;

SELECT "Ship Mode", ROUND(AVG(Total_Sales), 2) AS "Avg Sales"
FROM DiscountMart.dbo.discountmart
GROUP BY "Ship Mode"
ORDER BY 2 DESC; -- Second Class is giving the maximum sale :(

SELECT "Ship Mode", SUM(Quantity) AS "Quantity"
FROM DiscountMart.dbo.discountmart
GROUP BY "Ship Mode"
ORDER BY 2 DESC;  -- Most number of products are being shipped by Standard Class

--------------------------------------------------------------------------------------------------------------

-- Top 10 Highly demanded products
SELECT TOP 10
	"Product Name", SUM(Quantity) AS "Demand"
FROM DiscountMart.dbo.discountmart
GROUP BY "Product Name"
ORDER BY 2 DESC;

--------------------------------------------------------------------------------------------------------------
 
SELECT DISTINCT "Country/Region"
FROM DiscountMart.dbo.discountmart; -- This record only belongs to US

-- Most demanded products in each state
SELECT State,"Product Name", SUM(Quantity) AS "Demand"
FROM DiscountMart.dbo.discountmart
GROUP BY State, "Product Name"
ORDER BY 1 ASC,3 DESC;

-- Average revenue that the country is generating from each state
SELECT State, ROUND(AVG(Total_Sales), 2)
FROM DiscountMart.dbo.discountmart
GROUP BY State
ORDER BY 2 DESC;

----------------------------------------------------------------------------------------------------------------

SELECT DISTINCT Region
FROM DiscountMart.dbo.discountmart; 

-- Which region has how much sales and how many customers
SELECT Region, COUNT("Row ID") AS "No. of Sales", COUNT(DISTINCT "Customer ID") AS "No. of Customers"
FROM DiscountMart.dbo.discountmart
GROUP BY Region
ORDER BY 2 DESC, 3 DESC; -- West has both maximum no.of sales and customers

-- Which region has how many cities
SELECT Region, COUNT(DISTINCT City) AS "No. of Cities"
FROM DiscountMart.dbo.discountmart
GROUP BY Region
ORDER BY 2 DESC; -- Central Region has maximum no. of cities


-----------------------------------------------------------------------------------------------------
-- Products of which category are in Demand
SELECT DISTINCT Category, SUM(Quantity) AS Quantity
FROM DiscountMart.dbo.discountmart
GROUP BY Category
ORDER BY 2 DESC; --		Office Suplies have maximum demand

-- Which category is responsible for maximum average sales
SELECT DISTINCT Category, ROUND(AVG("Total_Sales"), 2) AS Avg_Sales
FROM DiscountMart.dbo.discountmart
GROUP BY Category
ORDER BY 2 DESC;

-- 