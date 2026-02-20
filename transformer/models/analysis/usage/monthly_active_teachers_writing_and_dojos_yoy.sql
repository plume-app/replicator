WITH combined_activity AS (
   -- Selecting students based on writings
   SELECT 
      kid_id, 
      writings.created_at
   FROM "public"."writings"
   JOIN kids ON kid_id = kids.id
   WHERE kids.student = 'true' AND kids.demo IS NOT TRUE

   UNION

   -- Selecting students based on dojos_kid_game
   SELECT 
      kid_id,
      "dojos_kid_games"."created_at"
   FROM "dojos_kid_games"
   JOIN kids ON "dojos_kid_games".kid_id = kids.id
   WHERE kids.student = 'true' AND kids.demo IS NOT TRUE
),

teacher_activity AS (
    SELECT 
        "user_classrooms"."user_id" AS teacher_id,
        "combined_activity"."created_at"
    FROM combined_activity
    JOIN "kid_classrooms" ON "combined_activity"."kid_id" = "kid_classrooms"."kid_id"
    JOIN "classrooms" ON "kid_classrooms"."classroom_id" = "classrooms"."id" AND "classrooms"."demo" IS NOT TRUE
    JOIN "user_classrooms" ON "kid_classrooms"."classroom_id" = "user_classrooms"."classroom_id"
)

SELECT 
    CASE 
        WHEN EXTRACT(MONTH FROM "source"."created_at") BETWEEN 8 AND 12 THEN 
            CONCAT(CAST(EXTRACT(YEAR FROM "source"."created_at") AS TEXT), '/', CAST(EXTRACT(YEAR FROM "source"."created_at") + 1 AS TEXT))
        ELSE
            CONCAT(CAST(EXTRACT(YEAR FROM "source"."created_at") - 1 AS TEXT), '/', CAST(EXTRACT(YEAR FROM "source"."created_at") AS TEXT))
    END AS "year",
    
    CASE 
        WHEN EXTRACT(MONTH FROM "source"."created_at") BETWEEN 8 AND 12 THEN 
            EXTRACT(MONTH FROM "source"."created_at") - 7
        ELSE
            EXTRACT(MONTH FROM "source"."created_at") + 5
    END AS "month",
    
    COUNT(DISTINCT "source"."teacher_id") AS "count"
    
FROM teacher_activity AS "source"
    
WHERE "source"."created_at" >= timestamp with time zone '2021-08-01 00:00:00.000Z'
GROUP BY 
    CASE 
        WHEN EXTRACT(MONTH FROM "source"."created_at") BETWEEN 8 AND 12 THEN 
            CONCAT(CAST(EXTRACT(YEAR FROM "source"."created_at") AS TEXT), '/', CAST(EXTRACT(YEAR FROM "source"."created_at") + 1 AS TEXT))
        ELSE
            CONCAT(CAST(EXTRACT(YEAR FROM "source"."created_at") - 1 AS TEXT), '/', CAST(EXTRACT(YEAR FROM "source"."created_at") AS TEXT))
    END,
    CASE 
        WHEN EXTRACT(MONTH FROM "source"."created_at") BETWEEN 8 AND 12 THEN 
            EXTRACT(MONTH FROM "source"."created_at") - 7
        ELSE
            EXTRACT(MONTH FROM "source"."created_at") + 5
    END
ORDER BY "month" ASC, "year" ASC