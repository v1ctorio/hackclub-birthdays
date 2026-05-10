CREATE TABLE members (
    hca_id TEXT PRIMARY KEY, -- Hack Club Account subject identifier
    slack_id TEXT NOT NULL, -- TODO - make it not necessary for users to have a slack acc (id)
    birthdate DATE DEFAULT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
)