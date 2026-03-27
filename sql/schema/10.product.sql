CREATE TABLE IF NOT EXISTS products (
    product_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    item_id UUID NOT NULL REFERENCES items(item_id) ON DELETE RESTRICT,
    room_id UUID REFERENCES rooms(room_id) ON DELETE SET NULL,
    serial_number VARCHAR(255) UNIQUE,
    qr_code VARCHAR(500) UNIQUE,
    purchase_date DATE,
    purchase_price DECIMAL(15, 2),
    warranty_start DATE,
    warranty_end DATE,
    supplier VARCHAR(255),
    condition VARCHAR(50) NOT NULL DEFAULT 'new',
    status INTEGER NOT NULL DEFAULT 1,
    note TEXT,
    image VARCHAR(500),
    created_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    updated_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_products_item_id ON products(item_id);
CREATE INDEX IF NOT EXISTS idx_products_room_id ON products(room_id);
CREATE INDEX IF NOT EXISTS idx_products_serial ON products(serial_number);
CREATE INDEX IF NOT EXISTS idx_products_qr_code ON products(qr_code);
CREATE INDEX IF NOT EXISTS idx_products_warranty_end ON products(warranty_end);
CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
