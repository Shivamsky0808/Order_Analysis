 USE Order_database;
 
## find top 10 highest reveue generating products
 
SELECT product_id, SUM(sale_price) AS sales
FROM df_orders
GROUP BY product_id
ORDER BY sales DESC
LIMIT 10;

## find top 5 highest selling products in each region
WITH cte AS (
  SELECT region, product_id, SUM(sale_price) AS sales
  FROM df_orders
  GROUP BY region, product_id
)
SELECT *
FROM (
  SELECT *,
    ROW_NUMBER() OVER(PARTITION BY region ORDER BY sales DESC) AS rn
  FROM cte
) a
WHERE rn <= 5;

## find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan

WITH cte AS (
  SELECT YEAR(order_date) AS order_year,
         MONTH(order_date) AS order_month,
         SUM(sale_price) AS sales
  FROM df_orders
  GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month,
       SUM(CASE WHEN order_year = 2022 THEN sales ELSE 0 END) AS sales_2022,
       SUM(CASE WHEN order_year = 2023 THEN sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

## for each category which month had highest sales

WITH cte AS (
  SELECT category,
         DATE_FORMAT(order_date, '%Y%m') AS order_year_month,
         SUM(sale_price) AS sales
  FROM df_orders
  GROUP BY category, DATE_FORMAT(order_date, '%Y%m')
)
SELECT *
FROM (
  SELECT *,
         ROW_NUMBER() OVER(PARTITION BY category ORDER BY sales DESC) AS rn
  FROM cte
) a
WHERE rn = 1;


## which sub category had highest growth by profit in 2023 compare to 2022

WITH cte AS (
  SELECT sub_category, YEAR(order_date) AS order_year,
         SUM(sale_price) AS sales
  FROM df_orders
  GROUP BY sub_category, YEAR(order_date)
), cte2 AS (
  SELECT sub_category,
         SUM(CASE WHEN order_year=2022 THEN sales ELSE 0 END) AS sales_2022,
         SUM(CASE WHEN order_year=2023 THEN sales ELSE 0 END) AS sales_2023
  FROM cte
  GROUP BY sub_category
)
SELECT *,
       (sales_2023 - sales_2022) AS sales_growth
FROM cte2
ORDER BY sales_growth DESC
LIMIT 1;













