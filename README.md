# L&D-Sales-Performance-Tracking
## Case Study
### Company Background:
 L&D Superstore is a major retail company that operates across different locations, delivering a varied selection
 of products to various consumer segments. The company has built a strong presence in the regions. L&D takes
 pride in providing excellent customer service and a smooth shopping experience.
 
 ### MY Task as an Analyst:
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
 - Profitability Analysis: Determine which product category generate the most profit for the company and also the segment
   with the highest avaerage salary . Identify the top 5 Customers contributing to the highest profits.
   Explore strategies to retain and further engage valuable customer.

  ```  SELECT 
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

--The top 5 customers contributing to the highest profits are in this order; Tamara Chand,Raymond Buch, Sanjit Chand,Hunter Lopez,Adrian Barton.```


- Product Analysis: Present the total number of products by category and subcategory highlighting any notable patterns or discrepancies.






