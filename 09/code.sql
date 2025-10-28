-- if we want only ONE per day:
-- we don't wanna make two cte's for the max,
-- so we'll use distinct on = Postgres allows it
with max_clients as (
    select distinct on (order_date)
        order_date,
        cust_id,
        sum(total_order_cost) as total_cost
    from orders
    where 1=1
    and order_date >= '2019-02-01'
    and order_date < '2019-05-02'
    group by order_date, cust_id
    order by order_date, total_cost desc -- !!! Important!
)
select c.first_name, mc.total_cost, mc.order_date
from max_clients mc join customers c
on mc.cust_id = c.id
order by order_date
;

-- if we wanna all the mosts per day,
-- we should use rank
-- but we don't wanna 2 cte:

with ranked_clients as (
    select
        order_date,
        cust_id,
        sum(total_order_cost) as total_cost,
        rank() over (
            partition by order_date
            order by sum(total_order_cost) desc
        ) as rnk
    from orders
    where order_date >= '2019-02-01'
    and order_date < '2019-05-02'
    group by order_date, cust_id
)
select c.first_name, rc.total_cost, rc.order_date
from ranked_clients rc
join customers c on rc.cust_id = c.id
where rc.rnk = 1
order by rc.order_date
;