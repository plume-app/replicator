WITH user_infos_2025_2026 AS (
    SELECT * FROM {{ ref('current_subscription_by_user_with_infos_2025_2026') }}
),

user_infos_2025_2026_formatted AS (
SELECT 
    user_infos_2025_2026.user_id,
    user_infos_2025_2026.first_name,
    user_infos_2025_2026.last_name,
    user_infos_2025_2026.email,
    user_infos_2025_2026.phone,
    user_infos_2025_2026.cycles,
    user_infos_2025_2026.classrooms_names,
    user_infos_2025_2026.premium,
    COALESCE(user_infos_2025_2026.payer, false) AS payer_2025_2026,
    user_infos_2025_2026.lpm_2024_2025,
    user_infos_2025_2026.lpm_2025_2026,
    user_infos_2025_2026.ambassadeur_2025_2026,
    user_infos_2025_2026.expe_2025_2026,
    user_infos_2025_2026.provider = 'gar' AS gar,
    user_infos_2025_2026.user_tags ILIKE '%expé%' AS expe,
    COALESCE(user_infos_2025_2026.canceled, false) AS canceled,
    user_infos_2025_2026.cancel_reason,
    user_infos_2025_2026.students_writings_count_2025_2026,
    user_infos_2025_2026.students_writings_corrections_count_2025_2026,
    user_infos_2025_2026.visits_2025_2026,
    user_infos_2025_2026.classrooms_created_count_2025_2026,
    user_infos_2025_2026.students_created_count_2025_2026,
    user_infos_2025_2026.user_creation_date,
    user_infos_2025_2026.user_account_type,
    user_infos_2025_2026.tags,
    user_infos_2025_2026.user_tags,
    user_infos_2025_2026.subscription_creation_date,
    user_infos_2025_2026.subscription_start,
    user_infos_2025_2026.subscription_end,
    user_infos_2025_2026.subscription_status,
    user_infos_2025_2026.plan_id,
    user_infos_2025_2026.plan_name,
    user_infos_2025_2026.plan_slug,
    user_infos_2025_2026.price_subscription,
    user_infos_2025_2026.school_id,
    user_infos_2025_2026.school_name,
    user_infos_2025_2026.school_contract_type,
    user_infos_2025_2026.school_type,
    CASE
        WHEN user_infos_2025_2026.school_type = 'elementary' THEN 'elementary'
        WHEN unaccent(lower(user_infos_2025_2026.school_name)) LIKE '%ecole primaire%' THEN 'elementary'
        WHEN unaccent(lower(user_infos_2025_2026.school_name)) LIKE '%ecole elementaire%' THEN 'elementary'
        WHEN user_infos_2025_2026.school_type = 'middle_school' THEN 'middle_school'
        WHEN unaccent(lower(user_infos_2025_2026.school_name)) LIKE '%college%' THEN 'middle_school'
        WHEN user_infos_2025_2026.school_type = 'high_school' THEN 'high_school'
        ELSE user_infos_2025_2026.school_type
    END AS school_type_enhanced,
    user_infos_2025_2026.school_country,
    user_infos_2025_2026.school_academy,
    user_infos_2025_2026.school_city,
    user_infos_2025_2026.school_zipcode,
    user_infos_2025_2026.school_street,
    user_infos_2025_2026.test,
    user_infos_2025_2026.gift_card_id,
    user_infos_2025_2026.gift_card_code,
    user_infos_2025_2026.gift_card_campaign_name,
    user_infos_2025_2026.stripe_payment,
    -- user_infos_2025_2026.stripe_intent_id,
    -- user_infos_2025_2026.stripe_subscription_id,
    user_infos_2025_2026.students_writings_count_2024_2025,
    user_infos_2025_2026.students_writings_count_2023_2024
FROM user_infos_2025_2026
ORDER BY user_infos_2025_2026.students_writings_count_2025_2026 DESC
)


SELECT * FROM user_infos_2025_2026_formatted