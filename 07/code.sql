-- CTE doesn't save work here:

-- with march_custs as (
--     select cust_id,
--         total_order_cost
--     from orders
--     where 1=1
--     and order_date <= '2019-03-31'
--     and order_date >= '2019-03-01'
-- )
-- select cust_id,
--     sum(total_order_cost) total_revenue
-- from march_custs
-- group by cust_id
-- order by total_revenue desc
-- ;

-- let's try the one-query

select cust_id,
    sum(total_order_cost) total_revenue
from orders
where 1=1
and order_date < '2019-04-01'
and order_date >= '2019-03-01'
group by cust_id
order by total_revenue desc
;

-- now we scan one table instead of two 💫
