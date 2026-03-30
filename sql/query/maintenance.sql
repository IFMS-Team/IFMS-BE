-- ===================== MAINTENANCE TICKETS =====================

-- name: CreateMaintenanceTicket :one
INSERT INTO maintenance_tickets (ticket_type, title, description, priority, scheduled_date, building_id, created_by, assigned_to)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING *;

-- name: GetMaintenanceTicketByID :one
SELECT mt.*, b.building_name,
       creator.username AS creator_name,
       assignee.username AS assignee_name
FROM maintenance_tickets mt
LEFT JOIN buildings b ON mt.building_id = b.building_id
LEFT JOIN users creator ON mt.created_by = creator.user_id
LEFT JOIN users assignee ON mt.assigned_to = assignee.user_id
WHERE mt.ticket_id = $1;

-- name: ListMaintenanceTickets :many
SELECT mt.*, b.building_name,
       creator.username AS creator_name,
       assignee.username AS assignee_name
FROM maintenance_tickets mt
LEFT JOIN buildings b ON mt.building_id = b.building_id
LEFT JOIN users creator ON mt.created_by = creator.user_id
LEFT JOIN users assignee ON mt.assigned_to = assignee.user_id
ORDER BY mt.created_at DESC
LIMIT $1 OFFSET $2;

-- name: ListMaintenanceTicketsByType :many
SELECT mt.*, b.building_name,
       creator.username AS creator_name,
       assignee.username AS assignee_name
FROM maintenance_tickets mt
LEFT JOIN buildings b ON mt.building_id = b.building_id
LEFT JOIN users creator ON mt.created_by = creator.user_id
LEFT JOIN users assignee ON mt.assigned_to = assignee.user_id
WHERE mt.ticket_type = $1
ORDER BY mt.created_at DESC
LIMIT $2 OFFSET $3;

-- name: ListMaintenanceTicketsByStatus :many
SELECT mt.*, b.building_name,
       creator.username AS creator_name,
       assignee.username AS assignee_name
FROM maintenance_tickets mt
LEFT JOIN buildings b ON mt.building_id = b.building_id
LEFT JOIN users creator ON mt.created_by = creator.user_id
LEFT JOIN users assignee ON mt.assigned_to = assignee.user_id
WHERE mt.status = $1
ORDER BY mt.created_at DESC
LIMIT $2 OFFSET $3;

-- name: ListMaintenanceTicketsByAssignee :many
SELECT mt.*, b.building_name
FROM maintenance_tickets mt
LEFT JOIN buildings b ON mt.building_id = b.building_id
WHERE mt.assigned_to = $1
ORDER BY mt.created_at DESC
LIMIT $2 OFFSET $3;

-- name: UpdateMaintenanceTicketStatus :one
UPDATE maintenance_tickets
SET status = $2, updated_at = NOW()
WHERE ticket_id = $1
RETURNING *;

-- name: CompleteMaintenanceTicket :one
UPDATE maintenance_tickets
SET status = 'completed', completed_date = NOW(), updated_at = NOW()
WHERE ticket_id = $1
RETURNING *;

-- name: AssignMaintenanceTicket :one
UPDATE maintenance_tickets
SET assigned_to = $2, updated_at = NOW()
WHERE ticket_id = $1
RETURNING *;

-- name: CountMaintenanceTicketsByStatus :one
SELECT COUNT(*) FROM maintenance_tickets WHERE status = $1;

-- name: DeleteMaintenanceTicket :exec
DELETE FROM maintenance_tickets WHERE ticket_id = $1;

-- ===================== MAINTENANCE TICKET SCOPES =====================

-- name: CreateMaintenanceTicketScope :one
INSERT INTO maintenance_ticket_scopes (ticket_id, floor_id, room_id)
VALUES ($1, $2, $3)
RETURNING *;

-- name: GetScopesByTicketID :many
SELECT mts.*, f.floor_name, r.room_name
FROM maintenance_ticket_scopes mts
LEFT JOIN floors f ON mts.floor_id = f.floor_id
LEFT JOIN rooms r ON mts.room_id = r.room_id
WHERE mts.ticket_id = $1;

-- name: DeleteScopesByTicketID :exec
DELETE FROM maintenance_ticket_scopes WHERE ticket_id = $1;

-- ===================== MAINTENANCE TICKET ITEMS =====================

-- name: CreateMaintenanceTicketItem :one
INSERT INTO maintenance_ticket_items (ticket_id, product_id, room_id)
VALUES ($1, $2, $3)
RETURNING *;

-- name: GetTicketItemByID :one
SELECT mti.*, p.serial_number, i.item_name, r.room_name,
       checker.username AS checker_name
FROM maintenance_ticket_items mti
LEFT JOIN products p ON mti.product_id = p.product_id
LEFT JOIN items i ON p.item_id = i.item_id
LEFT JOIN rooms r ON mti.room_id = r.room_id
LEFT JOIN users checker ON mti.checked_by = checker.user_id
WHERE mti.ticket_item_id = $1;

-- name: ListTicketItemsByTicketID :many
SELECT mti.*, p.serial_number, i.item_name, r.room_name,
       checker.username AS checker_name
FROM maintenance_ticket_items mti
LEFT JOIN products p ON mti.product_id = p.product_id
LEFT JOIN items i ON p.item_id = i.item_id
LEFT JOIN rooms r ON mti.room_id = r.room_id
LEFT JOIN users checker ON mti.checked_by = checker.user_id
WHERE mti.ticket_id = $1
ORDER BY r.room_name, i.item_name;

-- name: ListTicketItemsByRoomID :many
SELECT mti.*, p.serial_number, i.item_name,
       checker.username AS checker_name
FROM maintenance_ticket_items mti
LEFT JOIN products p ON mti.product_id = p.product_id
LEFT JOIN items i ON p.item_id = i.item_id
LEFT JOIN users checker ON mti.checked_by = checker.user_id
WHERE mti.ticket_id = $1 AND mti.room_id = $2
ORDER BY i.item_name;

-- name: UpdateTicketItemCheckStatus :one
UPDATE maintenance_ticket_items
SET check_status = $2, note = $3, checked_by = $4, checked_at = NOW(), updated_at = NOW()
WHERE ticket_item_id = $1
RETURNING *;

-- name: CountTicketItemsByStatus :one
SELECT COUNT(*) FROM maintenance_ticket_items
WHERE ticket_id = $1 AND check_status = $2;

-- name: CountPendingTicketItems :one
SELECT COUNT(*) FROM maintenance_ticket_items
WHERE ticket_id = $1 AND check_status = 'pending';

-- name: GetProductsByRoomIDs :many
SELECT p.product_id, p.room_id, p.serial_number, i.item_name
FROM products p
LEFT JOIN items i ON p.item_id = i.item_id
WHERE p.room_id = ANY($1::uuid[])
ORDER BY p.room_id, i.item_name;

-- name: GetProductsByBuildingID :many
SELECT p.product_id, p.room_id, p.serial_number, i.item_name, r.room_name, f.floor_name
FROM products p
LEFT JOIN items i ON p.item_id = i.item_id
LEFT JOIN rooms r ON p.room_id = r.room_id
LEFT JOIN floors f ON r.floor_id = f.floor_id
WHERE f.building_id = $1
ORDER BY f.floor_name, r.room_name, i.item_name;
