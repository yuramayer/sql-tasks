# Возвращения клиентов

Представим, что у нас есть табличка `transactions` такого вида

| cust_id | trans_date | amount  | type   |
|---------|------------|---------|--------|
| 1       | 2024-01-23 | 172.23  | SALE   |
| 1       | 2024-03-17 | 362.73  | SALE   |
| 2       | 2024-03-18 | 583.48  | SALE   |
| 2       | 2024-03-14 | 550.31  | REFUND |
| 2       | 2024-01-19 | 192.35  | SALE   |
| 2       | 2024-02-08 | 427.69  | SALE   |
| 3       | 2024-03-30 | 401.12  | REFUND |

Найди всех клиентов, которые:

- Совершили не менее 2 разных визитов с разницей минимум в 60 дней между первой и последней покупкой.

- При этом каждый визит должен содержать покупки (SALE) на сумму не менее 1000 (в рамках одного дня).

Вывести: `cust_id`, `first_visit`, `last_visit`, `total_visits`, `total_amount`.

> Визит — это день, когда клиент совершил покупки. Несколько транзакций в один день — один визит

## Код

```sql
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
```
