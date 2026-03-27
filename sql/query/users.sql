-- name: GetUserByID :one
SELECT * FROM users WHERE user_id = $1;

-- name: GetUserByEmail :one
SELECT * FROM users WHERE email = $1;

-- name: GetUserByUsername :one
SELECT * FROM users WHERE username = $1;

-- name: ListUsers :many
SELECT * FROM users ORDER BY created_at DESC LIMIT $1 OFFSET $2;

-- name: CreateUser :one
INSERT INTO users (username, email, password, password_hash, phone, address, cccd, role_id)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING *;

-- name: UpdateUser :one
UPDATE users
SET username = $2, email = $3, phone = $4, address = $5, updated_at = NOW()
WHERE user_id = $1
RETURNING *;

-- name: DeleteUser :exec
DELETE FROM users WHERE user_id = $1;

-- name: GetUserWithRole :one
SELECT u.*, r.role_name, r.description as role_description
FROM users u
JOIN roles r ON u.role_id = r.role_id
WHERE u.user_id = $1;
