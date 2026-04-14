-- name: InsertUserTrackingHistory :exec
INSERT INTO user_tracking_history (user_id, nonce, action, entity_type, entity_id, ip_address, description)
VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: GetUserTrackingHistory :many
SELECT * FROM user_tracking_history
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;
