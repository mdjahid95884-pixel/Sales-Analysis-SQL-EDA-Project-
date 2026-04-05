-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
                   -- { E-COMMERCE SQL EDA PROJECT }
-- -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*
-- CREATED BY : MOHD JAHID
-- DATE :04/04/2026 

-- ===================================================================================
                       -- # OVERVIEW OF THE DATASET!
-- ===================================================================================

-- <CHECKING THE TABLES INFORMATION FROM THE DATABASE>
SELECT * FROM INFORMATION_SCHEMA.TABLES

-- <CHECKING THE COLUMNS INFORMATION FROM OUR TABLES>
SELECT * FROM INFORMATION_SCHEMA.COLUMNS

-- <CHECKING THE CUSTOMERS WHERE FROM THEY COMES>
SELECT DISTINCT country FROM dim_customers;

-- <CHECKING THE ALL UNIQUE CATEGORIES>
SELECT DISTINCT category FROM dim_products;

-- <CHECKING PRODUCTS DETAILS SUBCATEGORY WISE>
SELECT DISTINCT subcategory,product_name FROM dim_products;

-- <CHECKING THE LATEST AND OLDEST ORDER DATE IN THE TABLE>

SELECT 
    MAX(order_date) AS latest_order,
    MIN(order_date)AS oldest_order 
FROM fact_sales;

-- <FINDING THE YOUNGEST AND OLDEST CUSTOMER>

SELECT 
MIN(birthdate) AS oldest_customer,
DATEDIFF(YEAR,MIN(birthdate),GETDATE()) AS age,
MAX(birthdate) AS youngest_customer,
DATEDIFF(YEAR,MAX(birthdate),GETDATE()) AS age
FROM dim_customers;

-- **_________________ #🔷BASIC_EDA_QUESTIONS ____________________________________________**

-- Find the Total Sales
SELECT 'Total_Sales',SUM(sales_amount)FROM fact_sales
UNION
-- Find how many items are sold
SELECT 'Item_Sold_Count',SUM(quantity) FROM fact_sales
UNION
-- Find the average selling price
SELECT 'Average_Price',AVG(price)FROM fact_sales
UNION
-- Find the Total number of Orders
SELECT 'Total_orders',COUNT(DISTINCT order_number) FROM fact_sales
UNION
-- Find the total number of products
SELECT 'Total_products',COUNT(*) FROM dim_products
UNION
-- Find the total number of customers
SELECT 'Total_customer_count', COUNT(*) AS total_customer_count FROM dim_customers
UNION
-- Find the total number of customers that has placed an order
SELECT 'Total_customers',COUNT(DISTINCT customer_key) FROM fact_sales;

-- CUSTOMER_COUNT COUNTRY WISE
SELECT country,
COUNT(customer_key)AS total_customers
FROM dim_customers
GROUP BY country
ORDER BY total_customers DESC

-- -- CUSTOMER_COUNT GENDER WISE
SELECT gender,
COUNT(customer_key)AS total_customers
FROM dim_customers
GROUP BY gender
ORDER BY total_customers DESC

-- PRODUCT COUNT CATEGORY WISE
SELECT category,
COUNT(product_key)AS total_products
FROM dim_products
GROUP BY category
ORDER BY total_products DESC

-- AVG_PRODUCT_COST CATEGORY WISE
SELECT category,
AVG(cost)AS avg_cost
FROM dim_products
GROUP BY category
ORDER BY avg_cost DESC

-- TOTAL_REVENUE GENTARED BY EACH CATEGORY
SELECT p.category,
SUM(f.price) AS total_revenue
FROM dim_products p
LEFT JOIN fact_sales f 
ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC

-- TOTAL_REVENUE GENTARED BY EACH CUSTOMERS
SELECT c.customer_id,
c.customer_key,
SUM(f.price) AS total_revenue
FROM dim_customers c
LEFT JOIN fact_sales f 
ON c.customer_key = f.customer_key
GROUP BY c.customer_id,c.customer_key
ORDER BY total_revenue DESC

-- TOTAL ITEMS SOLD BY EACH COUNTRY
SELECT c.country,
SUM(f.quantity) AS total_sold_items
FROM dim_customers c
LEFT JOIN fact_sales f 
ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC

-- TOTAL REVENUE GENRATED BY GENDER
SELECT c.gender,
SUM(f.price) AS total_revenue
FROM dim_customers c
LEFT JOIN fact_sales f 
ON c.customer_key = f.customer_key
GROUP BY c.gender
ORDER BY total_revenue DESC


-- -*-*-*-*-*-*-*-*-*-*-*-< 🧠 Advanced EDA Questions >-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*


-- WHICH 5 PRODUCTS GENRATE THE HIGHEST REVENUE ?
SELECT TOP 5 p.product_name,
SUM(f.price) AS total_revenue
FROM dim_products p
JOIN fact_sales f
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC


-- WHICH ARE THE 5 WORST-PERMORING PRODUCT IN TERMS OF SALES ?
SELECT TOP 5 p.product_name,
SUM(f.price) AS total_revenue
FROM dim_products p
JOIN fact_sales f
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue


