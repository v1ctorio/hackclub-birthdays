SELECT
  hca_id,
  slack_id,
  birthdate
FROM members
WHERE hca_id = $1