SELECT * FROM (
    SELECT date_trunc('day', "source"."created_at") AS "created_at",
            count(distinct "source"."id") AS "count"
    FROM (
        SELECT "public"."writings"."id" AS "id",
                CASE WHEN "Universes"."kind" = 0 THEN 'Story'
                WHEN "Universes"."kind" = 1 THEN 'Challenge'
                WHEN "Universes"."kind" = 2 THEN 'Free_writing'
                ELSE 'Other' END AS "universe_kind_string",
                "public"."writings"."created_at" AS "created_at",
                "Kids"."student" AS "Kids__student",
                "Universes"."kind" AS "Universes__kind"
        FROM "public"."writings"
        LEFT JOIN "public"."chapters" "Chapters" ON "public"."writings"."chapter_id" = "Chapters"."id"
        LEFT JOIN "public"."stories" "Stories" ON "public"."writings"."story_id" = "Stories"."id"
        LEFT JOIN "public"."universes" "Universes" ON "Stories"."universe_id" = "Universes"."id"
        LEFT JOIN "public"."kids" "Kids" ON "public"."writings"."kid_id" = "Kids"."id"
        WHERE "Kids"."demo" IS NOT TRUE
    ) "source"
    WHERE (
        "source"."created_at" >= date_trunc('day', CAST((CAST(now() AS timestamp) + (INTERVAL '-30 day')) AS timestamp))
        AND "source"."created_at" < date_trunc('day', CAST((CAST(now() AS timestamp) + (INTERVAL '1 day')) AS timestamp))
    )
    GROUP BY "source"."universe_kind_string", date_trunc('day', "source"."created_at")
    UNION
    SELECT date_trunc('day', "source2"."created_at") AS "created_at",
        count(distinct "source2"."id") AS "count"
    FROM (
        SELECT 'Daily Word' AS "universe_kind_string",
            "public"."kid_daily_words"."id",
            "public"."kid_daily_words"."created_at" AS "created_at",
            "Kids"."student" AS "Kids__student"
        FROM "public"."kid_daily_words"
        LEFT JOIN "public"."kids" "Kids" ON "public"."kid_daily_words"."kid_id" = "Kids"."id"
        WHERE "Kids"."demo" IS NOT TRUE
    ) "source2"
    WHERE (
        "source2"."created_at" >= date_trunc('day', CAST((CAST(now() AS timestamp) + (INTERVAL '-30 day')) AS timestamp))
        AND "source2"."created_at" < date_trunc('day', CAST((CAST(now() AS timestamp) + (INTERVAL '1 day')) AS timestamp))
    )
    GROUP BY "source2"."universe_kind_string", date_trunc('day', "source2"."created_at")
    UNION
    SELECT date_trunc('day', "source3"."created_at") AS "created_at",
        count(distinct "source3"."id") AS "count"
    FROM (
        SELECT 'Dojo' AS "universe_kind_string",
            "public"."dojos_kid_games"."id",
            "public"."dojos_kid_games"."created_at" AS "created_at",
            "Kids"."student" AS "Kids__student"
        FROM "public"."dojos_kid_games"
        LEFT JOIN "public"."kids" "Kids" ON "public"."dojos_kid_games"."kid_id" = "Kids"."id"
        WHERE "Kids"."demo" IS NOT TRUE
    ) "source3"
    WHERE (
        "source3"."created_at" >= date_trunc('day', CAST((CAST(now() AS timestamp) + (INTERVAL '-30 day')) AS timestamp))
        AND "source3"."created_at" < date_trunc('day', CAST((CAST(now() AS timestamp) + (INTERVAL '1 day')) AS timestamp))
    )
    GROUP BY  date_trunc('day', "source3"."created_at")
) "target"
ORDER BY "count" DESC, date_trunc('day', "target"."created_at") ASC