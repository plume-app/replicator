WITH classrooms_and_kids_created_2024 AS (
    SELECT * FROM {{ ref('high_usage_classrooms_2024_2025_kids_details') }}
),

distinct_dates AS (
    SELECT DISTINCT
        classroom_id,
        writing_creation_date::DATE AS session_day
    FROM classrooms_and_kids_created_2024
),

session_diffs AS (
    SELECT 
        classroom_id,
        session_day,
        session_day - LAG(session_day) OVER (
            PARTITION BY classroom_id ORDER BY session_day
        ) AS day_diff
    FROM distinct_dates
),

filtered_diffs AS (
    SELECT 
        classroom_id, 
        day_diff
    FROM session_diffs
    WHERE day_diff IS NOT NULL
),

stats AS (
    SELECT 
        classroom_id,
        AVG(day_diff) AS avg_day_gap,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY day_diff) AS median_day_gap,
        MIN(day_diff) AS min_day_gap,
        MAX(day_diff) AS max_day_gap,
        100.0 * COUNT(*) FILTER (WHERE day_diff <= 3) / COUNT(*) AS pct_lt_3days_gaps,
        100.0 * COUNT(*) FILTER (WHERE day_diff <= 7) / COUNT(*) AS pct_lt_week_gaps,
        100.0 * COUNT(*) FILTER (WHERE day_diff > 14) / COUNT(*) AS pct_gt_2weeks_gaps
    FROM filtered_diffs
    GROUP BY classroom_id
),

dow_counts AS (
    SELECT
        classroom_id,
        EXTRACT(DOW FROM writing_creation_date) AS dow,
        COUNT(*) AS count_sessions
    FROM classrooms_and_kids_created_2024
    GROUP BY classroom_id, dow
),

most_active_dow AS (
    SELECT DISTINCT ON (classroom_id)
        classroom_id,
        dow AS most_active_day_of_week
    FROM dow_counts
    ORDER BY classroom_id, count_sessions DESC
),

main_grade_per_classroom AS (
    SELECT DISTINCT ON (classroom_id)
        classroom_id,
        grade AS main_grade
    FROM (
        SELECT
            classroom_id,
            grade,
            COUNT(*) AS grade_count
        FROM classrooms_and_kids_created_2024
        GROUP BY classroom_id, grade
    ) sub
    ORDER BY classroom_id, grade_count DESC
),

grades_per_classroom AS (
    SELECT
        classroom_id,
        STRING_AGG(DISTINCT grade, ', ' ORDER BY grade) AS grades
    FROM classrooms_and_kids_created_2024
    GROUP BY classroom_id
),

agg AS (
    SELECT 
        classroom_id,
        COUNT(DISTINCT kid_id) AS kids_count,
        COUNT(1) AS writings_count,
        COUNT(DISTINCT writing_creation_date::DATE) AS writing_day_session_count,

        COUNT(DISTINCT writing_creation_date::DATE) FILTER (
            WHERE EXTRACT(DOW FROM writing_creation_date) IN (0, 6)
        ) AS weekend_day_session_count,

        COUNT(DISTINCT writing_creation_date::DATE) FILTER (
            WHERE writing_creation_date::TIME > TIME '19:00'
        ) AS evening_day_session_count
    FROM classrooms_and_kids_created_2024
    GROUP BY classroom_id
),

-- Compute proportion of kids present per session
session_participation AS (
    SELECT
        classroom_id,
        writing_creation_date::DATE AS session_day,
        COUNT(DISTINCT kid_id) AS kids_present
    FROM classrooms_and_kids_created_2024
    GROUP BY classroom_id, writing_creation_date::DATE
),

-- Join with total number of kids per classroom
session_participation_with_proportion AS (
    SELECT
        sp.classroom_id,
        sp.session_day,
        sp.kids_present,
        a.kids_count,
        100.0 * sp.kids_present / NULLIF(a.kids_count, 0) AS kids_participation_ratio
    FROM session_participation sp
    JOIN agg a ON sp.classroom_id = a.classroom_id
),

-- Aggregate proportions per classroom
participation_stats AS (
    SELECT
        classroom_id,
        AVG(kids_participation_ratio) AS avg_kids_participation_ratio,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY kids_participation_ratio) AS median_kids_participation_ratio
    FROM session_participation_with_proportion
    GROUP BY classroom_id
),

-- Calculate participation per session (classroom_id + date)
participation_per_session AS (
    SELECT 
        classroom_id,
        writing_creation_date::DATE AS session_day,
        COUNT(DISTINCT kid_id) AS kids_present
    FROM classrooms_and_kids_created_2024
    GROUP BY classroom_id, session_day
),

-- Add total kids per classroom to compute participation ratio
participation_with_ratio AS (
    SELECT 
        p.classroom_id,
        p.session_day,
        p.kids_present,
        agg.kids_count,
        1.0 * p.kids_present / NULLIF(agg.kids_count, 0) AS participation_ratio
    FROM participation_per_session p
    JOIN agg ON p.classroom_id = agg.classroom_id
),

-- For sessions with >= 25% participation
qualified_sessions_25 AS (
    SELECT * FROM participation_with_ratio
    WHERE participation_ratio >= 0.25
),

-- For sessions with >= 50% participation
qualified_sessions_50 AS (
    SELECT * FROM participation_with_ratio
    WHERE participation_ratio >= 0.50
),