-- TOP 10  CUSTOMERS WHO HAVE GENRATED THE HIGEST REVENUE
SELECT TOP 10
c.customer_id,
CONCAT(c.first_name,' ',c.last_name) AS name,
SUM(f.price) AS total_revenue
FROM dim_customers c
JOIN fact_sales f 
ON c.customer_key = f.customer_key
GROUP BY c.customer_id,c.first_name,c.last_name
ORDER BY total_revenue DESC

-- 10 WORST CUSTOMER BY REVENUE
SELECT TOP 10
c.customer_id,
CONCAT(c.first_name,' ',c.last_name) AS name,
SUM(f.price) AS total_revenue
FROM dim_customers c
JOIN fact_sales f 
ON c.customer_key = f.customer_key
GROUP BY c.customer_id,c.first_name,c.last_name
ORDER BY total_revenue


-- 10 WORST CUSTOMER BY ORDER_COUNT
SELECT TOP 10
    c.customer_id,
    CONCAT(c.first_name,' ',c.last_name) AS name,
    COUNT(f.order_number) AS ORDER_COUNT
FROM dim_customers c
JOIN fact_sales f 
ON c.customer_key = f.customer_key
GROUP BY c.customer_id,c.first_name,c.last_name
ORDER BY ORDER_COUNT


-- What is the monthly revenue trend over time?
SELECT 
    DATENAME(MONTH,order_date) AS Mnth,
    YEAR(order_date) AS Yrs,
    SUM(price) AS revenue
FROM fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
    YEAR(order_date),
    MONTH(order_date),
    DATENAME(MONTH,order_date)
ORDER BY 
    YEAR(order_date),
    MONTH(order_date);



-- Which months have peak and lowest sales?
WITH month_revenue AS (
    SELECT 
        FORMAT(order_date, 'yyyy-MM') AS month,
        SUM(price) AS revenue
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY FORMAT(order_date, 'yyyy-MM')
)

SELECT *
FROM (
    SELECT *,
        DENSE_RANK() OVER(ORDER BY revenue DESC) AS highest_rank,
        DENSE_RANK() OVER(ORDER BY revenue ASC) AS lowest_rank
    FROM month_revenue
) t
WHERE highest_rank = 1 OR lowest_rank = 1;


-- What is the year-over-year growth in revenue?
WITH yearly_revenue AS (
    SELECT 
        YEAR(order_date) AS yr,
        SUM(price) AS revenue
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY YEAR(order_date))
SELECT 
    yr,
    revenue,
    LAG(revenue) OVER(ORDER BY yr) AS prev_year_revenue,
        CONCAT((revenue - LAG(revenue) OVER(ORDER BY yr)) * 100
        / LAG(revenue) OVER(ORDER BY yr),'%')AS yoy_growth_percentage
FROM yearly_revenue;

-- Month wise running_revenue

SELECT 
month,
revenue,
SUM(revenue) OVER(ORDER BY month) As running_revenue
FROM 
    (SELECT 
    DATETRUNC(MONTH,order_date) AS month,
    SUM(price) As revenue
    FROM fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH,order_date))t

    -- product revenue yearly bases and avg_revenue product wise
    WITH yearly_prd_revenue AS 
    (SELECT 
    p.product_name,
    YEAR(f.order_date) YRs,
    SUM(f.price) AS Revenue
    FROM dim_products p
    JOIN fact_sales f
    ON p.product_key = f.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY p.product_name,
    YEAR(f.order_date))

    SELECT yrs,product_name,revenue,
    AVG(Revenue) OVER(PARTITION BY product_name) AS avg_prd_revenue
    FROM yearly_prd_revenue;

-- category contibution % to the revenue 
WITH cat_revenue AS (SELECT 
    p.category,
    SUM(f.price) AS revenue
    FROM dim_products p
    JOIN fact_sales f
    ON p.product_key = f.product_key
    GROUP BY p.category)

SELECT category,
revenue,
SUM(revenue) OVER()AS total_revenue,
CONCAT((ROUND((CAST(revenue AS FLOAT)/SUM(revenue) OVER()),3) * 100),'%') AS pct_cont
FROM cat_revenue;

-- Customer_segment based on the spend and lifespan and each segment count
WITH customer_lifespan AS 
(SELECT customer_key,
SUM(price) AS total_spend,
DATEDIFF(MONTH,MIN(order_date),MAX(order_date)) AS lifespan
FROM fact_sales
GROUP BY customer_key)

SELECT 
customer_segment,
COUNT(customer_key) AS customer_count
FROM
    (SELECT 
    customer_key,
    total_spend,
    lifespan,
    CASE 
        WHEN lifespan > 12 AND total_spend > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_spend <= 5000 THEN 'NORMAL'
        ELSE 'NEW'
    END AS customer_segment
    FROM customer_lifespan)t
    GROUP BY customer_segment
    ORDER BY customer_count DESC
