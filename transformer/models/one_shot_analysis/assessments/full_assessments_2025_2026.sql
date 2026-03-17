WITH base_writings AS (
  SELECT
    w.id AS writing_id,
    w.created_at AS writing_creation_date,
    w.content AS writing_content,
    w.writable_id,
    w.kid_activity_id,
    w.step_id,
    w.kid_id
  FROM writings w
  WHERE
    w.created_at >= '2025-10-01'
    AND w.writable_type = 'KidAssessment'
    AND w.publication_status = 'published'
),
assessment_rows AS (
  SELECT
    bw.writing_id,
    bw.writing_creation_date,
    bw.writing_content,
    bw.writable_id,
    bw.kid_activity_id,
    bw.step_id,
    bw.kid_id,
    k.grade AS kid_grade,
    st.type AS step_type,
    st.instruction,
    st.sentence_starter,
    st.text_to_transcript,
    st.text_to_improve,
    st.image_description,
    act.title AS assessment_activity_title,
    ka.status AS kid_activity_status,
    act.id AS activity_id,
    act.activitable_id,
    a.steps_count AS assessment_steps_count
  FROM base_writings bw
  INNER JOIN assessments_steps st ON st.id = bw.step_id
  INNER JOIN assessments a ON a.id = st.assessment_id
  INNER JOIN activities act ON act.activitable_id = a.id AND act.kind = 'assessment'
  INNER JOIN kid_activities ka ON ka.id = bw.kid_activity_id AND ka.status = 1
  INNER JOIN kids k ON k.id = bw.kid_id
),
skills_by_writing AS (
  SELECT
    ks.skillable_id AS writing_id,
    MAX(ks.score) FILTER (WHERE s.domain = 'understanding') AS understanding,
    MAX(ks.score) FILTER (WHERE s.domain = 'language_mastery') AS language_mastery,
    MAX(ks.score) FILTER (WHERE s.domain = 'structure') AS structure,
    MAX(ks.score) FILTER (WHERE s.domain = 'expression') AS expression,
    MAX(ks.score) FILTER (WHERE s.domain = 'revision') AS revision,
    MAX(ks.score) FILTER (WHERE s.domain = 'keyboard_proficiency') AS keyboard_proficiency
  FROM kid_skills ks
  INNER JOIN skills s ON s.id = ks.skill_id
  GROUP BY ks.skillable_id
),
completed_steps AS (
  SELECT
    kid_activity_id,
    COUNT(DISTINCT step_id) AS completed_steps_count
  FROM base_writings
  GROUP BY kid_activity_id
)
SELECT
  ar.*,
  sbw.understanding,
  sbw.language_mastery,
  sbw.structure,
  sbw.expression,
  sbw.revision,
  sbw.keyboard_proficiency,
  cs.completed_steps_count
FROM assessment_rows ar
INNER JOIN skills_by_writing sbw ON sbw.writing_id = ar.writing_id
INNER JOIN completed_steps cs ON cs.kid_activity_id = ar.kid_activity_id
WHERE ar.assessment_steps_count = cs.completed_steps_count
