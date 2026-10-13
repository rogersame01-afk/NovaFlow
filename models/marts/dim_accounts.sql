with account_history as (

    select

        dbt_scd_id as account_sk,

        account_id,
        account_name,
        industry,
        segment,
        region,
        account_status,

        dbt_valid_from as valid_from,

        coalesce(
            dbt_valid_to,
            '9999-12-31'::timestamp
        ) as valid_to,

        case
            when dbt_valid_to is null then true
            else false
        end as is_current

    from {{ ref('accounts_snapshot') }}

),

unknown_account as (

    select

        '-1' as account_sk,

        'UNKNOWN' as account_id,

        'Unknown Account' as account_name,

        'Unknown' as industry,

        'Unknown' as segment,

        'Unknown' as region,

        'Unknown' as account_status,

        '1900-01-01'::timestamp as valid_from,

        '9999-12-31'::timestamp as valid_to,

        true as is_current

)

select *
from account_history

union all

select *
from unknown_account