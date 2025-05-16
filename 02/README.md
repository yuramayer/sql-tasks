# Продажи клиентов

Задачки по продажам с группировкой и собственным Join-ом

## Таблица

Представим, что у нас есть табличка `transactions` такого вида

| trans_id | cust_id | trans_date | amount  | type   |
|----------|---------|------------|---------|--------|
| 1        | 1       | 2024-01-23 | 172.23  | SALE   |
| 2        | 1       | 2024-03-17 | 362.73  | SALE   |
| 3        | 1       | 2024-03-18 | 583.48  | SALE   |
| 4        | 1       | 2024-03-14 | 550.31  | SALE   |
| 5        | 1       | 2024-01-19 | 192.35  | SALE   |
| 6        | 1       | 2024-02-08 | 427.69  | SALE   |
| 8        | 1       | 2024-03-30 | 401.12  | REFUND |

**Описание колонок:**

- `trans_id` – уникальный идентификатор транзакции  
- `cust_id` – идентификатор клиента  
- `trans_date` – дата транзакции  
- `amount` – сумма в долларах  
- `type` – тип транзакции: `SALE` или `REFUND`

## Задача 1

Для каждого `SALE`-транзакта найди, были ли ещё продажи у этого же клиента в течение следующих 30 дней.

Если такие есть — верни сумму `amount` этих "повторных" транзакций (без самой исходной).

**Формат результата:**
| trans_id |	cust_id	| trans_date	| base_amount	| future_sales_count	| future_sales_sum |
| -- | --- | --         |   --          | -- |      - | 
| 1|	1	| 2024-01-23	| 172.23	| 2 |	619.04 |

## Решение 1

Вот такой код:

```sql
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
```

## Задача 2

Для каждого `SALE`-транзакта клиента сравни его `amount`
со средним чеком клиента за предыдущие 60 дней.

Если сумма больше чем в 2 раза среднего чека за предыдущие 60 дней —
пометь такую продажу как `anomaly = true`.

## Решение 2

```sql
with sales as (
	select *
	from transactions
	where "type" = 'SALE')
select s1.trans_id, s1.cust_id, s1.trans_date, s1.amount,
	round(avg(s2.amount), 2) avg_prev_60d,
	case
		when s1.amount > avg(s2.amount) * 2 then true 
		else false
	end anomaly
from sales s1
left join sales s2
on 1=1
and s1.trans_id <> s2.trans_id
and s1.cust_id = s2.cust_id
and s1.trans_date >= s2.trans_date
and s1.trans_date <= s2.trans_date + interval '60 days'
group by s1.trans_id, s1.cust_id, s1.trans_date, s1.amount;
```

## Задача 3

Для каждого клиента найди такие пары транзакций SALE, где:
 - обе принадлежат одному клиенту
 - вторая транзакция произошла быстрее, чем предыдущая пара
 - и сумма во второй транзакции выше суммы в первой

## Решение 3

```sql
with sales as (
	select *
	from transactions
	where "type" = 'SALE'
), sales_prev as (
	select *,
	lag(trans_id) over (partition by cust_id 
						  order by trans_date) prev_id
	from sales
), sales_info_prev as (
	select sp1.*, sp2.trans_id, sp2.trans_date as prev_date,
		sp1.trans_date - sp2.trans_date as trans_date_diff,
		lag(sp1.trans_date - sp2.trans_date) over (partition by sp1.cust_id) as prev_trans_date_diff,
		sp2.amount as prev_amount
	from sales_prev sp1
	left join sales_prev sp2
	on sp1.prev_id = sp2.trans_id
) select *
from sales_info_prev
where 1=1
and trans_date_diff < prev_trans_date_diff
and amount > prev_amount
;
```

## Задача 4

Для каждого клиента:
- Разбей все SALE-транзакции по неделям (например, "2024-01-01 → неделя 1", "2024-01-08 → неделя 2" и т.п.)
- Посчитай суммарную amount за каждую неделю
- Найди ту неделю, где клиент потратил больше всего

Верни таблицу:
- `cust_id`
- `week_start_date` (например, понедельник той недели)
- `total_week_amount`
- `rank` этой недели среди всех недель клиента (вдруг есть несколько одинаковых максимумов)

Также поверх посчитай подзапросом, какую долю от всех трат клиента за всё время составляет пиковая неделя

## Решение 4

> Я могу получить понедельник даты через `date_trunc('week', trans_date)`

```postgres
with sales as (
	select *
	from transactions
	where "type" = 'SALE'
), sales_grouped as (
	select cust_id, 
		extract('week' from trans_date) week_number,
		date_trunc('week', trans_date)::date week_start_date,
		sum(amount) as total_week_amount
	from sales
	group by cust_id, week_number, week_start_date
), sales_ranked as (
	select cust_id, 
		week_start_date,
		total_week_amount,
		rank() over(partition by cust_id order by total_week_amount desc) week_amount_rank,
		round(total_week_amount /
			sum(total_week_amount) over(partition by cust_id), 2) * 100 week_rate_perc
	from sales_grouped
)
select *
from sales_ranked
where week_amount_rank=1
;
```


