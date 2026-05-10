UPDATE members
SET 
    birthdate = $2,
    updated_at = NOW()
WHERE hca_id = $1
RETURNING
    hca_id,
    slack_id,
    birthdate,
    created_at,
    updated_at