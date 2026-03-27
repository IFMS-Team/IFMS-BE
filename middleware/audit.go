package middleware

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"net/http"
	"strings"
	"time"

	"IFMS-be/database"
	db "IFMS-be/sql/generated"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgtype"
	"go.uber.org/zap"
)

type auditContextKey string

const AuditDataKey auditContextKey = "audit_data"

type AuditData struct {
	UserID    *uuid.UUID
	Username  string
	Action    string
	TableName string
	RecordID  string
	OldData   interface{}
	NewData   interface{}
}

func SetAuditData(r *http.Request, data *AuditData) *http.Request {
	ctx := context.WithValue(r.Context(), AuditDataKey, data)
	return r.WithContext(ctx)
}

func GetAuditData(r *http.Request) *AuditData {
	data, _ := r.Context().Value(AuditDataKey).(*AuditData)
	return data
}

type responseRecorder struct {
	http.ResponseWriter
	statusCode int
	body       *bytes.Buffer
}

func (r *responseRecorder) WriteHeader(code int) {
	r.statusCode = code
	r.ResponseWriter.WriteHeader(code)
}

func (r *responseRecorder) Write(b []byte) (int, error) {
	r.body.Write(b)
	return r.ResponseWriter.Write(b)
}

func methodToAction(method string) string {
	switch method {
	case http.MethodPost:
		return "CREATE"
	case http.MethodPut, http.MethodPatch:
		return "UPDATE"
	case http.MethodDelete:
		return "DELETE"
	default:
		return method
	}
}

func AuditMiddleware(dbConn *database.DbPostgres, logger *zap.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			if r.Method == http.MethodGet || r.Method == http.MethodOptions {
				next.ServeHTTP(w, r)
				return
			}

			start := time.Now()

			var requestBody []byte
			if r.Body != nil {
				requestBody, _ = io.ReadAll(r.Body)
				r.Body = io.NopCloser(bytes.NewBuffer(requestBody))
			}

			recorder := &responseRecorder{
				ResponseWriter: w,
				statusCode:     http.StatusOK,
				body:           &bytes.Buffer{},
			}

			next.ServeHTTP(recorder, r)

			latency := time.Since(start).Milliseconds()

			go func() {
				auditData := GetAuditData(r)

				action := methodToAction(r.Method)
				tableName := extractTableName(r.URL.Path)
				recordID := ""
				username := "anonymous"
				var userID pgtype.UUID
				var oldDataJSON, newDataJSON, reqJSON, resJSON []byte

				if auditData != nil {
					if auditData.Action != "" {
						action = auditData.Action
					}
					if auditData.TableName != "" {
						tableName = auditData.TableName
					}
					if auditData.RecordID != "" {
						recordID = auditData.RecordID
					}
					if auditData.Username != "" {
						username = auditData.Username
					}
					if auditData.UserID != nil {
						userID = pgtype.UUID{Bytes: *auditData.UserID, Valid: true}
					}
					oldDataJSON, _ = json.Marshal(auditData.OldData)
					newDataJSON, _ = json.Marshal(auditData.NewData)
				}

				if oldDataJSON == nil {
					oldDataJSON = []byte("{}")
				}
				if newDataJSON == nil {
					newDataJSON = []byte("{}")
				}
				reqJSON, _ = json.Marshal(map[string]interface{}{
					"method": r.Method,
					"path":   r.URL.Path,
					"query":  r.URL.RawQuery,
					"body":   json.RawMessage(requestBody),
				})
				resJSON = recorder.body.Bytes()

				ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
				defer cancel()

				_, err := dbConn.Q.CreateAuditLog(ctx, db.CreateAuditLogParams{
					UserID:     userID,
					Username:   username,
					Path:       r.URL.Path,
					Action:     action,
					TableName:  tableName,
					RecordID:   recordID,
					OldData:    oldDataJSON,
					NewData:    newDataJSON,
					Request:    reqJSON,
					Response:   resJSON,
					StatusCode: int32(recorder.statusCode),
					LatencyMs:  latency,
					IpAddress:  getClientIP(r),
					UserAgent:  r.UserAgent(),
				})

				if err != nil {
					logger.Error("Failed to save audit log", zap.Error(err))
				}
			}()
		})
	}
}

func extractTableName(path string) string {
	parts := strings.Split(strings.Trim(path, "/"), "/")
	for i, part := range parts {
		if part == "api" && i+1 < len(parts) {
			return parts[i+1]
		}
	}
	if len(parts) > 0 {
		return parts[len(parts)-1]
	}
	return "unknown"
}

func getClientIP(r *http.Request) string {
	if ip := r.Header.Get("X-Forwarded-For"); ip != "" {
		return strings.Split(ip, ",")[0]
	}
	if ip := r.Header.Get("X-Real-IP"); ip != "" {
		return ip
	}
	return strings.Split(r.RemoteAddr, ":")[0]
}
