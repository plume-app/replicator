{{ config(
    materialized="incremental",
    unique_key="user_id",
    incremental_strategy="delete+insert"
) }}

-- Final model: joins only (no scan of the big writings table).
{% set classroom_days = [1, 3, 7, 14, 21, 30, 60] %}
{% set kid_days = [1, 3, 7, 14, 21, 30, 60] %}
{% set writing_days = [1, 3, 7, 14, 21, 30, 60] %}

WITH teachers_for_run AS (
    SELECT * FROM {{ ref('fr_teachers_postsignups') }}
    {% if is_incremental() %}
    WHERE user_creation_date >= current_date - interval '60 days'
    {% endif %}
)

SELECT
    u.user_id,
    u.user_creation_date,
    u.gar,
    u.user_active,
    
    {% for days in classroom_days -%}
    COALESCE(w.classrooms_d{{ days }}, 0) AS classrooms_d{{ days }}{% if not loop.last %},{% endif %}
    {% endfor -%}
    ,

    {% for days in kid_days -%}
    COALESCE(w.kids_d{{ days }}, 0) AS kids_d{{ days }}{% if not loop.last %},{% endif %}
    {% endfor -%}
    ,

    {% for days in writing_days -%}
    COALESCE(w.writings_d{{ days }}, 0) AS writings_d{{ days }}{% if not loop.last %},{% endif %}
    {% endfor -%}

FROM teachers_for_run AS u
LEFT JOIN {{ ref('fr_teachers_usage_within_windows') }} w ON u.user_id = w.user_id
