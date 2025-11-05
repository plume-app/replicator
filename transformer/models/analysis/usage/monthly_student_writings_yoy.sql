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
    
    COUNT(*) AS "count"
    
FROM (
   SELECT kid_id, writings.id, writings.created_at, CAST(extract(year from "public"."writings"."created_at") AS integer) AS "year" 
   FROM "public"."writings"
   JOIN kids ON kid_id = kids.id
   WHERE kids.student = 'true' AND kids.demo = 'false'
   
) "source"
    
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