# L&D-Sales-Performance-Tracking
## Case Study
### Company Background:
 L&D Superstore is a major retail company that operates across different locations, delivering a varied selection
 of products to various consumer segments. The company has built a strong presence in the regions. L&D takes
 pride in providing excellent customer service and a smooth shopping experience.
 
 ### My Task as an Analyst:
 I have been entrusted with performing a thorough analysis of L&D sales data in My capacity as a data
 analyst. Gaining important insights into a range of business variables, such as profitability, business
 performance, and product and customer specifics, is the goal.


## Data Source
Superstore.csv Dataset : This dataset contains all the  informations about sales, customers, products sold, locations where sales were made and some key metrics such as Sales, profits etc.

## Tool Used
SQL

## Data Preparation
In the initial data preparation phase, the following task were performed:
- Data Loading and inspection.
- Normalized the main table by splitting it into Facttable and Dimension Tables.
- I extracted the Location ID from the columns containing combnations of state and Location ID to form a new column.
- Created a new table for date named DimCalender.
- Created an ERD with the table in the database.

## Data Exploratory Analysis
#### 1.Profitability Analysis: Determine which product category generate the most profit for the company and also the segmentwith the highest avaerage salary . Identify the top 5 Customers contributing to the highest profits. Explore strategies to retain and further engage valuable customer.

  ```sql
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
```

#### 2.Product Analysis: Present the total number of products by category and subcategory highlighting any notable patterns or discrepancies.
```sql
SELECT 
  dp.Category,
  dp.Sub_Category,
  COUNT(dp.Product_ID) AS Total_Products

FROM LD_Facttable AS ldf
LEFT JOIN DimProduct AS dp
ON ldf.Product_ID = dp.Product_ID

GROUP BY dp.Category, dp.Sub_Category
ORDER BY Total_Products DESC;
```
#### Geographical Analysis: Examine the top 5 Cities in which the business generated the most and least revenue. Suggest methods for raising sales in areas where they were low.
```sql
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
```

####  3.Sales team Performance: Evaluate the performance of sales rep based on the sales made, and identifythe sales team with the highest and lowest sales. Recommend strategies to help the sales reps perform better.
```sql
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
```

#### 4.Shipment analysis: Determine which ship mode get the highest percentage of orders shipped and the number of ship days.
```sql
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
```

## Recommendations
- Providing incentives, such as discounts to motivate customers and increase sales in underperforming locations.
- Collecting feedback from customers in low-sales areas for a better understanding of their needs, enabling more effective strategy adjustments.
- Performing a location analysis to uncover key factors behind low sales, including demographic trends and local economic conditions.
- Creating targeted marketing campaigns that reflect the demographics and preferences of the area with low sales can enhance effectiveness.
- Offering additional sales training or support to the sales team in the low-sales area to improve their performance.
- Ensuring sufficient inventory levels and product availability to prevent missed sales opportunities in the low-sales region.
- Examining competitors' strategies in the low-sales area to highlight potential areas for improvement or ways to differentiate.
- Looking into cross-promotion opportunities to boost visibility and draw more customers to the low-sales area.
- Implementing technology such as data analytics or CRM systems to optimize processes and increase efficiency in the low-sales region.
- Regularly monitoring sales performance and adjusting strategies as necessary for driving improvements in the low-sales area.


## Challenge
Only challenge faced was when trying to debug an error not knowing it was caused by me not adding commas and semi colon at the neccessary places.


