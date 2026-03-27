CREATE TABLE IF NOT EXISTS rooms(
    room_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    floor_id UUID NOT NULL REFERENCES floors(floor_id) ON DELETE RESTRICT,
    room_name VARCHAR(255) NOT NULL,
    room_description VARCHAR(255) NOT NULL,
    room_image VARCHAR(255) NOT NULL,
    room_status VARCHAR(20) NOT NULL DEFAULT 'available' CHECK (room_status IN ('available', 'using', 'maintenance')),
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
    created_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    updated_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT
);