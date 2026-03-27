CREATE TABLE IF NOT EXISTS analytics_snapshots (
    snapshot_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    snapshot_date DATE NOT NULL UNIQUE,
    total_buildings INT NOT NULL DEFAULT 0,
    total_floors INT NOT NULL DEFAULT 0,
    total_rooms INT NOT NULL DEFAULT 0,
    total_categories INT NOT NULL DEFAULT 0,
    total_items INT NOT NULL DEFAULT 0,
    total_products INT NOT NULL DEFAULT 0,
    total_users INT NOT NULL DEFAULT 0,
    products_active INT NOT NULL DEFAULT 0,
    products_maintenance INT NOT NULL DEFAULT 0,
    products_damaged INT NOT NULL DEFAULT 0,
    products_disposed INT NOT NULL DEFAULT 0,
    products_warranty_expiring INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_analytics_snapshot_date ON analytics_snapshots(snapshot_date);
