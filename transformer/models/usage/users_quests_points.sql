WITH users_quests_points AS (
SELECT 
    user_id,
    SUM(in_app_quests.points) AS quests_points_total
FROM quests_completions
INNER JOIN in_app_quests ON quests_completions.quest_id = in_app_quests.id
GROUP BY user_id
)

SELECT
    user_id,
    quests_points_total,
    CASE
        WHEN quests_points_total >= 26650 THEN 'P20 - Plume de Diamant'
        WHEN quests_points_total >= 24000 THEN 'P19 - Plume de Platine'
        WHEN quests_points_total >= 21500 THEN 'P18 - Plume d’Émeraude'
        WHEN quests_points_total >= 19150 THEN 'P17 - Plume de Rubis'
        WHEN quests_points_total >= 16950 THEN 'P16 - Plume de Saphir'
        WHEN quests_points_total >= 14900 THEN 'P15 - Plume de Nacre'
        WHEN quests_points_total >= 13000 THEN 'P14 - Plume d’Opale'
        WHEN quests_points_total >= 11250 THEN 'P13 - Plume de Corail'
        WHEN quests_points_total >= 9650  THEN 'P12 - Plume de Cristal'
        WHEN quests_points_total >= 8200  THEN 'P11 - Plume d''Or'
        WHEN quests_points_total >= 6900  THEN 'P10 - Plume de Jade'
        WHEN quests_points_total >= 5750  THEN 'P9 - Plume d’Ambre'
        WHEN quests_points_total >= 4650  THEN 'P8 - Plume d''Argent'
        WHEN quests_points_total >= 3600  THEN 'P7 - Plume de Porcelaine'
        WHEN quests_points_total >= 2650  THEN 'P6 - Plume de Turquoise'
        WHEN quests_points_total >= 1850  THEN 'P5 - Plume de Lavande'
        WHEN quests_points_total >= 1200  THEN 'P4 - Plume de Bronze'
        WHEN quests_points_total >= 700   THEN 'P3 - Plume de Rose'
        WHEN quests_points_total >= 300   THEN 'P2 - Plume d’Encre'
        ELSE 'P1 - Plume de Papier'
    END AS quests_points_category
FROM users_quests_points