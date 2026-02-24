{{ config(
    materialized="incremental",
    unique_key="user_id",
    incremental_strategy="delete+insert",
    post_hook="ANALYZE {{ this }}"
) }}

-- Usage counts within day windows. One row per (user_id, user_creation_date).
WITH base AS (
    SELECT *
    FROM {{ ref('fr_teachers_postsignups_classrooms_kids_writings') }}
),

{% set classroom_days = [1, 3, 7, 14, 21, 30, 60] %}
{% set kid_days = [1, 3, 7, 14, 21, 30, 60] %}
{% set writing_days = [1, 3, 7, 14, 21, 30, 60] %}

usage_within_windows AS (
    SELECT
        b.user_id,
        b.user_creation_date,

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
)

SELECT * FROM usage_within_windows
