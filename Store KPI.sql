-- First we can take a look at the data we are going to start with

SELECT TOP 10 * FROM coffee_shop..sales;

-- We will use this information to find the busiest hours for the business, averaged across all sites

SELECT DATEPART(HOUR, transaction_time) AS hours, COUNT(transaction_id) AS transactions, SUM(line_item_amount) AS total_sales 
FROM sales
GROUP BY DATEPART(HOUR, transaction_time)
ORDER BY hours;

-- This shows that we have 5 hours early in the morning, where business is very slow.
-- Are all outlets open? Are they open daily at this time? We can drill into this.

SELECT DATEPART(HOUR, transaction_time) AS hours, COUNT(DISTINCT DATEPART(DAY, transaction_date)) AS day, 
COUNT(transaction_id) AS transactions, COUNT(DISTINCT sales_outlet_id) AS stores_open, SUM(line_item_amount) AS total_sales 
from sales
GROUP BY DATEPART(HOUR, transaction_time)
ORDER BY hours;

-- We can see that just one store was open in the early hours, on one day. We will eliminate this from further analysis
-- as it is erroneous, possibly for a special event. 

SELECT DATEPART(HOUR, transaction_time) AS hours, COUNT(DISTINCT DATEPART(DAY, transaction_date)) AS day, 
COUNT(transaction_id) AS transactions, COUNT(DISTINCT sales_outlet_id) AS stores_open, SUM(line_item_amount) AS total_sales 
from sales
GROUP BY DATEPART(HOUR, transaction_time) 
HAVING COUNT(DISTINCT DATEPART(DAY, transaction_date)) > 1
ORDER BY hours

-- Using this data, we are able to calculate useful KPI data, such as Average Daily Transactions, Average Transaction Value (ATV)
-- on a per store basis

with cte as(
SELECT DATEPART(HOUR, transaction_time) AS hours, COUNT(DISTINCT DATEPART(DAY, transaction_date)) AS day, 
COUNT(transaction_id) AS transactions, COUNT(DISTINCT sales_outlet_id) AS stores_open, SUM(line_item_amount) AS total_sales 
from sales
GROUP BY DATEPART(HOUR, transaction_time) 
HAVING COUNT(DISTINCT DATEPART(DAY, transaction_date)) > 1

)
select hours, total_sales/transactions AS ATV, (transactions/stores_open)/day AS hourly_transactions  from cte