CREATE TABLE IF NOT EXISTS items (
    item_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    category_id UUID NOT NULL REFERENCES categories(category_id) ON DELETE RESTRICT,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    brand VARCHAR(255),
    model VARCHAR(255),
    unit VARCHAR(50) NOT NULL DEFAULT 'cái',
    image VARCHAR(500),
    status INTEGER NOT NULL DEFAULT 1,
    created_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    updated_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(category_id, item_name)
);
