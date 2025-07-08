with visits as (
	select cust_id, trans_date, sum(amount) day_amount
	from dwh.transactions
	where type = 'SALE'
	group by cust_id, trans_date
	having sum(amount) >= 1000
)
,time_visits as (
	select cust_id, sum(day_amount) total_amount, 
		count(trans_date) total_visits,
		min(trans_date) first_visit,
		max(trans_date) last_visit
	from visits
	group by cust_id
)
select *
from time_visits
where 1=1
and last_visit >= first_visit + interval '60 days'
and total_visits >= 2
order by total_amount;
