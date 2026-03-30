CREATE TABLE IF NOT EXISTS users (
    user_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(20) NOT NULL UNIQUE CHECK (username ~ '^[a-zA-Z0-9_]{3,20}$'),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(50) NOT NULL DEFAULT '',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status VARCHAR(10) NOT NULL DEFAULT 'Enable' CHECK (status IN ('Enable', 'Disable')),
    phone VARCHAR(12) NOT NULL CHECK (phone ~ '^(\+84|0)[0-9]{9}$'),
    address VARCHAR(255) NOT NULL,
    cccd VARCHAR(12) NOT NULL UNIQUE CHECK (cccd ~ '^[0-9]{9}$|^[0-9]{12}$'),
    role_id UUID NOT NULL REFERENCES roles(role_id) ON DELETE RESTRICT
);
