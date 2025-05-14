# Заказы клиентов по месяцам

Задачка с группировкой и оконными функциями

## Таблица

Представим, что у нас есть табличка `orders` такого вида

| order_id | cust_id | order_date | amount | status     |
|----------|---------|------------|--------|------------|
| 200      | 2       | 2024-07-18 | 72.29  | COMPLETED  |
| 201      | 1       | 2024-06-04 | 471.84 | COMPLETED  |
| 202      | 4       | 2024-05-28 | 350.48 | COMPLETED  |
| 203      | 2       | 2024-11-07 | 460.96 | PENDING    |

## Задача

Необходимо написать один SQL-запрос, который выводит для каждого клиента и каждого месяца 2024 года: 
в котором у клиента были выполненные заказы, следующие поля:
- month — месяц
- cust_id - id клиента
- total_amount — суммарная сумма заказов за месяц
- order_count — количество заказов за месяц
- avg_amount — средний чек за месяц, округлённый до двух знаков
- monthly_rank — ранг клиента по убыванию `total_amount` внутри каждого месяца (1 = самый крупный объём продаж)
- amount_diff — разница `total_amount` данного месяца и предыдущего месяца для того же клиента (если предыдущего месяца нет — NULL)

## Решение

Вот такой код:

```sql
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
```

