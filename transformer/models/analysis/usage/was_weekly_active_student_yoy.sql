-- WAS = Weekly Active Student

WITH base AS (
  SELECT
    rollups.id,
    rollups.time::date AS week_start,
    rollups.value::int AS student_count
  FROM public.rollups
  WHERE rollups.name = 'weekly_active_student'
),

labeled AS (
  SELECT
    *,
    -- Assign school year
    CASE 
      WHEN EXTRACT(MONTH FROM week_start) >= 8 THEN 
        CONCAT(EXTRACT(YEAR FROM week_start)::int, '/', EXTRACT(YEAR FROM week_start)::int + 1)
      ELSE
        CONCAT(EXTRACT(YEAR FROM week_start)::int - 1, '/', EXTRACT(YEAR FROM week_start)::int)
    END AS school_year,

    -- Compute start of academic year
    CASE 
      WHEN EXTRACT(MONTH FROM week_start) >= 8 THEN 
        DATE_TRUNC('week', TO_DATE(CONCAT(EXTRACT(YEAR FROM week_start)::int, '-08-01'), 'YYYY-MM-DD'))
      ELSE
        DATE_TRUNC('week', TO_DATE(CONCAT(EXTRACT(YEAR FROM week_start)::int - 1, '-08-01'), 'YYYY-MM-DD'))
    END AS school_year_start
  FROM base
),

final AS (
  SELECT
    school_year,
    FLOOR(DATE_PART('day', week_start - school_year_start) / 7) + 1 AS week_number,
    week_start,
    student_count
  FROM labeled
)

SELECT *
FROM final
ORDER BY school_year, week_number