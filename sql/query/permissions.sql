-- name: GetPermissionByID :one
SELECT * FROM permissions WHERE permission_id = $1;

-- name: ListPermissions :many
SELECT * FROM permissions ORDER BY created_at;

-- name: CreatePermission :one
INSERT INTO permissions (permission_name, description, code)
VALUES ($1, $2, $3)
RETURNING *;

-- name: UpdatePermission :one
UPDATE permissions
SET permission_name = $2, description = $3, code = $4, updated_at = NOW()
WHERE permission_id = $1
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

-- name: CheckRoleHasPermission :one
SELECT COUNT(*) > 0 AS has_permission
FROM role_permissions rp
JOIN permissions p ON rp.permission_id = p.permission_id
WHERE rp.role_id = $1 AND p.permission_name = $2;
