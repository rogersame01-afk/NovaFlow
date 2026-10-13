with base as (
Select
opportunity_id,
count(*) as activity_count,
max(activity_date) as last_activity_date,
count_if( activity_type = 'Meeting' ) as number_of_meetings,
count_if( activity_type = 'Call' ) as number_of_calls,
count_if( activity_type = 'Emails' ) as number_of_emails,
from {{ ref('stg_activities') }} 
group by opportunity_id
)

Select * from  base