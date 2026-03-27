-- name: CreateAuditLog :one
INSERT INTO audit_logs (
    user_id, username, path, action, table_name, record_id,
    old_data, new_data, request, response,
    status_code, latency_ms, ip_address, user_agent
) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14)
RETURNING *;

-- name: GetAuditLogsByUserID :many
SELECT * FROM audit_logs
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: GetAuditLogsByTable :many
SELECT * FROM audit_logs
WHERE table_name = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

-- name: GetAuditLogsByRecordID :many
SELECT * FROM audit_logs
WHERE record_id = $1
ORDER BY created_at DESC;

-- name: GetAuditLogsByAction :many
SELECT * FROM audit_logs
WHERE action = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;

