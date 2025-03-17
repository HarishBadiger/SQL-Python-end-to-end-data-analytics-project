select * from df_orders;

/* Find top 10 highest revenue generating products */

select top 10 product_id, sum(sale_price) as sales
from df_orders
group by product_id
order by sum(sale_price) desc;

/* Find top 5 highest selling products in each region */

with cte as(
select region,product_id, sum(sale_price) as sales
from df_orders
group by region,product_id)

select * from (select *,dense_rank() over(partition by region order by sales desc) as rnk
from cte) A where rnk<=5;

/* Find month over month growth comparison for 2022 and 2023 sales eg: Jan 2022 vs jan 2023 */

with cte as (
select year(order_date) as yr, month(order_date) as mt , sum(sale_price) as sales
from df_orders
group by year(order_date) , month(order_date))

,cte2 as(
select mt
,sum(case when yr=2022 then sales else 0 end) as sales_2022
,sum(case when yr=2023 then sales else 0 end) as sales_2023
from cte group by mt)

select *, (sales_2023 - sales_2022) * 1.0/sales_2022 * 100 as percenatge_growth from cte2;

/* which sub category had highest growth by profit in 2023 compared to 2022 */

with cte as (
select sub_category, year(order_date) as yr, sum(sale_price) as sales
from df_orders
group by sub_category, year(order_date))

,cte2 as(
select sub_category
,sum(case when yr=2022 then sales else 0 end) as sales_2022
,sum(case when yr=2023 then sales else 0 end) as sales_2023
from cte group by sub_category)

select top 1 *, (sales_2023 - sales_2022) * 1.0/sales_2022 * 100 as percenatge_growth 
from cte2
order by percenatge_growth desc;