WITH base AS (
    -- Base table: one row per writing
    SELECT
        *
    FROM {{ ref('fr_teachers_postsignups_classrooms_kids_writings') }} AS signups_teachers_writings
),

-- --------------------------------------------------
-- First events per user
-- --------------------------------------------------
first_events AS (
    SELECT
        b.user_id,

        MIN(classroom_creation_date) FILTER (
            WHERE classroom_creation_date >= b.user_creation_date
        ) AS first_classroom_date,

        MIN(kid_creation_date) FILTER (
            WHERE kid_creation_date >= b.user_creation_date
        ) AS first_kid_date,

        MIN(writing_creation_date) FILTER (
            WHERE writing_creation_date >= b.user_creation_date
        ) AS first_writing_date

    FROM base b
    GROUP BY b.user_id
),

-- --------------------------------------------------
-- Usage counts within X days
-- --------------------------------------------------
{% set classroom_days = [1, 3, 7, 14, 21, 30, 60, 90] %}
{% set kid_days = [1, 3, 7, 14, 21, 30, 60, 90] %}
{% set writing_days = [1, 3, 7, 14, 21, 30, 60, 90] %}

usage_within_windows AS (
    SELECT
        b.user_id,

        -- Classrooms
        {% for days in classroom_days -%}
        COUNT(DISTINCT classroom_id) FILTER (
            WHERE classroom_creation_date <= user_creation_date + INTERVAL '{{ days }} day{% if days > 1 %}s{% endif %}'
        ) AS classrooms_d{{ days }}{% if not loop.last %},{% endif %}
        {% endfor -%}
        ,

        -- Kids
        {% for days in kid_days -%}
        COUNT(DISTINCT kid_id) FILTER (
            WHERE kid_creation_date <= user_creation_date + INTERVAL '{{ days }} day{% if days > 1 %}s{% endif %}'
        ) AS kids_d{{ days }}{% if not loop.last %},{% endif %}
        {% endfor -%}
        ,

        -- Writings
        {% for days in writing_days -%}
        COUNT(DISTINCT writing_id) FILTER (
            WHERE writing_creation_date <= user_creation_date + INTERVAL '{{ days }} day{% if days > 1 %}s{% endif %}'
        ) AS writings_d{{ days }}{% if not loop.last %},{% endif %}
        {% endfor %}

    FROM base b
    GROUP BY b.user_id, b.user_creation_date
),

-- --------------------------------------------------
-- Per-user metrics table
-- --------------------------------------------------
usage_since_user_creation AS (
SELECT
    u.user_id,
    u.user_creation_date,
    u.gar,
    u.user_active,

    -- Usage counts (COALESCE to 0)
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
    ,

    -- Delays (NULL if event never happened)
    EXTRACT(DAY FROM (f.first_classroom_date - u.user_creation_date))
        AS days_to_first_classroom,

    EXTRACT(DAY FROM (f.first_kid_date - u.user_creation_date))
        AS days_to_first_kid,

    EXTRACT(DAY FROM (f.first_writing_date - u.user_creation_date))
        AS days_to_first_writing

FROM (
    SELECT 
        *
    FROM {{ ref('fr_teachers_postsignups') }}
) AS u
LEFT JOIN usage_within_windows w ON u.user_id = w.user_id
LEFT JOIN first_events f         ON u.user_id = f.user_id
)

SELECT * FROM usage_since_user_creation
