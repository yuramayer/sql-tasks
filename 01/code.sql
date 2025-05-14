with month_groups as (
select date_trunc('month', order_date)::date as _month, cust_id,
	sum(amount) total_amount, count(*) order_count, round(avg(amount), 2) avg_amount
from orders
where 1=1
and status = 'COMPLETED'
and order_date >= '2024-01-01'
and order_date <= '2024-12-31'
group by date_trunc('month', order_date)::date, cust_id 
order by date_trunc('month', order_date)::date
	)
select _month, cust_id, total_amount, order_count, avg_amount,
	row_number() over(partition by _month order by total_amount desc) monthly_rank,
	--lag(total_amount) over (partition by cust_id order by _month) prev_month_amount,
	total_amount - lag(total_amount) over (partition by cust_id order by _month) amount_diff
from month_groups
order by _month, 
	row_number() over(partition by _month order by total_amount desc)
;
