package database

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strconv"
	"time"

	db "IFMS-be/sql/generated"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/joho/godotenv"
	"go.uber.org/zap"
)

type DbPostgres struct {
	Pool   *pgxpool.Pool
	Q      *db.Queries
	logger *zap.Logger
}

func NewDbPostgres(logger *zap.Logger) *DbPostgres {
	const (
		defaultMaxConns          = 10
		defaultMinConns          = 0
		defaultMaxConnLifetime   = time.Hour * 1
		defaultMaxConnIdleTime   = time.Minute * 30
		defaultHealthCheckPeriod = time.Minute
		defaultConnectTimeout    = time.Second * 5
	)

	_ = godotenv.Load()

	dbURL := os.Getenv("DATABASE_URL")
	dbConfig, err := pgxpool.ParseConfig(dbURL)
	if err != nil {
		logger.Fatal("Failed to parse database config", zap.Error(err))
	}

	maxConns := int32(defaultMaxConns)
	if v := os.Getenv("DB_MAX_CONNS"); v != "" {
		if n, err := strconv.Atoi(v); err == nil && n > 0 {
			maxConns = int32(n)
		}
	}

	dbConfig.MaxConns = maxConns
	dbConfig.MinConns = defaultMinConns
	dbConfig.MaxConnLifetime = defaultMaxConnLifetime
	dbConfig.MaxConnIdleTime = defaultMaxConnIdleTime
	dbConfig.HealthCheckPeriod = defaultHealthCheckPeriod
	dbConfig.ConnConfig.ConnectTimeout = defaultConnectTimeout

	dbConfig.AfterConnect = func(ctx context.Context, conn *pgx.Conn) error {
		_, err := conn.Exec(ctx, "SET statement_timeout = '30s'")
		return err
	}

	dbPool, err := pgxpool.NewWithConfig(context.Background(), dbConfig)
	if err != nil {
		logger.Fatal("Unable to connect to database", zap.Error(err))
	}

	if err := dbPool.Ping(context.Background()); err != nil {
		logger.Fatal("Unable to ping database", zap.Error(err))
	}

	logger.Info("Connected to PostgreSQL")

	return &DbPostgres{
		Pool:   dbPool,
		Q:      db.New(dbPool),
		logger: logger,
	}
}

func (s *DbPostgres) Close() {
	if s.Pool != nil {
		s.Pool.Close()
	}
}

func (s *DbPostgres) ExecTx(ctx context.Context, fn func(*db.Queries) error) error {
	tx, err := s.Pool.Begin(ctx)
	if err != nil {
		return err
	}

	q := s.Q.WithTx(tx)

	err = fn(q)
	if err != nil {
		_ = tx.Rollback(ctx)
		return err
	}
	return tx.Commit(ctx)
}

func (s *DbPostgres) AutoMigrate(schemaDir string) error {
	files, err := filepath.Glob(filepath.Join(schemaDir, "*.sql"))
	if err != nil {
		return fmt.Errorf("failed to read schema files: %w", err)
	}

	sort.Strings(files)

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	for _, file := range files {
		content, err := os.ReadFile(file)
		if err != nil {
			return fmt.Errorf("failed to read %s: %w", file, err)
		}

		if _, err := s.Pool.Exec(ctx, string(content)); err != nil {
			return fmt.Errorf("failed to execute %s: %w", file, err)
		}

		s.logger.Info("Migrated", zap.String("file", filepath.Base(file)))
	}

	return nil
}
