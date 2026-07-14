INSERT INTO members (hca_id, slack_id)
VALUES ($1, $2)
ON CONFLICT (hca_id) DO NOTHING
RETURNING
    hca_id,
    slack_id,
    birthdate
