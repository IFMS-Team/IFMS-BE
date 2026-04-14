-- name: InsertUserSession :exec
INSERT INTO user_sessions (user_id, token, device_info, ip_address, is_deleted, expired_at)
VALUES ($1, $2, $3, $4, $5, $6);

-- name: DeleteUserSession :exec
UPDATE user_sessions SET is_deleted = true, updated_at = NOW()
WHERE user_id = $1 AND token = $2;

-- name: DeleteUserSessionsByUserId :exec
UPDATE user_sessions SET is_deleted = true, updated_at = NOW()
WHERE user_id = $1 AND is_deleted = false;

-- name: ValidateUserSession :one
SELECT session_id FROM user_sessions
WHERE token = $1 AND is_deleted = false;

-- name: GetActiveSessionsByUserID :many
SELECT * FROM user_sessions
WHERE user_id = $1 AND is_deleted = false AND expired_at > EXTRACT(EPOCH FROM NOW())::BIGINT
ORDER BY created_at DESC;
