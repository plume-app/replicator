WITH combined_activity AS (
   -- Selecting students based on writings
   SELECT 
      kid_id, 
      writings.created_at
   FROM "public"."writings"
   JOIN kids ON kid_id = kids.id
   WHERE kids.student = 'true' AND kids.demo = 'false'

   UNION

   -- Selecting students based on dojos_kid_game
   SELECT 
      kid_id,
      "dojos_kid_games"."created_at"
   FROM "dojos_kid_games"
   JOIN kids ON "dojos_kid_games".kid_id = kids.id
   WHERE kids.student = 'true' AND kids.demo = 'false'
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
    
    COUNT(DISTINCT "source"."kid_id") AS "count"
    
FROM combined_activity AS "source"
    
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