with source as (

    select *
    from {{ source('novaflow_raw', 'accounts') }}

),

cleaned as (

    select

        upper(trim(account_id)) as account_id,

        trim(account_name) as account_name,

        trim(industry) as industry,

        case
            when upper(trim(segment)) = 'SMB'
                then 'SMB'

            when upper(trim(segment)) in ('MID-MARKET', 'MID MARKET')
                then 'Mid-Market'

            when upper(trim(segment)) in ('ENTERPRISE', 'LARGE')
                then 'Enterprise'

            when segment is null
                or upper(trim(segment)) = 'UNKNOWN'
                then 'Unknown'

            else 'Unknown'
        end as segment,

        trim(region) as region,

        initcap(trim(account_status)) as account_status,

        try_to_date(created_date) as created_date,

        try_to_timestamp(updated_at) as updated_at

    from source

),
depuded as (
select *
from cleaned
qualify row_number() over(partition by account_id order by updated_at desc) =1)

select * from depuded