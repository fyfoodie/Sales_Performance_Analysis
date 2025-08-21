/*
Business Requirement : 
to conduct a comprehensive analysis on Blinkit's sales performance, customer satisfaction, 
and inventory distrubution to identify key insights and opportunities for optimization using various 
KPI's and visualisation in Power BI

KPI's requirement
1. total sales : the overall revenue generate from all items sold
2. average sales : the average revenue
3. number of items :  the total count of diff items sold
4. average rating : the average customer rating for items sold 

Granular Requirements
1. total sales by fat content
obj : analyxe the impact of fat content on total sales
additional kpi metrics : assess how other KPs (avg sale, no of items, avg rating) vary with fat content

2. total sales by item type ; 
obj : identify the performance of diff item types in terms of total sales
add kpi  metrics : "

3. fat content by outlet for total sales 
obj : compare total sales across diff outlets segmented by fat content

4. total sales by outlet establishment
- evaluate the age or type of outlet establisment influense total sales

5. Percentage of sales by outlet size
- analyze the corr btween outlet size and total sales

6. sales by outlet location
- assess the geographic dist of sales across diff location

7. all metrics by outlet type
- provise a comprehensive view of all key metrics (total sales, avg sales, no of items, avg rating) 
  broken down by diff outlets types
 */

--
/*created the table manually instead of using the import wizard. 
This allowed me to handle empty numeric fields by converting them to NULL during import.
*/

-- DATA LOADING
USE blinkit_analysis;

CREATE TABLE blinkit_grocery (
    Item_Fat_Content       TEXT,
    Item_Identifier        TEXT,
    Item_Type              TEXT,
    Outlet_Est_Year        INT,
    Outlet_Identifier      TEXT,
    Outlet_Location_Type   TEXT,
    Outlet_Size            TEXT,
    Outlet_Type            TEXT,
    Item_Visibility        DOUBLE,
    Item_Weight            DOUBLE,
    Total_Sales            DOUBLE,
    Rating                 DOUBLE
);

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.4/Uploads/BlinkIT_Grocery.csv'
INTO TABLE blinkit_grocery
FIELDS TERMINATED BY ',' 
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(
    Item_Fat_Content,
    Item_Identifier,
    Item_Type,
    Outlet_Est_Year,
    Outlet_Identifier,
    Outlet_Location_Type,
    Outlet_Size,
    Outlet_Type,
    Item_Visibility,
    @Item_Weight,
    Total_Sales,
    Rating
)
SET Item_Weight = NULLIF(@Item_Weight, '');

-- all rows imporyed successfully
SELECT COUNT(*) 
FROM blinkit_grocery;

SELECT * FROM blinkit_grocery;

DESCRIBE blinkit_grocery;

-- DATA CLEANING
-- change LF and reg
SELECT DISTINCT Outlet_Location_Type
FROM blinkit_grocery 
ORDER BY 1;

UPDATE blinkit_grocery
SET Item_Fat_Content = 'Low Fat'
WHERE Item_Fat_Content IN ('low fat', 'LF');

UPDATE blinkit_grocery 
SET Item_Fat_Content = 'Regular'
WHERE Item_Fat_Content IN ('reg', 'Regular');

SELECT *FROM blinkit_grocery;

-- check for null values
SELECT DISTINCT Item_Weight
FROM blinkit_grocery 
ORDER BY 1 DESC;

-- theres 1463 null out of 8263
-- item_weight is not important for sales analysis so no need remove
SELECT COUNT(*) AS null_count
FROM blinkit_grocery
WHERE Item_Weight IS NULL;

-- EDA
-- -----------------------------------------------------------------------
-- total sales by fat content
-- Low Fat	776319.6784000006, Regular	425361.8023999995
-- low fat has more sales than regular one, consumer prefers low fat for health 
SELECT Item_Fat_Content, SUM(Total_Sales) AS total_sales
FROM blinkit_grocery
GROUP BY Item_Fat_Content
ORDER BY total_sales DESC;

-- total sales by item type
-- fruit n vege has competative total sales with snacks. followed by households items.
-- seafood has the lowest total sales
SELECT Item_Type, SUM(Total_Sales) AS total_sales
FROM blinkit_grocery
GROUP BY Item_Type
ORDER BY total_sales DESC
LIMIT 5;

