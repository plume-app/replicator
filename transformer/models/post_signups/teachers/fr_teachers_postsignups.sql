{{ config(
   materialized="view"
) }}

WITH teachers_signup AS (
SELECT 
    user_id,
    gar,
    user_creation_date,
    user_active,
    device_type_first_visit,
    quests_points_total,
    quests_points_category
FROM {{ ref('usage_by_user_2025_2026') }} 
WHERE 
    user_creation_date >= '2024-09-01'
    AND 
    user_account_type = 1
    AND 
    user_locale = 'fr'
)

SELECT * FROM teachers_signup