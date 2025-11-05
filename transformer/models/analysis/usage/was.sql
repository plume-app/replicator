-- WAS = Weekly Active Student

WITH params AS (
    SELECT
        CEIL(EXTRACT(EPOCH FROM (date_trunc('week', now() - INTERVAL '1 day') + INTERVAL '1 day' - DATE '2025-08-11')) / (7*24*60*60))::int AS weeks
),
filtered_users AS (
    SELECT users.id AS user_id
    FROM users 
    WHERE users.locale = 'fr'
), 
filtered_kids AS (
    SELECT kids.id AS kid_id, fu.user_id AS user_id
    FROM kids
    JOIN kid_classrooms ON kid_classrooms.kid_id = kids.id
    JOIN user_classrooms ON user_classrooms.classroom_id = kid_classrooms.classroom_id
    JOIN filtered_users fu ON fu.user_id = user_classrooms.user_id
    WHERE kids.student IS true
), 
wrt AS (
    SELECT writings.updated_at, writings.created_at, writings.kid_id, fk.user_id
    FROM writings
    JOIN filtered_kids fk ON fk.kid_id = writings.kid_id
    WHERE writings.updated_at >= date_trunc('week', now() - ((SELECT weeks FROM params) * INTERVAL '1 week'))
       OR writings.created_at >= date_trunc('week', now() - ((SELECT weeks FROM params) * INTERVAL '1 week'))
), 
dkg AS (
    SELECT dojos_kid_games.updated_at, dojos_kid_games.created_at, dojos_kid_games.kid_id, fk.user_id
    FROM dojos_kid_games
    JOIN filtered_kids fk ON fk.kid_id = dojos_kid_games.kid_id
    WHERE dojos_kid_games.updated_at >= date_trunc('week', now() - ((SELECT weeks FROM params) * INTERVAL '1 week'))
       OR dojos_kid_games.created_at >= date_trunc('week', now() - ((SELECT weeks FROM params) * INTERVAL '1 week'))
), 
base_data AS (
    SELECT COUNT(DISTINCT subquery.kid_id) AS "count", subquery.activity_date AS "activity_date"
    FROM (
        SELECT wrt.kid_id, date_trunc('week', wrt.updated_at) AS "activity_date"
        FROM wrt
        UNION ALL
        SELECT wrt.kid_id, date_trunc('week', wrt.created_at) AS "activity_date"
        FROM wrt
        UNION ALL
        SELECT dkg.kid_id, date_trunc('week', dkg.updated_at) AS "activity_date"
        FROM dkg
        UNION ALL
        SELECT dkg.kid_id, date_trunc('week', dkg.created_at) AS "activity_date"
        FROM dkg
    ) subquery
    where activity_date >= date_trunc('week', now() - ((SELECT weeks FROM params) * INTERVAL '1 week'))
    GROUP BY activity_date
), 
donnees_v2 AS (
    SELECT "count", "activity_date" 
    FROM base_data
), 
moyenne AS (
    SELECT ROUND(AVG("count")) AS "Moyenne" 
    FROM donnees_v2
) 
SELECT * 
FROM donnees_v2, moyenne
