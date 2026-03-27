-- ===================== DASHBOARD OVERVIEW =====================

-- name: GetDashboardOverview :one
SELECT
    (SELECT COUNT(*) FROM buildings)::int AS total_buildings,
    (SELECT COUNT(*) FROM floors)::int AS total_floors,
    (SELECT COUNT(*) FROM rooms)::int AS total_rooms,
    (SELECT COUNT(*) FROM categories)::int AS total_categories,
    (SELECT COUNT(*) FROM items)::int AS total_items,
    (SELECT COUNT(*) FROM products)::int AS total_products,
    (SELECT COUNT(*) FROM users)::int AS total_users;

-- ===================== PRODUCTS BY STATUS =====================

-- name: GetProductsByStatus :many
SELECT
    status,
    COUNT(*)::int AS total
FROM products
GROUP BY status
ORDER BY status;

-- ===================== PRODUCTS BY CATEGORY =====================

-- name: GetProductCountByCategory :many
SELECT
    c.category_id,
    c.category_name,
    COUNT(p.product_id)::int AS total_products
FROM categories c
LEFT JOIN items i ON c.category_id = i.category_id
LEFT JOIN products p ON i.item_id = p.item_id
GROUP BY c.category_id, c.category_name
ORDER BY total_products DESC;

-- ===================== PRODUCTS BY BUILDING =====================

-- name: GetProductCountByBuilding :many
SELECT
    b.building_id,
    b.building_name,
    COUNT(p.product_id)::int AS total_products
FROM buildings b
LEFT JOIN floors f ON b.building_id = f.building_id
LEFT JOIN rooms r ON f.floor_id = r.floor_id
LEFT JOIN products p ON r.room_id = p.room_id
GROUP BY b.building_id, b.building_name
ORDER BY total_products DESC;

-- ===================== WARRANTY =====================

-- name: GetProductsWarrantyExpiringSoon :many
SELECT
    p.product_id,
    p.serial_number,
    p.warranty_end,
    i.item_name,
    c.category_name,
    r.room_name
FROM products p
JOIN items i ON p.item_id = i.item_id
JOIN categories c ON i.category_id = c.category_id
LEFT JOIN rooms r ON p.room_id = r.room_id
WHERE p.warranty_end BETWEEN NOW() AND NOW() + INTERVAL '30 days'
ORDER BY p.warranty_end ASC;

-- name: GetProductsWarrantyExpired :many
SELECT
    p.product_id,
    p.serial_number,
    p.warranty_end,
    i.item_name,
    c.category_name,
    r.room_name
FROM products p
JOIN items i ON p.item_id = i.item_id
JOIN categories c ON i.category_id = c.category_id
LEFT JOIN rooms r ON p.room_id = r.room_id
WHERE p.warranty_end < NOW()
ORDER BY p.warranty_end DESC
LIMIT $1 OFFSET $2;

-- ===================== RECENT ACTIVITIES =====================

-- name: GetRecentAuditLogs :many
SELECT
    a.id,
    a.username,
    a.action,
    a.table_name,
    a.record_id,
    a.path,
    a.status_code,
    a.created_at
FROM audit_logs a
ORDER BY a.created_at DESC
LIMIT $1 OFFSET $2;

-- ===================== ROOM UTILIZATION =====================

-- name: GetRoomUtilization :many
SELECT
    r.room_id,
    r.room_name,
    f.floor_name,
    b.building_name,
    COUNT(p.product_id)::int AS total_products
FROM rooms r
JOIN floors f ON r.floor_id = f.floor_id
JOIN buildings b ON f.building_id = b.building_id
LEFT JOIN products p ON r.room_id = p.room_id
GROUP BY r.room_id, r.room_name, f.floor_name, b.building_name
ORDER BY total_products DESC
LIMIT $1 OFFSET $2;

-- ===================== MONTHLY PRODUCT ADDITIONS =====================

-- name: GetMonthlyProductAdditions :many
SELECT
    DATE_TRUNC('month', created_at)::date AS month,
    COUNT(*)::int AS total_added
FROM products
WHERE created_at >= NOW() - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', created_at)
ORDER BY month DESC;

-- ===================== SNAPSHOTS =====================

-- name: SaveAnalyticsSnapshot :one
INSERT INTO analytics_snapshots (
    snapshot_date, total_buildings, total_floors, total_rooms,
    total_categories, total_items, total_products, total_users,
    products_active, products_maintenance, products_damaged,
    products_disposed, products_warranty_expiring
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13)
ON CONFLICT (snapshot_date) DO UPDATE SET
    total_buildings = EXCLUDED.total_buildings,
    total_floors = EXCLUDED.total_floors,
    total_rooms = EXCLUDED.total_rooms,
    total_categories = EXCLUDED.total_categories,
    total_items = EXCLUDED.total_items,
    total_products = EXCLUDED.total_products,
    total_users = EXCLUDED.total_users,
    products_active = EXCLUDED.products_active,
    products_maintenance = EXCLUDED.products_maintenance,
    products_damaged = EXCLUDED.products_damaged,
    products_disposed = EXCLUDED.products_disposed,
    products_warranty_expiring = EXCLUDED.products_warranty_expiring
RETURNING *;

-- name: GetAnalyticsSnapshots :many
SELECT * FROM analytics_snapshots
ORDER BY snapshot_date DESC
LIMIT $1;
