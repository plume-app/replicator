{{
  config(
    materialized='incremental',
    incremental_strategy='delete+insert',
    unique_key='user_id'
  )
}}

SELECT
    DISTINCT ON (v.user_id)
    v.user_id,
    v.started_at,
    v.device_type
FROM ahoy_visits v
{% if is_incremental() %}
INNER JOIN users u ON u.id = v.user_id
    AND u.created_at >= current_date - interval '14 days'
{% endif %}
WHERE v.user_id IS NOT NULL
ORDER BY v.user_id, v.started_at ASC