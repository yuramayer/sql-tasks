-- we wanna one single scan,
--      without subqueries

select "type" ticket_type,
    round(1.0 * sum(
        case
            when processed = true
            then 1
            else 0
        end
    ) / count(*), 2) as processed_rate
from facebook_complaints
group by "type"
;