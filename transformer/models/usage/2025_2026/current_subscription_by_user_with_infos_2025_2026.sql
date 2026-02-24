{{ config(
   materialized="view"
) }}

WITH user_metrics_2025_2026 AS (
SELECT 
    user_id,
    school_year,
    students_writings_count,
    student_writing_corrections_count,
    visits,
    classrooms_created_count,
    students_created_count,
    student_dojo_activities_count,
    cycles,
    tags,
    premium_subscription AS premium
FROM user_metrics
WHERE school_year = '2025_2026'
),

user_metrics_2025_2026_with_school_id AS (
SELECT 
    users.id AS user_id,
    user_metrics_2025_2026.school_year,
    COALESCE(user_metrics_2025_2026.students_writings_count, 0) AS students_writings_count,
    COALESCE(user_metrics_2025_2026.student_writing_corrections_count, 0) AS student_writing_corrections_count,
    COALESCE(user_metrics_2025_2026.visits, 0) AS visits,
    COALESCE(user_metrics_2025_2026.classrooms_created_count, 0) AS classrooms_created_count,
    COALESCE(user_metrics_2025_2026.students_created_count, 0) AS students_created_count,
    COALESCE(user_metrics_2025_2026.student_dojo_activities_count, 0) AS student_dojo_activities_count,
    user_metrics_2025_2026.cycles,
    user_metrics_2025_2026.tags,
    user_metrics_2025_2026.premium,
    users.school_id,
    users.first_name,
    users.last_name,
    users.email,
    users.contact_email,
    users.phone,
    users.hubspot_id,
    users.created_at AS user_creation_date,
    users.provider,
    users.tags AS user_tags,
    users.account_type AS user_account_type,
    users.active AS user_active,
    users.locale AS user_locale
FROM user_metrics_2025_2026
RIGHT JOIN users
ON user_metrics_2025_2026.user_id = users.id
),

school_adresses_cleaned AS (
SELECT DISTINCT ON (school_id) 
    school_id,
    country,
    city,
    zip AS address_zip,
    street
FROM addresses
ORDER BY school_id, updated_at DESC
),

user_metrics_2025_2026_with_school_adress AS (
SELECT 
    user_metrics_2025_2026_with_school_id.*,
    school_adresses_cleaned.country,
    school_adresses_cleaned.city AS school_city,
    school_adresses_cleaned.address_zip,
    school_adresses_cleaned.street AS school_street
FROM user_metrics_2025_2026_with_school_id
LEFT JOIN school_adresses_cleaned 
ON user_metrics_2025_2026_with_school_id.school_id = school_adresses_cleaned.school_id
),

user_metrics_2025_2026_with_school_infos AS (
SELECT 
    user_metrics_2025_2026_with_school_adress.user_id,
    user_metrics_2025_2026_with_school_adress.students_writings_count AS students_writings_count_2025_2026,
    user_metrics_2025_2026_with_school_adress.student_writing_corrections_count AS students_writings_corrections_count_2025_2026,
    user_metrics_2025_2026_with_school_adress.visits AS visits_2025_2026,
    user_metrics_2025_2026_with_school_adress.classrooms_created_count AS classrooms_created_count_2025_2026,
    user_metrics_2025_2026_with_school_adress.students_created_count AS students_created_count_2025_2026,
    user_metrics_2025_2026_with_school_adress.student_dojo_activities_count AS student_dojo_activities_count_2025_2026,
    user_metrics_2025_2026_with_school_adress.school_id,
    schools.contract_type AS school_contract_type,
    user_metrics_2025_2026_with_school_adress.country AS school_country,
    user_metrics_2025_2026_with_school_adress.school_city,
    user_metrics_2025_2026_with_school_adress.address_zip AS school_zipcode,
    user_metrics_2025_2026_with_school_adress.school_street,
    schools.academy AS school_academy,
    schools.name AS school_name,
    schools.name || ' (id = ' || schools.id || ')' AS school_label,
    schools.kind AS school_type,
    schools.uai AS school_uai,
    user_metrics_2025_2026_with_school_adress.first_name,
    user_metrics_2025_2026_with_school_adress.last_name,
    user_metrics_2025_2026_with_school_adress.user_creation_date,
    user_metrics_2025_2026_with_school_adress.email,
    user_metrics_2025_2026_with_school_adress.contact_email,
    user_metrics_2025_2026_with_school_adress.phone,
    user_metrics_2025_2026_with_school_adress.premium,
    user_metrics_2025_2026_with_school_adress.cycles,
    user_metrics_2025_2026_with_school_adress.tags,
    user_metrics_2025_2026_with_school_adress.provider,
    user_metrics_2025_2026_with_school_adress.hubspot_id,
    user_metrics_2025_2026_with_school_adress.user_tags,
    (
      'contest-les-petits-molieres' = ANY(string_to_array(user_metrics_2025_2026_with_school_adress.user_tags, ','))
      AND NOT 'contest-les-petits-molieres-2025' = ANY(string_to_array(user_metrics_2025_2026_with_school_adress.user_tags, ','))
    ) AS lpm_2024_2025,
    user_metrics_2025_2026_with_school_adress.user_tags ILIKE '%contest_les-petits-molieres-2025%' AS lpm_2025_2026,
    user_metrics_2025_2026_with_school_adress.user_tags ILIKE '%ambassadeur-25-26%' AS ambassadeur_2025_2026,
    user_metrics_2025_2026_with_school_adress.user_tags ILIKE '%expé-25-26%' AS expe_2025_2026,
    user_metrics_2025_2026_with_school_adress.user_account_type,
    user_metrics_2025_2026_with_school_adress.user_active,
    user_metrics_2025_2026_with_school_adress.user_locale
FROM user_metrics_2025_2026_with_school_adress
LEFT JOIN schools 
ON user_metrics_2025_2026_with_school_adress.school_id = schools.id
),

