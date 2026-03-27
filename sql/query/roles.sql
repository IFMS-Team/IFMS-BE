-- name: GetRoleByID :one
SELECT * FROM roles WHERE role_id = $1;

-- name: GetRoleByName :one
SELECT * FROM roles WHERE role_name = $1;

-- name: ListRoles :many
SELECT * FROM roles ORDER BY created_at;

-- name: CreateRole :one
INSERT INTO roles (role_name, description)
VALUES ($1, $2)
RETURNING *;

-- name: DeleteRole :exec
DELETE FROM roles WHERE role_id = $1;
