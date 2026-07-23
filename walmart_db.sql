
-- Walmart pProject Queries

SELECT * FROM walmart;

--SELECT COUNT(*) FROM walmart;

DROP TABLE walmart;

-- Business Problems 

--1 Find different payment method and number of transactions,number of quantity old.

  SELECT payment_method,
  COUNT(*) AS no_payments,
  SUM(quantity) AS no_qty_sold
  FROM walmart
  GROUP BY payment_method

--2 Identity the highest rated category in each branch, displaying the branch,category and average rating.

SELECT * 
FROM
 (  Select
   branch,
   category,
   AVG(rating) AS avg_rating,
   RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
   FROM walmart
   GROUP BY branch,category
   )
   WHERE  rank = 1

--3 Identify the busiest day for each branch based on the number of tranctions.

  SELECT * 
  FROM 
  ( SELECT 
  branch,
  TO_CHAR(TO_DATE(date,'DD/MM/YY'), 'Day') AS day_name,
  COUNT(*) AS no_transactions,
  RANK() OVER(PARTITION BY branch ORDER BY  COUNT(*) DESC) AS rank
  FROM walmart
  GROUP BY 1,2)
	WHERE rank = 1


 --4 Calculate the total quantity of items sold per payment method.List payment_method and total_quantity.

 SELECT payment_method,
  
  SUM(quantity) AS no_qty_sold
  FROM walmart
  GROUP BY payment_method

--5 Determine the average ,minimum ,and maximum rating of category for each city.List the city ,average_rating , and max_rating.

    Select 
	city,
	category,
	MIN(rating) AS min_rating,
	MAX(rating) AS max_rating,
	AVG(rating) AS avg_rating
	FROM walmart
	GROUP BY 1,2


--6 Calculate the total profit for each category by considering total_profit as unit_price * quantity * profit_margin.
-- List category and total_profit, ordered from highest to loest profit.

   SELECT
   category,
   SUM(total) AS total_revenue,
   SUM(total * profit_margin) AS profit
   FROM walmart
   GROUP BY 1

--7 Determine the most common payment method for each branch. 
--Display branch and the preferred_payment-method.
WITH cte
AS
  ( SELECT 
   branch,
   payment_method,
   COUNT(*) AS total_trans,
   RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
   FROM walmart
   GROUP BY 1,2
   )
   SELECT * FROM cte
   WHERE rank = 1

--8 Categorize sales into 3 group morning,afternoon,evening
--Find out each of the shift and number of invoices.

 SELECT
 branch,
  CASE
       WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
	   WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
	   ELSE 'Evening'
	 END day_time,
	 COUNT(*)
	 FROM walmart
	 GROUP BY 1,2
	 ORDER BY 1,3 DESC

--9 Identify the 5 branch with highest decrese ratio in revenue compare to last year(current year 2023 and last year 2022)
-- Revenue decrese ratio = last year rev - current year rev/last year rev *100
 -- revenue decrease ratio(rdr) = last_rev - current_rev / last_rev *100

  --2022 sales
  WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY 1
), 
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY 1
)
SELECT 
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS cr_year_revenue,
	ROUND(
	(ls.revenue - cs.revenue)::numeric / ls.revenue ::numeric * 100 ,2) AS rev_dec_ratio
	
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5