unique_subscriptions AS (
SELECT DISTINCT ON (user_id) 
    *
FROM subscriptions
WHERE period_end_at IS NOT NULL
  -- AND period_end_at >= CURRENT_DATE  -- still active
ORDER BY 
    user_id, 
    CASE 
        WHEN plan_id IN (48, 19, 53, 54, 59, 60, 61, 62, 106, 145, 146, 180, 213, 214, 215, 216) THEN 1  -- prioritize premium subscriptions
        ELSE 2                                       -- free or challenge plans last
    END ASC,
    period_end_at DESC, 
    period_start_at DESC
),

unique_subscriptions_2025_2026 AS (
SELECT 
    *
FROM unique_subscriptions
WHERE 
    unique_subscriptions.period_start_at BETWEEN '2025-08-15' AND '2026-07-15'
    OR 
    unique_subscriptions.period_end_at >= '2025-08-16'
),

unique_subscriptions_with_planinfos AS (
SELECT 
    unique_subscriptions_2025_2026.user_id,
    unique_subscriptions_2025_2026.created_at AS subscription_creation_date,
    unique_subscriptions_2025_2026.period_start_at AS subscription_start,
    unique_subscriptions_2025_2026.period_end_at AS subscription_end,
    unique_subscriptions_2025_2026.status AS subscription_status,
    unique_subscriptions_2025_2026.gift_card_id,
    CASE 
        WHEN (unique_subscriptions_2025_2026.stripe_subscription_id IS NOT NULL AND TRIM(unique_subscriptions_2025_2026.stripe_subscription_id) <> '')
                OR 
            (unique_subscriptions_2025_2026.stripe_intent_id IS NOT NULL AND TRIM(unique_subscriptions_2025_2026.stripe_intent_id) <> '')
        THEN true
        ELSE false
    END AS stripe_payment,
    unique_subscriptions_2025_2026.stripe_intent_id,
    unique_subscriptions_2025_2026.stripe_subscription_id,
    unique_subscriptions_2025_2026.plan_id,
    unique_subscriptions_2025_2026.test,
    CASE
        WHEN unique_subscriptions_2025_2026.cancel_at IS NULL THEN FALSE
        ELSE TRUE
    END AS canceled,
    unique_subscriptions_2025_2026.cancel_at,
    unique_subscriptions_2025_2026.cancel_reason,
    unique_subscriptions_2025_2026.trial_canceled_at,
    unique_subscriptions_2025_2026.cancel_at::date - unique_subscriptions_2025_2026.period_start_at::date AS day_delay_cancelation_subscription_start,
    unique_subscriptions_2025_2026.cancel_at::date - unique_subscriptions_2025_2026.created_at::date AS day_delay_cancelation_subscription_creation,
    plans.category AS plan_category,
    plans.name AS plan_name,
    plans.slug AS plan_slug,
    plans.price_cents AS price_subscription,
    COALESCE(plans.price_cents > 0, FALSE) AS payer,
    gift_cards.gift_cards_campaign_id,
    gift_cards.code AS gift_card_code,
    gift_cards_campaigns.name AS gift_card_campaign_name
FROM unique_subscriptions_2025_2026
LEFT JOIN plans ON unique_subscriptions_2025_2026.plan_id = plans.id
LEFT JOIN gift_cards ON unique_subscriptions_2025_2026.gift_card_id = gift_cards.id
LEFT JOIN gift_cards_campaigns ON gift_cards.gift_cards_campaign_id = gift_cards_campaigns.id
),

