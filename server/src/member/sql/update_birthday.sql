UPDATE members
SET 
    birthday = $2,
    updated_at = NOW()
WHERE hca_id = $1
RETURNING
    hca_id,
    slack_id,
    birthday,
    created_at,
    updated_at