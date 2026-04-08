-- ===================== USER CRUD =====================

-- name: GetUserByID :one
SELECT * FROM users WHERE user_id = $1;

-- name: GetUserByEmail :one
SELECT * FROM users WHERE email = $1;

-- name: GetUserByUsername :one
SELECT * FROM users WHERE username = $1;

-- name: GetUserByCCCD :one
SELECT * FROM users WHERE cccd = $1;

-- name: GetUserWithRole :one
SELECT u.*, r.role_name, r.description as role_description
FROM users u
JOIN roles r ON u.role_id = r.role_id
WHERE u.user_id = $1;

-- name: ListUsers :many
SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2;

-- name: ListUsersWithRole :many
SELECT u.*, r.role_name
FROM users u
JOIN roles r ON u.role_id = r.role_id
ORDER BY u.created_at DESC
LIMIT $1 OFFSET $2;

-- name: ListUsersByRoleID :many
SELECT * FROM users WHERE role_id = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3;

-- name: ListUsersByStatus :many
SELECT * FROM users WHERE status = $1 ORDER BY created_at DESC LIMIT $2 OFFSET $3;

-- name: SearchUsers :many
SELECT u.*, r.role_name
FROM users u
JOIN roles r ON u.role_id = r.role_id
WHERE u.username ILIKE '%' || $1 || '%'
   OR u.email ILIKE '%' || $1 || '%'
   OR u.phone ILIKE '%' || $1 || '%'
ORDER BY u.created_at DESC
LIMIT $2 OFFSET $3;

-- name: CountUsers :one
SELECT COUNT(*) FROM users;

-- name: CountUsersByStatus :one
SELECT COUNT(*) FROM users WHERE status = $1;

-- name: CreateUser :one
INSERT INTO users (username, email, password, password_hash, full_name, phone, address, cccd, role_id)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
RETURNING *;

-- name: UpdateUser :one
UPDATE users
SET username = $2, email = $3, full_name = $4, phone = $5, address = $6, updated_at = NOW()
WHERE user_id = $1
RETURNING *;

-- name: UpdateUserRole :one
UPDATE users
SET role_id = $2, updated_at = NOW()
WHERE user_id = $1
RETURNING *;

-- name: UpdateUserStatus :one
UPDATE users
SET status = $2, updated_at = NOW()
WHERE user_id = $1
RETURNING *;

-- name: UpdateUserPassword :exec
UPDATE users
SET password = $2, password_hash = $3, updated_at = NOW()
WHERE user_id = $1;

-- name: DeleteUser :exec
DELETE FROM users WHERE user_id = $1;

-- name: SoftDeleteUser :one
UPDATE users
SET status = 0, updated_at = NOW()
WHERE user_id = $1
RETURNING *;

-- ===================== USER SESSIONS =====================

-- name: InsertUserSession :exec
INSERT INTO user_sessions (user_id, token, device_info, ip_address, is_deleted, expired_at)
VALUES ($1, $2, $3, $4, $5, $6);

-- name: DeleteUserSession :exec
UPDATE user_sessions SET is_deleted = true, updated_at = NOW()
WHERE user_id = $1 AND token = $2;

-- name: DeleteUserSessionsByUserId :exec
UPDATE user_sessions SET is_deleted = true, updated_at = NOW()
WHERE user_id = $1 AND is_deleted = false;

-- name: GetActiveSessionsByUserID :many
SELECT * FROM user_sessions
WHERE user_id = $1 AND is_deleted = false AND expired_at > EXTRACT(EPOCH FROM NOW())::BIGINT
ORDER BY created_at DESC;

-- ===================== USER TRACKING =====================

-- name: InsertUserTrackingHistory :exec
INSERT INTO user_tracking_history (user_id, nonce, action, entity_type, entity_id, ip_address, description)
VALUES ($1, $2, $3, $4, $5, $6, $7);

-- name: GetUserTrackingHistory :many
SELECT * FROM user_tracking_history
WHERE user_id = $1
ORDER BY created_at DESC
LIMIT $2 OFFSET $3;
