with base as (
select

    trim(opportunity_id)
        as opportunity_id,

    upper(trim(account_id))
        as account_id,

    trim(sales_rep_id)
        as sales_rep_id,

    case

        when lower(trim(opportunity_stage))
             in ('closed won', 'closed-won', 'closedwon')
        then 'Closed Won'

        when lower(trim(opportunity_stage))
             in ('closed lost', 'closed-lost', 'closedlost')
        then 'Closed Lost'

        else initcap(
            trim(opportunity_stage)
        )

    end as opportunity_stage,

    try_to_decimal(
        opportunity_amount,
        18,
        2
    ) as opportunity_amount,

    try_to_decimal(
        probability,
        5,
        4
    ) as probability,

    trim(lead_source)
        as lead_source,

    try_to_date(
        created_date
    ) as created_date,

    try_to_date(
        expected_close_date
    ) as expected_close_date,

    try_to_date(
        actual_close_date
    ) as actual_close_date,

    try_to_timestamp(
        updated_at
    ) as updated_at
    from {{ source('novaflow_raw', 'opportunities') }}
)
,

 depuded as (
    select * from base
    qualify row_number() over(partition by opportunity_id order by updated_at desc ) = 1
 )

 select * from depuded