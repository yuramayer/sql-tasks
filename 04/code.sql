-- This leads to the problem:
-- We calculate twice with CTE.

-- with hearts_posts as (
--     select distinct post_id
--     from facebook_reactions
--     where reaction='heart'
-- )
-- select fp.*
-- from facebook_posts fp
-- join hearts_posts hp
-- on fp.post_id = hp.post_id
-- ;

-- Better to use Exists:

select fp.*
from facebook_posts fp
where exists (
    select 1
    from facebook_reactions fr
    where 1=1
    and fr.reaction='heart'
    and fr.post_id = fp.post_id
)
;