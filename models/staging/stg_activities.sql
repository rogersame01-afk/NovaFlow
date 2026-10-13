 select 
   trim(activity_id)
        as activity_id,

    trim(opportunity_id)
        as opportunity_id,

    initcap(
        trim(activity_type)
    ) as activity_type,

    try_to_date(
        activity_date
    ) as activity_date,
      initcap(
        trim(activity_status)
    ) as activity_status,
  try_to_date(created_at) as created_date
 from {{ source('novaflow_raw', 'activities') }}



 