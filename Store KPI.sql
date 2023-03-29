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
FROM sales
GROUP BY DATEPART(HOUR, transaction_time)
ORDER BY hours;

-- We can see that just one store was open in the early hours, on one day. We will eliminate this from further analysis
-- as it is erroneous, possibly for a special event. 

SELECT sales_outlet_id, DATEPART(HOUR, transaction_time) AS hours, COUNT(DISTINCT DATEPART(DAY, transaction_date)) AS day, 
COUNT(transaction_id) AS transactions, COUNT(DISTINCT sales_outlet_id) AS stores_open, SUM(line_item_amount) AS total_sales 
FROM sales
GROUP BY DATEPART(HOUR, transaction_time), sales_outlet_id 
HAVING COUNT(DISTINCT DATEPART(DAY, transaction_date)) > 1
ORDER BY hours

-- Taking stock of this data, it is 
-- Using this data, now need to realise that each transaction could have multiple lines, so using a case statement these have
-- been collected together. 
 -- We can now use this to calculate average hourly transactions and transaction values.


WITH grouped_tran AS

(
SELECT transaction_id, transaction_date, sales_outlet_id, DATEPART(HOUR, transaction_time) AS hour, 
CASE WHEN transaction_id = transaction_id AND
 transaction_date = transaction_date AND
 sales_outlet_Id = sales_outlet_id THEN SUM(line_item_amount) END AS sales,

CASE WHEN

 sales_outlet_Id = sales_outlet_id THEN COUNT(transaction_id)/ SUM(DISTINCT DATEPART(DAY, transaction_date)) END AS total_transactions ,

 COUNT(DISTINCT sales_outlet_id) AS stores_open
 FROM sales
 GROUP BY  DATEPART(HOUR, transaction_time), transaction_id, transaction_date, sales_outlet_id, transaction_time

 )
  SELECT sales_outlet_id, hour ,COUNT(total_transactions)/hour/sales_outlet_id AS transactions, 
 CAST(AVG(sales) AS DECIMAL(5,2)) AS ATV from grouped_tran g
  WHERE hour > 5
 GROUP BY hour, sales_outlet_id
 ORDER BY sales_outlet_id, hour