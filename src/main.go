package main

import (
	"fmt"
	"healthcheck/db"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	hc "healthcheck/healthcheck"

	_ "github.com/lib/pq"
)

func main() {
	postgresHost := os.Getenv("POSTGRES_HOST")
	postgresPort := os.Getenv("POSTGRES_PORT")
	postgresDb := os.Getenv("POSTGRES_DB")
	postgresUser := os.Getenv("POSTGRES_USER")
	postgresPassword := os.Getenv("POSTGRES_PASSWORD")

	options := fmt.Sprintf("host=%s port=%s dbname=%s user=%s password=%s sslmode=disable",
		postgresHost, postgresPort, postgresDb, postgresUser, postgresPassword)
	log.Printf("%s\n", options)
	dbManager := db.NewDatabaseManager("postgres", options)

	dbManager.CreateStatusTable()

	go func() {
		secondsStr := os.Getenv("UPDATE_STATUS_TIME")
		seconds, _ := strconv.ParseUint(secondsStr, 10, 64)
		addr := "0.0.0.0"

		for _ = range time.Tick(time.Second * time.Duration(seconds)) {
			log.Println("Status updated")

			dbManager.UpdateStatus(addr)
		}
	}()

	http.HandleFunc("/healthcheck", hc.HealthHandler)
	log.Fatal(http.ListenAndServe("localhost:8000", nil))
}