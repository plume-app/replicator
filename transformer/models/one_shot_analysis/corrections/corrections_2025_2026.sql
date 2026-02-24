WITH classrooms_2024_2025 AS (
SELECT
    *
FROM classrooms
WHERE 
    created_at BETWEEN '2024-09-01' AND '2025-03-01'
    AND
    kids_count > 5
),

classrooms_2024_2025_kids AS (
SELECT 
    classrooms_2024_2025.id AS classroom_id,
    classrooms_2024_2025.created_at AS classroom_creation_date,
    kid_classrooms.kid_id,
    kids.grade,
    kids.grade_at
FROM classrooms_2024_2025
INNER JOIN kid_classrooms ON classrooms_2024_2025.id = kid_classrooms.classroom_id
INNER JOIN kids ON kid_classrooms.kid_id = kids.id
WHERE kids.grade_at BETWEEN '2024-09-01' AND '2025-03-01'
),

filtered_classrooms AS (
    SELECT
        classroom_id
    FROM classrooms_2024_2025_kids
    GROUP BY classroom_id
    HAVING COUNT(*) >= 5
),

classrooms_2024_2025_kids_filtered AS (
SELECT 
    *
FROM classrooms_2024_2025_kids
WHERE classroom_id IN (SELECT classroom_id FROM filtered_classrooms)
),

classrooms_2024_2025_writings AS (
SELECT 
    classrooms_2024_2025_kids_filtered.*,
    writings.id AS writing_id,
    writings.created_at AS writing_creation_date,
    writings.writable_type,
    writings.chapter_id
FROM classrooms_2024_2025_kids_filtered
INNER JOIN writings
ON classrooms_2024_2025_kids_filtered.kid_id = writings.kid_id
WHERE writings.created_at BETWEEN '2024-09-01' AND '2025-05-01'
),

filtered_writings_kids AS (
    SELECT
        kid_id
    FROM classrooms_2024_2025_writings
    GROUP BY kid_id
    HAVING COUNT(*) >= 1
),

classrooms_2024_2025_writings_filtered_by_kids AS (
SELECT 
    *
FROM classrooms_2024_2025_writings
WHERE kid_id IN (SELECT kid_id FROM filtered_writings_kids)
),

filtered_writings_classrooms AS (
    SELECT
        classroom_id
    FROM classrooms_2024_2025_writings_filtered_by_kids
    GROUP BY classroom_id
    HAVING COUNT(DISTINCT kid_id) >= 5
),

classrooms_2024_2025_classrooms_filtered AS (
SELECT 
    *
FROM classrooms_2024_2025_writings_filtered_by_kids
WHERE classroom_id IN (SELECT classroom_id FROM filtered_writings_classrooms)
), 

classrooms_2024_2025_classrooms_filtered_writings AS (
SELECT 
    *
FROM classrooms_2024_2025_classrooms_filtered
WHERE 
    writable_type IN ('KidStory', 'KidPrompt')
    AND (
        chapter_id NOT IN ('1194', '1195', '1196', '1197')
        AND chapter_id NOT IN ('1567', '1568', '1569', '1570')
        OR chapter_id IS NULL
    )
),

classrooms_2024_2025_classrooms_filtered_corrections AS (
    SELECT 
        w.*,
        -- Count of corrections with non-empty content
        COALESCE(c.corrections_count, 0) AS corrections_count
    FROM classrooms_2024_2025_classrooms_filtered_writings w
    LEFT JOIN (
        SELECT 
            writing_id,
            COUNT(*) AS corrections_count
        FROM corrections
        WHERE content IS NOT NULL
          AND content <> ''
        GROUP BY writing_id
    ) c ON c.writing_id = w.writing_id
),


classrooms_2024_2025_classrooms_filtered_corrections_boolean AS (
SELECT 
    *,
    corrections_count > 0 AS has_correction
FROM classrooms_2024_2025_classrooms_filtered_corrections
),




classrooms_2024_2025_classrooms_users AS (
SELECT 
    classrooms_2024_2025_classrooms_filtered_corrections_boolean.*,
    usage_2024_2025.*,
    CASE 
        WHEN usage_2024_2025.students_writings_count_2024_2025 BETWEEN 0 AND 100 THEN 'G1 : 100 écrits'
        WHEN usage_2024_2025.students_writings_count_2024_2025 BETWEEN 101 AND 250 THEN 'G2 : 250 écrits'
        WHEN usage_2024_2025.students_writings_count_2024_2025 BETWEEN 251 AND 500 THEN 'G3 : 500 écrits'
        WHEN usage_2024_2025.students_writings_count_2024_2025 > 500 THEN 'G4 : 501+ écrits'
        ELSE NULL 
    END AS niveau_usage
FROM classrooms_2024_2025_classrooms_filtered_corrections_boolean
INNER JOIN user_classrooms ON classrooms_2024_2025_classrooms_filtered_corrections_boolean.classroom_id = user_classrooms.classroom_id
INNER JOIN {{ ref('usage_by_geo_zones_2024_2025') }} AS usage_2024_2025 ON user_classrooms.user_id = usage_2024_2025.user_id
),

classrooms_2024_2025_classrooms_distinct_writing_id AS (
SELECT DISTINCT ON (writing_id)
    classrooms_2024_2025_classrooms_users.*
FROM classrooms_2024_2025_classrooms_users
)

SELECT * FROM classrooms_2024_2025_classrooms_distinct_writing_id