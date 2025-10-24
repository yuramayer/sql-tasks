select
    extract(month from post_date) month_number,
    count(*) total_posts
from facebook_posts
group by 1
order by 1
;

-- with month names:

select 
    extract(month from post_date) as month_number,
    to_char(post_date, 'Month') as month_name,
    count(*) as total_posts
from facebook_posts
group by month_number, month_name -- postgres,
-- won't work in ANSI, should use all the line
order by month_number
;