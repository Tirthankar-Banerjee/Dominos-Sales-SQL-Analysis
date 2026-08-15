Create Database Dominos_pizza;
Use Dominos_pizza;
-- join all the table together. 
Select * from DATA_TIME DT join Order_details OD on DT.order_id = OD.order_id join PIZZA_TYPE PT on Dt.order_id = PT.order_id 
join Price_segment PS on DT.order_id = PS.order_id join [STORE LOCATION] SL on DT.order_id = SL.order_id;

--- 1. Calculate the total revenue.
Select Sum(total_amount) as Total_revenue from  Price_segment;

--- 2. Find the total number of orders.
Select Count(DISTINCT order_id) as total_number_of_orders from Price_segment;

-- 3. Find the total number of customers.
Select Count(DISTINCT customer_id) as Total_customers From [STORE LOCATION];

-- 4. Calculate the average order value.
Select Avg(total_amount) AS Average_Order_Value from Price_segment;

-- 5. Find the total quantity of pizzas sold.
select sum(quantity) As Total_quantity From Price_segment;

-- 6. Which city generated the highest revenue?
Select  TOP 1 City, Sum(total_amount) as Most_revenue  from Price_segment PS join [STORE LOCATION] SL on PS.order_id = SL.order_id 
Group by City
Order by Most_revenue Desc;

-- 7. Which store generated the highest revenue?

Select top 1 store_id,city, Sum(total_amount) as City_wise_most_revenue  from Price_segment PS join [STORE LOCATION] SL on PS.order_id = SL.order_id 
group by store_id,city Order by City_wise_most_revenue Desc;

-- 8. Which pizza generated the highest revenue?
Select Top 1 pizza_name,Sum(total_amount) as Most_revenue_Pizza 
from Price_segment PS join PIZZA_TYPE PT on PS.order_id = PT.order_id Group by pizza_name order by Most_revenue_Pizza Desc ;

-- 9. Which pizza category sold the most?
Select Top 1 category, Sum(quantity) As Most_sold_Pizza_category  
from Price_segment PS join PIZZA_TYPE PT on PS.order_id = PT.order_id group by category order by Most_sold_Pizza_category Desc;

-- 10. Which payment method is used most frequently?		
Select Top 1 payment_method, Count(payment_method) as most_use_payment_method from Order_details Group by payment_method order by Count(payment_method) Desc;


-- 11. Find the top 5 customers based on total spending.

Select Top 5 customer_id, Sum(total_amount) as total_spending from [STORE LOCATION] SL join Price_segment PS on SL.order_id = PS.order_id 
Group by customer_id order by total_spending Desc;

-- 12. Find monthly persentage sales trends.
with monthly_sales as (Select month(order_date) as month , Sum(total_amount) as Total_revenue 
from DATA_TIME DT join Price_segment PS on DT.order_id = PS.order_id 
Group by month(order_date)),

Trend as  (Select month,Total_revenue, lag(Total_revenue) Over(order by month)
as previous_sales from monthly_sales) 

Select month, Total_revenue, previous_sales, round((Total_revenue - previous_sales) * 100.0 / previous_sales, 2) 
as Growth_percentage from Trend order by month;

-- 13. Rank stores based on total revenue.
Select*from
(select SL.Store_id,SL.City,Sum(PS.total_amount) as total_revnue,
dense_rank () Over  (Order by Sum(PS.total_amount) Desc) As rnk 
from [STORE LOCATION] SL
join Price_segment PS on SL.order_id = PS.order_id 
GROUP BY SL.Store_id, SL.City) t; 

-- 14. Find the 2nd highest revenue-generating pizza.
With Total_profit as (select pizza_name,Sum(total_amount) As Total_revenue, 
dense_rank () Over (Order by Sum(total_amount) Desc) As rnk 
from PIZZA_TYPE PT join Price_segment PS on PT.order_id = PS.order_id
group by PT.pizza_name)
Select * from Total_profit where rnk = 2;

-- 15. Calculate each city's percentage contribution to total revenue.

with Total_profit as (select City, Sum(total_amount) as Total_Revenue 
from Price_segment PS join [STORE LOCATION] SL on SL.order_id = PS.order_id 
GROUP BY SL.City) 
Select City,round(Total_Revenue*100/Sum(Total_Revenue) over (),2) as Persentage_revenue from Total_profit 
order by Persentage_revenue Desc;
