-- Now to look at customers, who have details in the database.
-- We'll look at the top 10 most regular visitors and join the customer table to get customer name
-- we can see here, that not all customers have supplied a full name, so for consistency, we will select just first name.
-- However, not all fields contain a surname, so using a case statement, we can extract just first name to use
-- Adding in total spend, and reordering columns in the view, we have a useful series of information to 


with first_name as
(
select customer_id, customer_email,
case when LEFT(customer_name,CHARINDEX (' ',customer_name)) != '' then LEFT(customer_name,CHARINDEX (' ',customer_name))
else customer_name

 end as first_name  from customer
 )

select top 10 s.customer_id, first_name, count(s.customer_id) as visits, SUM(line_item_amount) as total_spend,   customer_email

from sales s
 join first_name f
 on s.customer_id = f.customer_id
where s.customer_id != ' '
group by s.customer_id, f.first_name, customer_email
order by visits desc

