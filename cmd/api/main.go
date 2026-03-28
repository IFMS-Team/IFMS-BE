package main

import (
	"net/http"

	"github.com/vippergod12/IFMS-BE/database"
	auditMw "github.com/vippergod12/IFMS-BE/middleware"
	redisclient "github.com/vippergod12/IFMS-BE/redis"

	"go.uber.org/zap"
)

func main() {
	logger, _ := zap.NewProduction()
	defer logger.Sync()

	logger.Info("IFMS Backend Server starting...")

	db := database.NewDbPostgres(logger)
	defer db.Close()

	if err := db.AutoMigrate("sql/schema"); err != nil {
		logger.Fatal("Migration failed", zap.Error(err))
	}

	redisclient.Connect()
	defer redisclient.Close()

	mux := http.NewServeMux()
	mux.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		w.Write([]byte(`{"status":"ok"}`))
	})

	handler := auditMw.CORSMiddleware()(auditMw.AuditMiddleware(db, logger)(mux))

	logger.Info("Server is running on http://localhost:8080")
	if err := http.ListenAndServe(":8080", handler); err != nil {
		logger.Fatal("Server failed", zap.Error(err))
	}
}
