with next_sales as (
select t1.trans_id, t1.cust_id, t1.trans_date,
	t1.amount base_amount, t1.type, t2.trans_id as next_trans_id,
	t2.trans_date as next_trans_date,
	t2.amount as next_amount
from transactions t1
left join transactions t2
on 1=1
and t1.trans_id <> t2.trans_id
and t1.cust_id = t2.cust_id
and t2.type='SALE'
and t2.trans_date > t1.trans_date
and t2.trans_date <= t1.trans_date + interval '30 days'
where t1.type='SALE')
select trans_id, cust_id, trans_date, base_amount,
	count(next_amount) future_sales_count,
	sum(next_amount) future_sales_sum
from next_sales
group by trans_id, cust_id, trans_date, base_amount
order by cust_id, trans_date
;