WITH user_metrics_2024_2025 AS (
SELECT 
    user_id,
    school_year,
    students_writings_count,
    student_writing_corrections_count,
    student_dojo_activities_count,
    visits,
    classrooms_created_count,
    students_created_count,
    cycles,
    tags,
    premium_subscription AS premium
FROM user_metrics
WHERE school_year = '2024_2025'
),

user_metrics_2024_2025_with_school_id AS (
SELECT 
    users.id AS user_id,
    user_metrics_2024_2025.school_year,
    COALESCE(user_metrics_2024_2025.students_writings_count, 0) AS students_writings_count,
    COALESCE(user_metrics_2024_2025.student_writing_corrections_count, 0) AS student_writing_corrections_count,
    COALESCE(user_metrics_2024_2025.student_dojo_activities_count, 0) AS student_dojo_activities_count,
    COALESCE(user_metrics_2024_2025.visits, 0) AS visits,
    COALESCE(user_metrics_2024_2025.classrooms_created_count, 0) AS classrooms_created_count,
    COALESCE(user_metrics_2024_2025.students_created_count, 0) AS students_created_count,
    user_metrics_2024_2025.cycles,
    user_metrics_2024_2025.tags,
    user_metrics_2024_2025.premium,
    users.school_id,
    users.first_name,
    users.last_name,
    users.email,
    users.phone,
    users.hubspot_id,
    users.created_at AS user_creation_date,
    users.provider,
    users.tags AS user_tags,
    users.account_type AS user_account_type,
    users.active AS user_active
FROM user_metrics_2024_2025
LEFT JOIN users
ON user_metrics_2024_2025.user_id = users.id
),

school_adresses_cleaned AS (
SELECT DISTINCT ON (school_id) 
    school_id,
    country,
    city,
    zip AS address_zip
FROM addresses
ORDER BY school_id, updated_at DESC
),

user_metrics_2024_2025_with_school_adress AS (
SELECT 
    user_metrics_2024_2025_with_school_id.*,
    school_adresses_cleaned.country,
    school_adresses_cleaned.city AS school_city,
    school_adresses_cleaned.address_zip
FROM user_metrics_2024_2025_with_school_id
LEFT JOIN school_adresses_cleaned 
ON user_metrics_2024_2025_with_school_id.school_id = school_adresses_cleaned.school_id
),

user_metrics_2024_2025_with_school_infos AS (
SELECT 
    user_metrics_2024_2025_with_school_adress.user_id,
    user_metrics_2024_2025_with_school_adress.first_name,
    user_metrics_2024_2025_with_school_adress.last_name,
    user_metrics_2024_2025_with_school_adress.email,
    user_metrics_2024_2025_with_school_adress.phone,
    user_metrics_2024_2025_with_school_adress.cycles,
    user_metrics_2024_2025_with_school_adress.premium,
    user_metrics_2024_2025_with_school_adress.user_creation_date,
    user_metrics_2024_2025_with_school_adress.students_writings_count AS students_writings_count_2024_2025,
    user_metrics_2024_2025_with_school_adress.student_writing_corrections_count AS students_writings_corrections_count_2024_2025,
    user_metrics_2024_2025_with_school_adress.student_dojo_activities_count AS student_dojo_activities_count_2024_2025,
    user_metrics_2024_2025_with_school_adress.visits AS visits_2024_2025,
    user_metrics_2024_2025_with_school_adress.classrooms_created_count AS classrooms_created_count_2024_2025,
    user_metrics_2024_2025_with_school_adress.students_created_count AS students_created_count_2024_2025,
    user_metrics_2024_2025_with_school_adress.school_id,
    schools.contract_type AS school_contract_type,
    user_metrics_2024_2025_with_school_adress.country AS school_country,
    user_metrics_2024_2025_with_school_adress.school_city,
    user_metrics_2024_2025_with_school_adress.address_zip AS school_zipcode,
    schools.academy AS school_academy,
    schools.name AS school_name,
    schools.name || ' (id = ' || schools.id || ')' AS school_label,
    schools.kind AS school_type,
    {{ get_enhanced_school_type(school_type="schools.kind", school_name="schools.name") }} AS school_type_enhanced,
    schools.uai AS school_uai,
    user_metrics_2024_2025_with_school_adress.tags,
    user_metrics_2024_2025_with_school_adress.provider,
    user_metrics_2024_2025_with_school_adress.hubspot_id,
    user_metrics_2024_2025_with_school_adress.user_tags,
    user_metrics_2024_2025_with_school_adress.user_account_type,
    user_metrics_2024_2025_with_school_adress.user_active
FROM user_metrics_2024_2025_with_school_adress
LEFT JOIN schools 
ON user_metrics_2024_2025_with_school_adress.school_id = schools.id
),

user_metrics_2024_2025_geo_infos AS (
SELECT
    *,
    {{ get_departement_name(country="school_country", zipcode="school_zipcode") }} AS department_name,
    {{ get_region_name(country="school_country", zipcode="school_zipcode") }} AS region_name
FROM user_metrics_2024_2025_with_school_infos
)

SELECT * FROM user_metrics_2024_2025_geo_infos