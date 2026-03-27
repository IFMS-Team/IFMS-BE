package redis

import (
	"context"
	"fmt"
	"log"
	"os"
	"strconv"
	"sync"
	"time"

	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"
)

var (
	client *redis.Client
	once   sync.Once
)

func LoadConfig() (string, string, string, int) {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using default values")
	}

	host := getEnv("REDIS_HOST", "localhost")
	port := getEnv("REDIS_PORT", "6379")
	password := getEnv("REDIS_PASSWORD", "")
	db, _ := strconv.Atoi(getEnv("REDIS_DB", "0"))

	return host, port, password, db
}

func getEnv(key, fallback string) string {
	if val := os.Getenv(key); val != "" {
		return val
	}
	return fallback
}

func Connect() *redis.Client {
	once.Do(func() {
		host, port, password, db := LoadConfig()

		client = redis.NewClient(&redis.Options{
			Addr:     fmt.Sprintf("%s:%s", host, port),
			Password: password,
			DB:       db,
		})

		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()

		if err := client.Ping(ctx).Err(); err != nil {
			log.Printf("Warning: Redis not available: %v", err)
			client = nil
			return
		}

		log.Println("Connected to Redis successfully")
	})

	return client
}

func GetClient() *redis.Client {
	return client
}

func IsConnected() bool {
	return client != nil
}

func Close() error {
	if client != nil {
		return client.Close()
	}
	return nil
}
