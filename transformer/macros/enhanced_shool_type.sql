{% macro get_enhanced_school_type(school_type, school_name) %}
    CASE
    
    WHEN {{ school_type }} IS NULL OR {{ school_name }} IS NULL THEN NULL

    WHEN {{ school_type }} = 'elementary' THEN 'elementary'
    WHEN unaccent(lower({{ school_name }})) LIKE '%ecole primaire%' THEN 'elementary'
    WHEN unaccent(lower({{ school_name }})) LIKE '%ecole elementaire%' THEN 'elementary'
    WHEN {{ school_type }} = 'middle_school' THEN 'middle_school'
    WHEN unaccent(lower({{ school_name }})) LIKE '%college%' THEN 'middle_school'
    WHEN {{ school_type }} = 'high_school' THEN 'high_school'

    ELSE {{ school_type }}
    
    END 
{% endmacro %}
