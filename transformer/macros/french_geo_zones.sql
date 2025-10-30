{% macro get_departement_name(country, zipcode) %}
    CASE
    
    WHEN {{ country }} IS NULL OR {{ zipcode }} IS NULL THEN NULL
    WHEN CAST({{ zipcode }} AS TEXT) = '' THEN NULL

    -- Metropolitan departments
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(01)' THEN '01 - Ain'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(02)' THEN '02 - Aisne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(03)' THEN '03 - Allier'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(04)' THEN '04 - Alpes-de-Haute-Provence'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(05)' THEN '05 - Hautes-Alpes'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(06)' THEN '06 - Alpes-Maritimes'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(07)' THEN '07 - Ardèche'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(08)' THEN '08 - Ardennes'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(09)' THEN '09 - Ariège'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(10)' THEN '10 - Aube'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(11)' THEN '11 - Aude'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(12)' THEN '12 - Aveyron'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(13)' THEN '13 - Bouches-du-Rhône'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(14)' THEN '14 - Calvados'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(15)' THEN '15 - Cantal'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(16)' THEN '16 - Charente'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(17)' THEN '17 - Charente-Maritime'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(18)' THEN '18 - Cher'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(19)' THEN '19 - Corrèze'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(2A|20[0-1])' THEN '2A - Corse-du-Sud'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(2B|20[2-9])' THEN '2B - Haute-Corse'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(21)' THEN '21 - Côte-d''Or'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(22)' THEN '22 - Côtes-d''Armor'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(23)' THEN '23 - Creuse'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(24)' THEN '24 - Dordogne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(25)' THEN '25 - Doubs'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(26)' THEN '26 - Drôme'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(27)' THEN '27 - Eure'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(28)' THEN '28 - Eure-et-Loir'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(29)' THEN '29 - Finistère'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(30)' THEN '30 - Gard'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(31)' THEN '31 - Haute-Garonne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(32)' THEN '32 - Gers'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(33)' THEN '33 - Gironde'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(34)' THEN '34 - Hérault'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(35)' THEN '35 - Ille-et-Vilaine'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(36)' THEN '36 - Indre'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(37)' THEN '37 - Indre-et-Loire'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(38)' THEN '38 - Isère'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(39)' THEN '39 - Jura'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(40)' THEN '40 - Landes'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(41)' THEN '41 - Loir-et-Cher'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(42)' THEN '42 - Loire'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(43)' THEN '43 - Haute-Loire'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(44)' THEN '44 - Loire-Atlantique'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(45)' THEN '45 - Loiret'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(46)' THEN '46 - Lot'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(47)' THEN '47 - Lot-et-Garonne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(48)' THEN '48 - Lozère'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(49)' THEN '49 - Maine-et-Loire'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(50)' THEN '50 - Manche'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(51)' THEN '51 - Marne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(52)' THEN '52 - Haute-Marne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(53)' THEN '53 - Mayenne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(54)' THEN '54 - Meurthe-et-Moselle'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(55)' THEN '55 - Meuse'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(56)' THEN '56 - Morbihan'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(57)' THEN '57 - Moselle'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(58)' THEN '58 - Nièvre'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(59)' THEN '59 - Nord'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(60)' THEN '60 - Oise'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(61)' THEN '61 - Orne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(62)' THEN '62 - Pas-de-Calais'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(63)' THEN '63 - Puy-de-Dôme'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(64)' THEN '64 - Pyrénées-Atlantiques'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(65)' THEN '65 - Hautes-Pyrénées'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(66)' THEN '66 - Pyrénées-Orientales'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(67)' THEN '67 - Bas-Rhin'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(68)' THEN '68 - Haut-Rhin'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(69)' THEN '69 - Rhône'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(70)' THEN '70 - Haute-Saône'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(71)' THEN '71 - Saône-et-Loire'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(72)' THEN '72 - Sarthe'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(73)' THEN '73 - Savoie'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(74)' THEN '74 - Haute-Savoie'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(75)' THEN '75 - Paris'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(76)' THEN '76 - Seine-Maritime'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(77)' THEN '77 - Seine-et-Marne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(78)' THEN '78 - Yvelines'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(79)' THEN '79 - Deux-Sèvres'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(80)' THEN '80 - Somme'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(81)' THEN '81 - Tarn'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(82)' THEN '82 - Tarn-et-Garonne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(83)' THEN '83 - Var'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(84)' THEN '84 - Vaucluse'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(85)' THEN '85 - Vendée'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(86)' THEN '86 - Vienne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(87)' THEN '87 - Haute-Vienne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(88)' THEN '88 - Vosges'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(89)' THEN '89 - Yonne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(90)' THEN '90 - Territoire de Belfort'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(91)' THEN '91 - Essonne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(92)' THEN '92 - Hauts-de-Seine'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(93)' THEN '93 - Seine-Saint-Denis'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(94)' THEN '94 - Val-de-Marne'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(95)' THEN '95 - Val-d''Oise'

    -- Overseas departments (DROM)
    WHEN {{ country }} IN ('FR','GP') AND CAST({{ zipcode }} AS TEXT) ~ '^(971)' THEN '971 - Guadeloupe'
    WHEN {{ country }} IN ('FR','MQ') AND CAST({{ zipcode }} AS TEXT) ~ '^(972)' THEN '972 - Martinique'
    WHEN {{ country }} IN ('FR','GF') AND CAST({{ zipcode }} AS TEXT) ~ '^(973)' THEN '973 - Guyane'
    WHEN {{ country }} IN ('FR','RE') AND CAST({{ zipcode }} AS TEXT) ~ '^(974)' THEN '974 - La Réunion'
    WHEN {{ country }} IN ('FR','YT') AND CAST({{ zipcode }} AS TEXT) ~ '^(976)' THEN '976 - Mayotte'
    
    -- Overseas collectivities (COM + TAAF)
    WHEN {{ country }} IN ('FR','PM') AND CAST({{ zipcode }} AS TEXT) ~ '^(975)' THEN '975 - Saint-Pierre-et-Miquelon'
    WHEN {{ country }} IN ('FR','WF') AND CAST({{ zipcode }} AS TEXT) ~ '^(986)' THEN '986 - Wallis-et-Futuna'
    WHEN {{ country }} IN ('FR','PF') AND CAST({{ zipcode }} AS TEXT) ~ '^(987)' THEN '987 - Polynésie française'
    WHEN {{ country }} IN ('FR','NC') AND CAST({{ zipcode }} AS TEXT) ~ '^(988)' THEN '988 - Nouvelle-Calédonie'
    WHEN {{ country }} = 'FR' AND CAST({{ zipcode }} AS TEXT) ~ '^(989)' THEN '989 - Clipperton'

    ELSE NULL
    END
{% endmacro %}


