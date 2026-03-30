-- ===================== REPORT CHECKER =====================

-- name: CreateReportChecker :one
INSERT INTO report_checker (user_id, room_id, status, description, url_image)
VALUES ($1, $2, $3, $4, $5)
RETURNING *;

-- name: GetReportCheckerByID :one
SELECT rc.*, u.username, r.room_name
FROM report_checker rc
LEFT JOIN users u ON rc.user_id = u.user_id
LEFT JOIN rooms r ON rc.room_id = r.room_id
WHERE rc.report_checker_id = $1;

-- name: ListReportCheckers :many
SELECT rc.*, u.username, r.room_name
FROM report_checker rc
LEFT JOIN users u ON rc.user_id = u.user_id
LEFT JOIN rooms r ON rc.room_id = r.room_id
ORDER BY rc.created_at DESC
LIMIT $1 OFFSET $2;

-- name: ListOpenReportCheckers :many
SELECT rc.*, u.username, r.room_name
FROM report_checker rc
LEFT JOIN users u ON rc.user_id = u.user_id
LEFT JOIN rooms r ON rc.room_id = r.room_id
WHERE rc.is_open = TRUE
ORDER BY rc.created_at DESC
LIMIT $1 OFFSET $2;

-- name: CloseReportChecker :one
UPDATE report_checker
SET is_open = FALSE, confirmed_by = $2, updated_at = NOW()
WHERE report_checker_id = $1
RETURNING *;

-- name: UpdateReportCheckerStatus :one
UPDATE report_checker
SET status = $2, updated_at = NOW()
WHERE report_checker_id = $1
RETURNING *;

-- name: CountOpenReportCheckers :one
SELECT COUNT(*) FROM report_checker WHERE is_open = TRUE;

-- name: ListReportCheckersByRoomID :many
SELECT rc.*, u.username
FROM report_checker rc
LEFT JOIN users u ON rc.user_id = u.user_id
WHERE rc.room_id = $1
ORDER BY rc.created_at DESC
LIMIT $2 OFFSET $3;

-- ===================== REPORT GUEST =====================

-- name: CreateReportGuest :one
INSERT INTO report_guest (name_sender, phone_sender, email_sender, room_id, item_id, status, description, url_image)
VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
RETURNING *;

-- name: GetReportGuestByID :one
SELECT rg.*, r.room_name
FROM report_guest rg
LEFT JOIN rooms r ON rg.room_id = r.room_id
WHERE rg.report_guest_id = $1;

-- name: ListReportGuests :many
SELECT rg.*, r.room_name
FROM report_guest rg
LEFT JOIN rooms r ON rg.room_id = r.room_id
ORDER BY rg.created_at DESC
LIMIT $1 OFFSET $2;

-- name: ListOpenReportGuests :many
SELECT rg.*, r.room_name
FROM report_guest rg
LEFT JOIN rooms r ON rg.room_id = r.room_id
WHERE rg.is_open = TRUE
ORDER BY rg.created_at DESC
LIMIT $1 OFFSET $2;

-- name: CloseReportGuest :one
UPDATE report_guest
SET is_open = FALSE, confirmed_by = $2, updated_at = NOW()
WHERE report_guest_id = $1
RETURNING *;

-- name: UpdateReportGuestStatus :one
UPDATE report_guest
SET status = $2, updated_at = NOW()
WHERE report_guest_id = $1
RETURNING *;

-- name: CountOpenReportGuests :one
SELECT COUNT(*) FROM report_guest WHERE is_open = TRUE;

-- name: ListReportGuestsByRoomID :many
SELECT rg.*
FROM report_guest rg
WHERE rg.room_id = $1
ORDER BY rg.created_at DESC
LIMIT $2 OFFSET $3;
