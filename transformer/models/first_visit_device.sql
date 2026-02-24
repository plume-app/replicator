SELECT 
    DISTINCT ON (user_id)
    user_id,
    started_at,
    device_type
FROM ahoy_visits
WHERE user_id IS NOT NULL
ORDER BY user_id, started_at ASC