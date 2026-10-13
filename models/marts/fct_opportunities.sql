
{{
    config(
        materialized = 'incremental',
        unique_key = 'opportunity_id',
        incremental_strategy = 'merge'
    )
}}

WITH opportunities AS (

    SELECT *
    FROM {{ ref('stg_opportunities') }}

),

activity AS (

    SELECT *
    FROM {{ ref('int_opportunity_activity') }}

),

account_history AS (

    SELECT *
    FROM {{ ref('dim_accounts') }}

),

current_accounts AS (

    SELECT *
    FROM {{ ref('dim_accounts') }}
    WHERE is_current = TRUE

)

SELECT
    o.opportunity_id,

    -- Keep all surrogate keys as VARCHAR
    COALESCE(
        ah.account_sk::VARCHAR,
        ca.account_sk::VARCHAR,
        '-1'
    ) AS account_sk,

    o.account_id,
    o.sales_rep_id,
    o.opportunity_stage,
    o.opportunity_amount,
    o.probability,

    o.opportunity_amount * o.probability
        AS expected_revenue,

    o.lead_source,
    o.created_date,
    o.expected_close_date,
    o.actual_close_date,

    DATEDIFF(
        day,
        o.created_date,
        COALESCE(
            o.actual_close_date,
            CURRENT_DATE()
        )
    ) AS days_open,

    COALESCE(
        act.activity_count,
        0
    ) AS activity_count,

    act.last_activity_date,

    DATEDIFF(
        day,
        act.last_activity_date,
        CURRENT_DATE()
    ) AS days_since_last_activity,

    o.updated_at

FROM opportunities o

LEFT JOIN activity act
    ON o.opportunity_id = act.opportunity_id

LEFT JOIN account_history ah
    ON o.account_id = ah.account_id
   AND o.created_date >= ah.valid_from
   AND (
       o.created_date < ah.valid_to
       OR ah.valid_to IS NULL
   )

LEFT JOIN current_accounts ca
    ON o.account_id = ca.account_id
