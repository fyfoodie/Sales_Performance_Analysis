# Sales Analysis Performance

**Dataset Created By:** [YouTube](https://www.youtube.com/@datatutorials1)
**Dataset:** [blinkit_data.csv](https://drive.google.com/drive/folders/1VYDaziCCvS9sEeMpF9OfdfGG17U0Ajmb)

---

## Introduction  

This SQL project is based on the **Blinkit Dataset** featured in a YouTube tutorial.  

This repository provides an SQL analysis of retail sales transactions to explore insights such as:  
- Sales distribution by category and time  
- Customer purchasing patterns  
- Revenue trends and performance  

The dataset is hosted in MySQL Workbench, where SQL queries are used to clean, analyze, and summarize the data.  

The aim of this analysis is to gain useful business insights from retail transactions and practice SQL techniques for data analytics.  

---

## SQL Analysis

### Total Sales by Fat Content  

```sql
SELECT Item_Fat_Content, SUM(Total_Sales) AS total_sales
FROM blinkit_grocery
GROUP BY Item_Fat_Content
ORDER BY total_sales DESC;
```

```md
| Item_Fat_Content | total_sales        | 
|------------------|--------------------|
| Low Fat          | 776319.6784000006  | 
| Regular          | 425361.8023999995  | 
```
<img width="542" height="504" alt="download (1)" src="https://github.com/user-attachments/assets/ef022fa5-806b-4806-bc65-c1ae75209930" />

### Total Sales by Item Type
```sql
SELECT Item_Type, SUM(Total_Sales) AS total_sales
FROM blinkit_grocery
GROUP BY Item_Type
ORDER BY total_sales DESC
LIMIT 5;
```

```md
| Item_Type              | total_sales         | 
|------------------------|---------------------|
| Fruits and Vegetables  | 178124.08099999995  | 
| Snack Foods            | 175433.92040000024  | 
| Household              | 135976.52539999998  | 
| Frozen Foods           | 118558.88140000009  |
| Dairy                  | 101276.45959999996  |
```

<img width="989" height="590" alt="download (2)" src="https://github.com/user-attachments/assets/7f3bd222-f417-4258-9fcc-9e1083fee3ff" />

### Fat Content by Outlet for Total Sales
```sql
SELECT Outlet_Type AS OutletType,
    SUM(CASE WHEN Item_Fat_Content = 'Low Fat' THEN Total_Sales ELSE 0 END) AS Low_Fat,
    SUM(CASE WHEN Item_Fat_Content = 'Regular' THEN Total_Sales ELSE 0 END) AS Regular
FROM blinkit_grocery
GROUP BY Outlet_Type
ORDER BY Outlet_Type DESC;
```

```md
| OutletType         | Low_Fat            | Regular            |
|--------------------|--------------------|--------------------|
| Supermarket Type3  | 83774.41099999996  | 46940.26360000005  |
| Supermarket Type2  | 84844.60699999995  | 46633.16540000002  |
| Supermarket Type1  | 507886.2953999999  | 279663.5913999997  |
| Grocery Store      | 99814.36499999993  | 52124.78200000001  |
```

<img width="989" height="590" alt="download (3)" src="https://github.com/user-attachments/assets/49b9929a-9e46-4281-a0ab-74b61903017c" />

###  Total Sales by Outlet Establishment Year
```sql
SELECT Outlet_Est_Year AS Year,
    SUM(Total_Sales) AS Total_Sales,
	CAST(AVG(Total_Sales) AS DECIMAL(10,1)) AS Avg_Sales,
    COUNT(*) AS No_Of_Items,
    CAST(AVG(Rating) AS DECIMAL(10,2)) AS Avg_Rating
FROM blinkit_grocery
GROUP BY Outlet_Est_Year
ORDER BY Outlet_Est_Year ASC;
```

```md
| Year | Total_Sales        | Avg_Sales | No_Of_Items | Avg_Rating |
|------|--------------------|-----------|-------------|------------|
| 1998 | 204522.25700000025 | 139.8     | 1463        | 3.97       |
| 2000 | 131809.01560000007 | 141.4     | 932         | 3.95       |
| 2010 | 132113.36980000007 | 142.1     | 930         | 3.96       |
| 2011 | 78131.56459999997  | 140.8     | 555         | 3.98       |
| 2012 | 130476.85979999998 | 140.3     | 930         | 3.99       |
| 2015 | 130942.77819999999 | 141.0     | 929         | 3.96       |
| 2017 | 133103.9069999999  | 143.1     | 930         | 3.94       |
| 2020 | 129103.95639999988 | 139.4     | 926         | 3.98       |
| 2022 | 131477.77239999996 | 141.7     | 928         | 3.97       |
```

<img width="799" height="470" alt="download (4)" src="https://github.com/user-attachments/assets/f12d2857-6501-4dde-924b-08447d595638" />


## Percentage of sales by outlet size
```sql
SELECT Outlet_Size,  SUM(Total_Sales) AS Total_Sales, 
    ROUND(
        (SUM(Total_Sales) * 100.0) / (SELECT SUM(Total_Sales) FROM blinkit_grocery), 2 
    ) AS Sales_Percentage
FROM blinkit_grocery
GROUP BY Outlet_Size
ORDER BY Total_Sales DESC;
```
 
```md
| Outlet_Size | Total_Sales  | Sales_Percentage |
|-------------|--------------|------------------|
| Medium      | 507895.73    | 42.27%           |
| Small       | 444794.17    | 37.01%           |
| High        | 248991.58    | 20.72%           |
```
<img width="504" height="504" alt="download (5)" src="https://github.com/user-attachments/assets/715d4866-69b0-4d83-aab3-a37109ffaad3" />


## all metrics by outlet_type
```sql
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
```

```md
| Outlet_Type        | TotalSales     | Sales_Percentage | Avg_Sales | No_Of_Items | Avg_Rating |
|--------------------|----------------|------------------|-----------|-------------|------------|
| Supermarket Type1  | 787549.89      | 65.54%           | 141.2     | 5577        | 3.96       |
| Grocery Store      | 151939.15      | 12.64%           | 140.3     | 1083        | 3.99       |
| Supermarket Type2  | 131477.77      | 10.94%           | 141.7     | 928         | 3.97       |
| Supermarket Type3  | 130714.67      | 10.88%           | 139.8     | 935         | 3.95       |  
```


