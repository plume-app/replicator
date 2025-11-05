-- WAT = Weekly Active Teacher

WITH params AS (
    SELECT
        CEIL(EXTRACT(EPOCH FROM (date_trunc('week', now() - INTERVAL '1 day') + INTERVAL '1 day' - DATE '2025-08-11')) / (7*24*60*60))::int AS weeks
),
filtered_users as (
    SELECT users.id as user_id
    FROM users 
    WHERE users.locale = 'fr'
    AND users.provider = 'gar'
), filtered_kids as (
    SELECT kids.id as kid_id, fu.user_id as user_id
    FROM kids
    JOIN kid_classrooms ON kid_classrooms.kid_id = kids.id 
    JOIN user_classrooms ON user_classrooms.classroom_id = kid_classrooms.classroom_id
    JOIN filtered_users fu ON fu.user_id = user_classrooms.user_id
    WHERE kids.student = true
),wrt as (
    SELECT writings.created_at, writings.kid_id, fk.user_id
    FROM writings
    JOIN filtered_kids fk ON fk.kid_id = writings.kid_id
    WHERE writings.created_at >= date_trunc('week', now() - ((SELECT weeks FROM params) * INTERVAL '1 week') - INTERVAL '1 day') + INTERVAL '1 day'
),dkg as (
    SELECT dojos_kid_games.created_at, dojos_kid_games.kid_id, fk.user_id
    FROM dojos_kid_games
    JOIN filtered_kids fk ON fk.kid_id = dojos_kid_games.kid_id
    WHERE dojos_kid_games.created_at >= date_trunc('week', now() - ((SELECT weeks FROM params) * INTERVAL '1 week') - INTERVAL '1 day') + INTERVAL '1 day'
),kdw as (
    SELECT kid_daily_words.created_at, kid_daily_words.kid_id, fk.user_id
    FROM kid_daily_words
    JOIN filtered_kids fk ON fk.kid_id = kid_daily_words.kid_id
    WHERE kid_daily_words.created_at >= date_trunc('week', now() - ((SELECT weeks FROM params) * INTERVAL '1 week') - INTERVAL '1 day') + INTERVAL '1 day'
),base_data as (
SELECT COUNT(DISTINCT subquery.user_id) as "count", subquery.activity_date as "activity_date"
FROM (
  SELECT wrt.user_id, date_trunc('week', wrt.created_at) as "activity_date" 
  FROM wrt

  UNION ALL

  SELECT dkg.user_id, date_trunc('week', dkg.created_at) as "activity_date"
  FROM dkg

  UNION ALL

  SELECT kdw.user_id, date_trunc('week', kdw.created_at) as "activity_date"
  FROM kdw
) subquery
GROUP BY activity_date
), donnees_v2 as (
    select "count", "activity_date" from base_data
), moyenne as (
    select round(avg("count")) as "Moyenne" from donnees_v2
) select * from donnees_v2, "moyenne"