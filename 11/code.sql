with address_ranked as (
    select item_id,
    address,
        row_number() over (partition by item_id order by actual_date desc) rk
),
filter_address_ranked as (
    select item_id, address
    from address_ranked
    where rk = 1
),
price_ranked as (
    select item_id, price, 
        row_number() over (partition by item_id order by actual_date desc) rk
),
filter_price_ranked as (
    select item_id, price
    from price_ranked
    where rk = 1
)
select coalesce(pr.item_id, ar.item_id) as item_id, -- либо id1, либо id2
    pr.price, ar.address
from filter_address_ranked ar
full outer join filter_price_ranked pr  -- хотим все варианты глянуть
on ar.item_id = pr.item_id
;