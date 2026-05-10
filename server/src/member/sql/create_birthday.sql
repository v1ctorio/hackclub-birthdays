INSERT INTO members (hca_id, slack_id, birthday)
VALUES ($1, $2, $3)
RETURNING
    hca_id,
    slack_id,
    birthday,
    created_at,
    updated_at