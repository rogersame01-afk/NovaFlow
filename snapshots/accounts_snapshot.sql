{% snapshot accounts_snapshot %}

{{
    config(
        target_schema='SNAPSHOTS',
        unique_key='account_id',
        strategy='check',
        check_cols=[
            'account_name',
            'industry',
            'segment',
            'region',
            'account_status'
        ]
    )
}}

select
    account_id,
    account_name,
    industry,
    segment,
    region,
    account_status,
    created_date,
    updated_at

from {{ ref('stg_accounts') }}

where account_id is not null

{% endsnapshot %}