{% macro get_region_name(country, zipcode) %}
    CASE

    WHEN {{ country }} IS NULL OR {{ zipcode }} IS NULL THEN NULL
    WHEN CAST({{ zipcode }} AS TEXT) = '' THEN NULL

    WHEN {{ country }} NOT IN ('FR', 'GP', 'MQ', 'GF', 'RE', 'YT', 'PM', 'WF', 'PF', 'NC') THEN NULL

    -- Auvergne-Rhône-Alpes
    WHEN {{ zipcode }} ~ '^(01|03|07|15|26|38|42|43|63|69|73|74)' THEN 'Auvergne-Rhône-Alpes'

    -- Bourgogne-Franche-Comté
    WHEN {{ zipcode }} ~ '^(21|25|39|58|70|71|89|90)' THEN 'Bourgogne-Franche-Comté'

    -- Bretagne
    WHEN {{ zipcode }} ~ '^(22|29|35|56)' THEN 'Bretagne'

    -- Centre-Val de Loire
    WHEN {{ zipcode }} ~ '^(18|28|36|37|41|45)' THEN 'Centre-Val de Loire'

    -- Corse
    WHEN {{ zipcode }} ~ '^(2A|20[0-1])' THEN 'Corse' -- Corse-du-Sud
    WHEN {{ zipcode }} ~ '^(2B|20[6-9])' THEN 'Corse' -- Haute-Corse

    -- Grand Est
    WHEN {{ zipcode }} ~ '^(08|10|51|52|54|55|57|67|68|88)' THEN 'Grand Est'

    -- Hauts-de-France
    WHEN {{ zipcode }} ~ '^(02|59|60|62|80)' THEN 'Hauts-de-France'

    -- Île-de-France
    WHEN {{ zipcode }} ~ '^(75|77|78|91|92|93|94|95)' THEN 'Île-de-France'

    -- Normandie
    WHEN {{ zipcode }} ~ '^(14|27|50|61|76)' THEN 'Normandie'

    -- Nouvelle-Aquitaine
    WHEN {{ zipcode }} ~ '^(16|17|19|23|24|33|40|47|64|79|86|87)' THEN 'Nouvelle-Aquitaine'

    -- Occitanie
    WHEN {{ zipcode }} ~ '^(09|11|12|30|31|32|34|46|48|65|66|81|82)' THEN 'Occitanie'

    -- Pays de la Loire
    WHEN {{ zipcode }} ~ '^(44|49|53|72|85)' THEN 'Pays de la Loire'

    -- Provence-Alpes-Côte d’Azur
    WHEN {{ zipcode }} ~ '^(04|05|06|13|83|84)' THEN 'Provence-Alpes-Côte d’Azur'

    -- Overseas regions (DROM)
    WHEN {{ zipcode }} ~ '^(971)' THEN 'Guadeloupe'
    WHEN {{ zipcode }} ~ '^(972)' THEN 'Martinique'
    WHEN {{ zipcode }} ~ '^(973)' THEN 'Guyane'
    WHEN {{ zipcode }} ~ '^(974)' THEN 'La Réunion'
    WHEN {{ zipcode }} ~ '^(976)' THEN 'Mayotte'

    -- Overseas collectivities (COM / POM)
    WHEN {{ zipcode }} ~ '^(975)' THEN 'Saint-Pierre-et-Miquelon'
    WHEN {{ zipcode }} ~ '^(986)' THEN 'Wallis-et-Futuna'
    WHEN {{ zipcode }} ~ '^(987)' THEN 'Polynésie française'
    WHEN {{ zipcode }} ~ '^(988)' THEN 'Nouvelle-Calédonie'
    WHEN {{ zipcode }} ~ '^(989)' THEN 'Clipperton'

    ELSE NULL

    END
{% endmacro %}

