INSERT INTO members (hca_id, slack_id, birthdate)
VALUES ($1, $2, $3)
RETURNING
    hca_id,
    slack_id,
    birthdate,
    created_at,
    updated_at