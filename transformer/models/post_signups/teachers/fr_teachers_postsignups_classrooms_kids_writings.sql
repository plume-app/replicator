{{ config(
    materialized="incremental",
    unique_key="user_id",
    incremental_strategy="delete+insert"
) }}

WITH signups_teachers_classrooms AS (
SELECT 
    signups_teachers.*,
    user_classrooms.classroom_id,
    user_classrooms.created_at AS classroom_creation_date
FROM {{ ref('fr_teachers_postsignups') }} AS signups_teachers
LEFT JOIN user_classrooms ON signups_teachers.user_id = user_classrooms.user_id
LEFT JOIN classrooms ON user_classrooms.classroom_id = classrooms.id
WHERE classrooms.demo IS NOT TRUE
{% if is_incremental() %}
    AND signups_teachers.user_creation_date >= current_date - interval '60 days'
{% endif %}
),

signups_teachers_classrooms_kids AS (
SELECT 
    signups_teachers_classrooms.*,
    kids.id AS kid_id,
    kids.created_at AS kid_creation_date,
    kids.grade AS kid_grade
FROM signups_teachers_classrooms
LEFT JOIN kid_classrooms ON signups_teachers_classrooms.classroom_id = kid_classrooms.classroom_id
LEFT JOIN kids ON kid_classrooms.kid_id = kids.id
WHERE kids.demo IS NOT TRUE
),

signups_teachers_writings AS (
SELECT 
    signups_teachers_classrooms_kids.*,
    writings.id AS writing_id,
    writings.created_at AS writing_creation_date
FROM signups_teachers_classrooms_kids
LEFT JOIN writings ON signups_teachers_classrooms_kids.kid_id = writings.kid_id
)

SELECT * FROM signups_teachers_writings