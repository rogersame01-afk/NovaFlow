select
    o.opportunity_id,
    o.account_id

from {{ ref('stg_opportunities') }} o

left join {{ ref('dim_accounts') }} a
    on o.account_id = a.account_id
   and a.is_current = true

where o.account_id is not null
  and a.account_id is null