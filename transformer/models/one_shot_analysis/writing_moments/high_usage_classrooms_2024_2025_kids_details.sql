WITH classrooms_2024_2025 AS (
SELECT
    *
FROM classrooms
WHERE 
    created_at BETWEEN '2024-09-01' AND '2024-11-30'
    AND
    kids_count > 15
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
WHERE kids.grade_at BETWEEN '2024-09-01' AND '2024-11-30'
),

filtered_classrooms AS (
    SELECT
        classroom_id
    FROM classrooms_2024_2025_kids
    GROUP BY classroom_id
    HAVING COUNT(*) >= 15
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
    writings.created_at AS writing_creation_date,
    writings.writable_type
FROM classrooms_2024_2025_kids_filtered
INNER JOIN writings
ON classrooms_2024_2025_kids_filtered.kid_id = writings.kid_id
WHERE writings.created_at BETWEEN '2024-09-01' AND '2025-06-30'
),

filtered_writings_kids AS (
    SELECT
        kid_id
    FROM classrooms_2024_2025_writings
    GROUP BY kid_id
    HAVING COUNT(*) >= 10
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
    HAVING COUNT(DISTINCT kid_id) >= 15
),

classrooms_2024_2025_classrooms_filtered AS (
SELECT 
    *
FROM classrooms_2024_2025_writings_filtered_by_kids
WHERE classroom_id IN (SELECT classroom_id FROM filtered_writings_classrooms)
)

SELECT * FROM classrooms_2024_2025_classrooms_filtered