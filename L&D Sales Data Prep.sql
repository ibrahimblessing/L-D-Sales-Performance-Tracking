CREATE Database LD_Retails;

USE LD_Retails;
SELECT * FROM [L & D Sales Dataset - Csv];


/*Split data into Facts and dimension tablesand also form a ERD with them.
The dimension tables to be created are DimCustomers,DimProduct 
and DimLocation*/

--Creating the DimCustomer
SELECT * INTO DimCustomer
FROM 
	(SELECT
		Customer_ID,
		Customer_Name
	FROM [L & D Sales Dataset - Csv]
	)
AS DimC;
--To view data in the DimCustomer table
SELECT * FROM DimCustomer;

--To remove duplicates from the DimCustomer Table
With CTE AS (
	SELECT 
	*,
	ROW_NUMBER () OVER (PARTITION BY
		Customer_ID,
		Customer_Name
		ORDER BY Customer_ID
		) AS ROWNUM
FROM DimCustomer
)

--Delete Duplicate rowswhere RowNum >1 (Keeping only the first Occurence.
DELETE FROM CTE WHERE ROWNUM >1;

DROP TABLE DimLocation;
--Creating the DimLocation Table
SELECT * INTO DimLocation
FROM 
	(SELECT 
		Location_ID,
		City,Location_ID
		State,
		Postal_Code,
		Region
		FROM [L & D Sales Dataset - Csv]
		WHERE Postal_Code <> 92024
	)
AS DimL;
--To view DimLocation table
SELECT * FROM DimLocation;

--Extracting the Location_ID from the location_ID Column since it contains both IDs and City names.
ALTER TABLE DimLocation
ADD Location_IDD VARCHAR(10);


UPDATE DimLocation
SET
	Location_IDD = SUBSTRING(Location_ID,1,CHARINDEX(',',Location_ID)-1);

--To drop the Location_ID Column
ALTER TABLE DimLocation
DROP COLUMN Location_ID;

--To remove duplicates from the DimLocation Table.
With CTE AS (
	SELECT 
	*,
	ROW_NUMBER () OVER (PARTITION BY
		Location_IDD,
		City,
		State,
		Postal_Code,
		Region
		ORDER BY Location_IDD
		) AS ROWNUM
FROM DimLocation
)

--Delete Duplicate rowswhere RowNum >1 (Keeping only the first Occurence.
DELETE FROM CTE WHERE ROWNUM >1;



--Creating DimProduct Table
SELECT * INTO DimProduct
FROM 
	(SELECT	
		Product_ID,
		Category,
		Sub_Category,
		Product_Name
	FROM [L & D Sales Dataset - Csv]
	)
	AS DimP;
		
--To remove duplicates from the dimProduct
With CTE AS (
	SELECT 
	*,
	ROW_NUMBER () OVER (PARTITION BY
		Product_ID,
		Category,
		Sub_Category,
		Product_Name
		ORDER BY Product_ID
		) AS ROWNUM
FROM DimProduct
)

DELETE FROM CTE WHERE ROWNUM >1;

--To view table
SELECT * FROM DimProduct;


--Creating a RollingCalendar Table
CREATE TABLE RollingCalendar
	(Date DATE PRIMARY KEY NOT NULL,
	Year SMALLINT,
	Quarter TINYINT,
	Month TINYINT,
	MonthName VARCHAR(10),
    DayOfWeek TINYINT,
	Day TINYINT,
    DayName VARCHAR(10),
);

-- Declare variables for data range
DECLARE @StartDate DATE = '2014-01-01';
DECLARE @EndDate DATE = '2017-12-31';


-- To populate the Date Dimension Table
WITH DateSeries AS (
    -- Anchor member
    SELECT 
        @StartDate AS Date
    UNION ALL 
    -- Recursive member
    SELECT 
        DATEADD(DAY, 1, Date)
    FROM DateSeries
    WHERE Date < @EndDate
)

-- Insert into RolingCalender table
INSERT INTO RollingCalendar
SELECT
    Date,
    YEAR(Date) AS Year,
	DATEPART(QUARTER, Date) AS Quarter, -- Changed from DATENAME to DATEPART for numeric quarter
	MONTH(Date) AS Month,
	DATENAME(MONTH, Date) AS MonthName,
    DATEPART(WEEKDAY, Date) AS DayOfWeek,
	DAY(Date) AS Day,
    DATENAME(WEEKDAY, Date) AS DayName
  
  FROM DateSeries
OPTION (MAXRECURSION 0);

--To view RollingCalender
SELECT * FROM RollingCalendar;


DROP TABLE LD_Facttable;
--To create the factTable
SELECT * INTO LD_Facttable
FROM
	(SELECT 
	Order_ID,
	Order_Date,
	Ship_Date,
	Ship_Mode,
	Customer_ID,
	Segment,
	Sales_Rep,
	Sales_Team_Manager,
	Location_ID,
	Product_ID,
	ROUND(Sales, 2) AS Sales,
	Quantity,
	ROUND(Discount, 2) AS Discount,
	ROUND(Profit, 2) AS Profit
	FROM [L & D Sales Dataset - Csv]
	WHERE Postal_Code<>92024
	)
AS LDFact;

--View the facttable
SELECT * FROM LD_Facttable;

--Extracting the Location_ID from the location_ID Column since it contains both IDs and City names.
ALTER TABLE LD_Facttable
ADD LocationID VARCHAR(10);

UPDATE LD_Facttable
SET
	LocationID = SUBSTRING(Location_ID,1,CHARINDEX(',',Location_ID)-1);

ALTER TABLE LD_Facttable
DROP COLUMN Location_ID;

SELECT * FROM DimCustomer;
SELECT * FROM DimProduct;
SELECT * FROM LD_Facttable;

--ANALYSIS
/*Determine which product category generate the most profit for the company and also the segment 
with the highest avaerage salary . Identify the top 5 Customers contributing to the highest profits. 
Explore strategies to retain and further engage valuable customers*/

 SELECT 
	dp.Category,
	SUM(ldf.Profit) AS Total_Profit

FROM LD_Facttable AS ldf
LEFT JOIN DimProduct AS dp
ON ldf.Product_ID = dp.Product_ID

GROUP BY dp.Category
ORDER BY Total_Profit DESC;

--The technology category of product makes the highest profit for the company.

SELECT 
	Segment,
	ROUND(AVG(Profit),3) AS Average_Profit

FROM LD_Facttable
 GROUP BY segment
 ORDER BY Average_Profit DESC;

 --Home Office segment has the highest Average salary

SELECT 
	TOP(5) dc.Customer_Name,
	SUM(ldf.Profit) AS Total_Profit

FROM LD_Facttable AS ldf
LEFT JOIN DimCustomer AS dc
ON ldf.Customer_ID = dc.Customer_ID

GROUP BY dc.Customer_Name
ORDER BY Total_Profit DESC;

--The top 5 customers contributing to the highest profits are in this order; Tamara Chand,Raymond Buch, Sanjit Chand,Hunter Lopez,Adrian Barton.


/*Present the total number of products by category and subcategory*/
SELECT 
	dp.Category,
	dp.Sub_Category,
	COUNT(dp.Product_ID) AS Total_Products

FROM LD_Facttable AS ldf
LEFT JOIN DimProduct AS dp
ON ldf.Product_ID = dp.Product_ID

GROUP BY dp.Category, dp.Sub_Category
ORDER BY Total_Products DESC;



/*Examine the Cities in which the business generated the most and least sales.
 Suggest methods for raising sales in areas where they were low.*/

SELECT 
	TOP(5)dl.City,
	SUM(ldf.Sales) AS Total_Sales

FROM LD_Facttable AS ldf
LEFT JOIN DimLocation AS dl
ON ldf.LocationID = dl.Location_IDD

GROUP BY dl.City
ORDER BY  Total_Sales DESC;
--	Most sales were generated in New York City,Los Angeles, Seatle, San Fransisco and Philadelphia.

SELECT 
	TOP(5)dl.City,
	SUM(ldf.Sales) AS Total_Sales

FROM LD_Facttable AS ldf
LEFT JOIN DimLocation AS dl
ON ldf.LocationID = dl.Location_IDD

GROUP BY dl.City
ORDER BY  Total_Sales ASC;
--The least sales were generated in Abilene, Elyria,Jupiter,Pensacola and Omond Beach.


/*Evaluate the performance of sales REP based on the sales made, and identify
 the sales rep with the highest and lowest sales. Recommend strategies to help the sales rep perform
 better. */

  SELECT 
	TOP(1) Sales_Rep,
	ROUND(SUM(Sales),2) AS Total_Sales
FROM LD_Facttable

GROUP BY Sales_Rep
ORDER BY Total_Sales DESC;
--Organic made the highest sales.

  SELECT 
	TOP(1) Sales_Rep,
	ROUND(SUM(Sales),2) AS Total_Sales
FROM LD_Facttable

GROUP BY Sales_Rep
ORDER BY Total_Sales ASC;
--Jessica Smith made the least Sales.


/*Determine which ship mode get the highest percentage of orders shipped and the
 number of ship days.*/
SELECT 
	Ship_Mode,
	COUNT(Order_ID) AS Total_Orders,
	FORMAT(COUNT(Order_ID) * 100.0 / (SELECT COUNT(*) FROM LD_Facttable),'N2') + '%'  AS  '%Total_Orders'

FROM LD_Facttable
GROUP BY Ship_Mode
ORDER BY  '%Total_Orders' DESC;

SELECT * FROM LD_Facttable;

--Standard Class mode of shipping gets the highest percentage of shipping..


SELECT
	Order_Date,
	Ship_Date,
	DATEDIFF(Day,Order_Date,Ship_Date) AS Shipping_Days

FROM LD_Facttable;

	