with user_sessions as (
    select user_id,
        "timestamp"::date session_date,
        max(
            case
                when "action" = 'page_load'
                then "timestamp"
            end
         ) as session_start,
        min(
            case
                when "action" = 'page_exit'
                then "timestamp"
            end
        ) as session_end
    from facebook_web_log
    group by 1, 2
),
session_time as (
    select user_id,
        extract(
            epoch from (session_end - session_start)
            ) session_sec
    from user_sessions
    where 1=1
    and session_start is not null
    and session_end is not null
    and session_end > session_start
)
select user_id,
    round(avg(session_sec) / 60, 2) avg_session_min
from session_time
group by user_id
order by user_id; 