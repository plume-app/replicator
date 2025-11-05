SELECT
  CAST("public"."writings"."created_at" AS date) AS "created_at",
  COUNT(*) AS "count"
FROM
  "public"."writings"
 
LEFT JOIN "public"."kids" AS "Kids" ON "public"."writings"."kid_id" = "Kids"."id"
WHERE
  ("Kids"."student" = TRUE)
 
   AND (
    "public"."writings"."created_at" >= timestamp '2024-08-27 00:00:00.000'
  )
  AND (
    (
      "public"."writings"."publication_status" = CAST('published' AS "varchar")
    )
   
    OR (
      "public"."writings"."publication_status" = CAST('draft' AS "varchar")
    )
  )
GROUP BY
  CAST("public"."writings"."created_at" AS date)
ORDER BY
  CAST("public"."writings"."created_at" AS date) ASC