# Последующие продажи клиентов

Задачка с группировкой и собственным Join-ом

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

## Задача

Для каждого `SALE`-транзакта найди, были ли ещё продажи у этого же клиента в течение следующих 30 дней.

Если такие есть — верни сумму `amount` этих "повторных" транзакций (без самой исходной).

**Формат результата:**
| trans_id |	cust_id	| trans_date	| base_amount	| future_sales_count	| future_sales_sum |
| -- | --- | --         |   --          | -- |      - | 
| 1|	1	| 2024-01-23	| 172.23	| 2 |	619.04 |

## Решение

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