SELECT Item_Type,
    CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2)) AS total_sales,
    CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_grocery
GROUP BY Item_Type
ORDER BY total_sales DESC;
 
-- --------------- fat content by outlet for total sales 
SELECT Item_Fat_Content, Outlet_Type, SUM(Total_Sales) AS total_sales
FROM blinkit_grocery
GROUP BY Item_Fat_Content, Outlet_Type
ORDER BY total_sales DESC;

SELECT Outlet_Location_Type, Item_Fat_Content,
    CAST(SUM(Total_Sales)/1000 AS DECIMAL(10,2)) AS total_sales
FROM blinkit_grocery
GROUP BY Outlet_Location_Type, Item_Fat_Content
ORDER BY total_sales DESC;

-- change tier 1,2,3 as rows and make itemfatcontent as the column
-- this this the pivot table style 
SELECT Outlet_Type AS OutletType,
    SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Total_Sales ELSE 0 END) AS Low_Fat,
    SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Total_Sales ELSE 0 END) AS Regular
FROM blinkit_grocery
GROUP BY Outlet_Type
ORDER BY Outlet_Type DESC;

-- tier 3 low fat has the hiighest sales overall
-- low fat for all tier has higher sales than regular fat
-- tier 1 for regular has the lowest sales
SELECT Outlet_Location_Type AS Tier,
    SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Total_Sales ELSE 0 END) AS Low_Fat,
    SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Total_Sales ELSE 0 END) AS Regular
FROM blinkit_grocery
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type DESC;

-- --------------- total sales by outlet establishment
SELECT 
    MIN(Outlet_Est_Year) AS Earliest_Year,
    MAX(Outlet_Est_Year) AS Latest_Year
FROM blinkit_grocery;

-- total sales per year
-- almost constant sales throught out year 1998 to 2022
SELECT Outlet_Est_Year AS Year,
    SUM(Total_Sales) AS Total_Sales,
	CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_grocery
GROUP BY Outlet_Est_Year
ORDER BY Outlet_Est_Year ASC;

-- total sales per year per outlet type
SELECT Outlet_Type, Outlet_Est_Year AS Year,
    SUM(Total_Sales) AS Total_Sales
FROM blinkit_grocery
GROUP BY Outlet_Type, Outlet_Est_Year
ORDER BY Outlet_Est_Year;

-- ---------------- Percentage of sales by outlet size
/* medium sized outlet has the highest sales perc contrary to high outlet size which has the 
   lowest sales perc */
   
SELECT Outlet_Size,  SUM(Total_Sales) AS Total_Sales, -- total sales for every Outlet_Size 
    ROUND(
        (SUM(Total_Sales) * 100.0) / (SELECT SUM(Total_Sales) FROM blinkit_grocery),  
        -- divide w overall total sales (dari subquery) 
        -- to get % contribution for every Outlet_Size
        2 -- round to 2 decimal places
    ) AS Sales_Percentage
FROM blinkit_grocery
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;

-- ----------------- sales by outlet location
-- tier 3 is topping the total sales followed by tier 2 and tier 1
SELECT Outlet_Location_Type, SUM(Total_Sales) AS TotalSales
FROM blinkit_grocery
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;

-- specific year
SELECT Outlet_Location_Type, SUM(Total_Sales) AS TotalSales
FROM blinkit_grocery
WHERE Outlet_Est_Year = 2020
GROUP BY Outlet_Location_Type
ORDER BY Outlet_Location_Type;		

-- ----------- all metrics by outlet_type
-- supermarket type 1 dominate the overall sales which over 65% compared to other like 12% and 10%
-- they have sold 5577 items 
-- however all supermakret has almost simlar rating like 3.96, 3.99, 3.97 and 3.95
SELECT 
    Outlet_Type,         
    SUM(Total_Sales) AS TotalSales,        
    ROUND((SUM(Total_Sales) * 100.0) / (SELECT SUM(Total_Sales) FROM blinkit_grocery), 2) AS Sales_Percentage,        
    CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,        
    COUNT(*) AS No_Of_Items,        
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating 
FROM blinkit_grocery 
GROUP BY Outlet_Type 
ORDER BY TotalSales DESC;

