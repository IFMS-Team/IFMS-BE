-- name: GetPermissionByID :one
SELECT * FROM permissions WHERE permission_id = $1;

-- name: ListPermissions :many
SELECT * FROM permissions ORDER BY created_at;

-- name: CreatePermission :one
INSERT INTO permissions (permission_name, description)
VALUES ($1, $2)
RETURNING *;

-- name: DeletePermission :exec
DELETE FROM permissions WHERE permission_id = $1;

-- name: GetPermissionsByRoleID :many
SELECT p.* FROM permissions p
JOIN role_permissions rp ON p.permission_id = rp.permission_id
WHERE rp.role_id = $1;

-- name: AddPermissionToRole :exec
INSERT INTO role_permissions (role_id, permission_id)
VALUES ($1, $2)
ON CONFLICT DO NOTHING;

-- name: RemovePermissionFromRole :exec
DELETE FROM role_permissions
WHERE role_id = $1 AND permission_id = $2;