-- Compute day diffs for 25% threshold
session_diffs_25 AS (
    SELECT 
        classroom_id,
        session_day,
        session_day - LAG(session_day) OVER (
            PARTITION BY classroom_id ORDER BY session_day
        ) AS day_diff
    FROM qualified_sessions_25
),

-- Compute day diffs for 50% threshold
session_diffs_50 AS (
    SELECT 
        classroom_id,
        session_day,
        session_day - LAG(session_day) OVER (
            PARTITION BY classroom_id ORDER BY session_day
        ) AS day_diff
    FROM qualified_sessions_50
),

-- Filter out NULL diffs (first session per class)
filtered_diffs_25 AS (
    SELECT classroom_id, day_diff FROM session_diffs_25 WHERE day_diff IS NOT NULL
),

filtered_diffs_50 AS (
    SELECT classroom_id, day_diff FROM session_diffs_50 WHERE day_diff IS NOT NULL
),

-- Aggregate stats for each threshold
stats_qualified_sessions AS (
    SELECT 
        f25.classroom_id,
        AVG(f25.day_diff) AS avg_day_gap_25pct,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f25.day_diff) AS median_day_gap_25pct,
        AVG(f50.day_diff) AS avg_day_gap_50pct,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY f50.day_diff) AS median_day_gap_50pct
    FROM filtered_diffs_25 f25
    LEFT JOIN filtered_diffs_50 f50 ON f25.classroom_id = f50.classroom_id
    GROUP BY f25.classroom_id
),


classrooms_stats AS (
    SELECT 
        a.*,
        mg.main_grade,
        gc.grades,
        a.writings_count / a.kids_count AS writings_per_kid,
        s.avg_day_gap,
        s.median_day_gap,
        s.min_day_gap,
        s.max_day_gap,
        s.pct_lt_3days_gaps,
        s.pct_lt_week_gaps,
        s.pct_gt_2weeks_gaps,
        m.most_active_day_of_week,
        ps.avg_kids_participation_ratio,
        ps.median_kids_participation_ratio,
        sqs.avg_day_gap_25pct,
        sqs.median_day_gap_25pct,
        sqs.avg_day_gap_50pct,
        sqs.median_day_gap_50pct,
        100.0 * a.weekend_day_session_count / NULLIF(a.writing_day_session_count, 0) AS pct_weekend_sessions,
        100.0 * a.evening_day_session_count / NULLIF(a.writing_day_session_count, 0) AS pct_evening_sessions

    FROM agg a
    LEFT JOIN stats s ON a.classroom_id = s.classroom_id
    LEFT JOIN most_active_dow m ON a.classroom_id = m.classroom_id
    LEFT JOIN main_grade_per_classroom mg ON a.classroom_id = mg.classroom_id
    LEFT JOIN grades_per_classroom gc ON a.classroom_id = gc.classroom_id
    LEFT JOIN participation_stats ps ON a.classroom_id = ps.classroom_id
    LEFT JOIN stats_qualified_sessions sqs ON a.classroom_id = sqs.classroom_id
),

-- Adding User subscription type

classrooms_stats_user_infos AS (
SELECT 
    classrooms_stats.classroom_id,
    user_classrooms.user_id
FROM classrooms_stats
LEFT JOIN user_classrooms ON classrooms_stats.classroom_id = user_classrooms.classroom_id
),

subscriptions_selection AS (
SELECT 
    *
FROM subscriptions
WHERE user_id IN (SELECT user_id FROM classrooms_stats_user_infos)
),

unique_subscriptions AS (
SELECT 
    *
FROM subscriptions_selection t
WHERE created_at = (
    SELECT MAX(created_at)
    FROM subscriptions_selection
    WHERE user_id = t.user_id
)
),

unique_subscriptions_with_planinfos AS (
SELECT 
    unique_subscriptions.user_id,
    unique_subscriptions.period_start_at AS subscription_start,
    unique_subscriptions.period_end_at AS subscription_end,
    unique_subscriptions.status AS subscription_status,
    unique_subscriptions.gift_card_id,
    unique_subscriptions.plan_id,
    plans.category AS plan_category,
    plans.name AS plan_name,
    plans.price_cents AS price_subscription,
    COALESCE(plans.price_cents > 0, FALSE) AS payer
FROM unique_subscriptions
LEFT JOIN plans
ON unique_subscriptions.plan_id = plans.id
),

classrooms_stats_subscription_infos AS (
SELECT 
    classrooms_stats_user_infos.*,
    unique_subscriptions_with_planinfos.payer
FROM classrooms_stats_user_infos
LEFT JOIN unique_subscriptions_with_planinfos ON classrooms_stats_user_infos.user_id = unique_subscriptions_with_planinfos.user_id
),

unique_classrooms_stats_subscription_infos AS (
SELECT 
    classrooms_stats_subscription_infos.classroom_id,
    BOOL_OR(classrooms_stats_subscription_infos.payer) AS payer
FROM classrooms_stats_subscription_infos
GROUP BY classroom_id
),

classrooms_stats_payer_infos AS (
SELECT 
    classrooms_stats.*,
    unique_classrooms_stats_subscription_infos.payer
FROM classrooms_stats
LEFT JOIN unique_classrooms_stats_subscription_infos ON classrooms_stats.classroom_id = unique_classrooms_stats_subscription_infos.classroom_id
)

SELECT * FROM classrooms_stats_payer_infos