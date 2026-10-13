select 
a.region,

 a.segment,

 f.opportunity_stage,

count(*) as opportunity_count,

sum(f.opportunity_amount)
        as pipeline_amount,

sum(f.expected_revenue)
        as expected_revenue,

avg(f.days_open)
        as avg_days_open,

avg(f.activity_count)
        as avg_activity_count

    
from {{ ref('fct_opportunities') }} f

join {{ ref('dim_accounts') }} a
    on f.account_sk =
       a.account_sk

group by
    a.region,
    a.segment,
    f.opportunity_stage