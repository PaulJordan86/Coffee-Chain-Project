-- Now to take a look at product

SELECT * FROM product1;

-- We have some very long wholesale prices - this is money, so only needs to be rounded to 2db

ALTER TABLE product1
ALTER COLUMN current_wholesale_price MONEY;

--Much tidier and easy to read. We will now look at profit margins

SELECT product, current_retail_price, current_wholesale_price, (current_retail_price - current_wholesale_price) AS gross_profit, 
CAST((100.0*(current_retail_price - current_wholesale_price))/current_retail_price AS DECIMAL (5,2)) AS profit_percentage 
FROM product1 ;

-- Now we can take this information and combine it with sales information to see best performing products
-- As we have half the product range with no wholesale price, this data is not giving us anything usable, so we will move on to
-- sales data

SELECT product, current_retail_price, current_wholesale_price, (current_retail_price - current_wholesale_price) AS gross_profit, 
CAST((100.0*(current_retail_price - current_wholesale_price))/current_retail_price AS DECIMAL (5,2)) AS profit_percentage 
FROM product1 p
JOIN sales s
ON p.product_id = s.product_id
ORDER BY  desc

-- Finally, as total sales is the only product metric which we have, we can look at the top sellers,
-- in each category by revenue. We could use a WHERE statement to look at top or bottom performing products
-- if desired.

WITH rank AS
( select product, product_category, s.product_id,
DENSE_RANK () OVER(PARTITION BY product_category ORDER BY SUM(line_item_amount) DESC) AS product_rank
FROM product1 p
JOIN sales s
ON s.product_id = p.product_id
GROUP BY p.product_category, product, s.product_id
)
SELECT product, r.product_category, r.product_rank, sum(line_item_amount) AS total_sales_value
FROM rank r
JOIN sales s
ON r.product_id = s.product_id
 -- WHERE RANK <= 3 OR WHERE RANK >= 3 would provide top or bottom 3 performing
 -- products from each category
GROUP BY product_category, product, product_rank
ORDER BY product_category, product_rank



