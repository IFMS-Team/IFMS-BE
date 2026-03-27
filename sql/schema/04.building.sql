CREATE TABLE IF NOT EXISTS buildings(
    building_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    building_name VARCHAR(255) NOT NULL,
    building_address VARCHAR(255) NOT NULL,
    building_description VARCHAR(255) NOT NULL,
    building_image VARCHAR(255) NOT NULL,
    building_status INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    maximum_floor INTEGER NOT NULL DEFAULT 0,
    created_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    updated_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT
);