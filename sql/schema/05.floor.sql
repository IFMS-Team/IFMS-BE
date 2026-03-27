CREATE TABLE IF NOT EXISTS floors(
    floor_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    building_id UUID NOT NULL REFERENCES buildings(building_id) ON DELETE RESTRICT,
    floor_name VARCHAR(255) NOT NULL,
    floor_description VARCHAR(255) NOT NULL,
    floor_image VARCHAR(255) NOT NULL,
    floor_status INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    maximum_room INTEGER NOT NULL DEFAULT 0,
    created_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    updated_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT
);