
-- Test: Each account must have only one current record.
-- Expected result: Zero rows.

SELECT
    account_id,
    COUNT(*) AS current_row_count

FROM {{ ref('dim_accounts') }}

WHERE is_current = TRUE

GROUP BY account_id

HAVING COUNT(*) > 1