users_2025_2026_subscriptions_infos AS (
SELECT 
    user_metrics_2025_2026_with_school_infos.*,
    unique_subscriptions_with_planinfos.subscription_creation_date,
    unique_subscriptions_with_planinfos.subscription_start,
    unique_subscriptions_with_planinfos.subscription_end,
    unique_subscriptions_with_planinfos.subscription_status,
    unique_subscriptions_with_planinfos.gift_card_id,
    unique_subscriptions_with_planinfos.gift_card_code,
    unique_subscriptions_with_planinfos.gift_cards_campaign_id,
    unique_subscriptions_with_planinfos.gift_card_campaign_name,
    unique_subscriptions_with_planinfos.stripe_payment,
    unique_subscriptions_with_planinfos.stripe_intent_id,
    unique_subscriptions_with_planinfos.stripe_subscription_id,
    unique_subscriptions_with_planinfos.plan_id,
    unique_subscriptions_with_planinfos.plan_category,
    unique_subscriptions_with_planinfos.plan_name,
    unique_subscriptions_with_planinfos.plan_slug,
    unique_subscriptions_with_planinfos.price_subscription AS price_subscription_cents,
    ROUND(unique_subscriptions_with_planinfos.price_subscription / 100.0, 2) AS price_subscription,
    unique_subscriptions_with_planinfos.payer,
    unique_subscriptions_with_planinfos.canceled,
    unique_subscriptions_with_planinfos.cancel_at,
    unique_subscriptions_with_planinfos.cancel_reason,
    unique_subscriptions_with_planinfos.trial_canceled_at,
    unique_subscriptions_with_planinfos.test,
    day_delay_cancelation_subscription_start,
    day_delay_cancelation_subscription_creation
FROM user_metrics_2025_2026_with_school_infos
LEFT JOIN unique_subscriptions_with_planinfos ON user_metrics_2025_2026_with_school_infos.user_id = unique_subscriptions_with_planinfos.user_id
),

classrooms_names_2025_2026 AS (
SELECT
    uc.user_id,
    string_agg(c.name, ',' ORDER BY c.name) AS classrooms_names
FROM user_classrooms uc
JOIN classrooms c
    ON uc.classroom_id = c.id
    AND c.demo IS NOT TRUE
WHERE uc.created_at >= '2025-08-15'
GROUP BY uc.user_id
),

user_count_by_school_id AS (
SELECT
    school_id,
    COUNT(DISTINCT id) AS nb_users_in_school_id
FROM users
GROUP BY school_id
),

users_2025_2026_classrooms_schools_infos AS (
SELECT 
    users_2025_2026_subscriptions_infos.*,
    classrooms_names_2025_2026.classrooms_names,
    user_count_by_school_id.nb_users_in_school_id
FROM users_2025_2026_subscriptions_infos
LEFT JOIN classrooms_names_2025_2026 ON users_2025_2026_subscriptions_infos.user_id = classrooms_names_2025_2026.user_id
LEFT JOIN user_count_by_school_id ON users_2025_2026_subscriptions_infos.school_id = user_count_by_school_id.school_id
),

infos_users_2025_2026_previous_years_infos AS (
SELECT 
    users_2025_2026_classrooms_schools_infos.*,
    user_metrics_2024_2025.students_writings_count AS students_writings_count_2024_2025,
    user_metrics_2023_2024.students_writings_count AS students_writings_count_2023_2024
FROM users_2025_2026_classrooms_schools_infos
LEFT JOIN user_metrics AS user_metrics_2024_2025
    ON users_2025_2026_classrooms_schools_infos.user_id = user_metrics_2024_2025.user_id
   AND user_metrics_2024_2025.school_year = '2024_2025'
LEFT JOIN user_metrics AS user_metrics_2023_2024
    ON users_2025_2026_classrooms_schools_infos.user_id = user_metrics_2023_2024.user_id
   AND user_metrics_2023_2024.school_year = '2023_2024'
),

infos_users_2025_2026_additional_infos AS (
SELECT 
    infos_users_2025_2026_previous_years_infos.*,
    first_visit_device.device_type AS device_type_first_visit,
    users_quests_points.quests_points_total,
    users_quests_points.quests_points_category
FROM infos_users_2025_2026_previous_years_infos
LEFT JOIN {{ ref('first_visit_device') }} AS first_visit_device
    ON infos_users_2025_2026_previous_years_infos.user_id = first_visit_device.user_id
LEFT JOIN {{ ref('users_quests_points') }} AS users_quests_points
    ON infos_users_2025_2026_previous_years_infos.user_id = users_quests_points.user_id
)

SELECT * FROM infos_users_2025_2026_additional_infos