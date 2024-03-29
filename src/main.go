package main

import (
	"fmt"
	"healthcheck/db"
	"healthcheck/utils"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	hc "healthcheck/healthcheck"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
)

func main() {
	err := godotenv.Load(".env")
	if err != nil {
		log.Fatal(err)
	}

	postgresHost := os.Getenv("POSTGRES_HOST")
	postgresPort := os.Getenv("POSTGRES_PORT")
	postgresDb := os.Getenv("POSTGRES_DB")
	postgresUser := os.Getenv("POSTGRES_USER")
	postgresPassword := os.Getenv("POSTGRES_PASSWORD")
	port := os.Getenv("SERVICE_PORT")

	options := fmt.Sprintf("host=%s port=%s dbname=%s user=%s password=%s sslmode=disable connect_timeout=1",
		postgresHost, postgresPort, postgresDb, postgresUser, postgresPassword)

	dbManager := db.NewDatabaseManager("postgres", options)
	service := hc.Service{Manager: &dbManager}

	dbManager.CreateStatusTable()

	go func() {
		secondsStr := os.Getenv("UPDATE_STATUS_TIME")
		seconds, _ := strconv.ParseUint(secondsStr, 10, 64)
		addr := utils.GetInternalIP()

		for _ = range time.Tick(time.Second * time.Duration(seconds)) {
			log.Println("Status updated")

			dbManager.UpdateStatus(addr)
		}
	}()

	http.HandleFunc("/healthcheck", service.HealthHandler)
	log.Fatal(http.ListenAndServe("0.0.0.0:" + port, nil))
}
