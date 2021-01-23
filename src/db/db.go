package db

import (
	//"database/sql"

	"github.com/jmoiron/sqlx"
	"log"
	"time"
)

var schema = `
CREATE TABLE IF NOT EXISTS status (
	ip TEXT PRIMARY KEY,
	ts TIMESTAMPTZ 
);
`

var upsertStatus = `
INSERT INTO status (ip, ts)
VALUES ($1, $2)
ON CONFLICT (ip)
DO UPDATE SET ts = $2; 
`

type Status struct {
	Ip string `db:"ip"`
	Ts string `db:"ts"`
}

type DatabaseManager struct {
	Db *sqlx.DB
}

func NewDatabaseManager(database string, options string) DatabaseManager {
	db, err := sqlx.Connect(database, options)
	if err != nil {
		log.Fatal(err)
	}

	return DatabaseManager{
		Db: db,
	}
}

func (m *DatabaseManager) CreateStatusTable() {
	log.Println("Creating status table")

	m.Db.MustExec(schema)
}

func (m *DatabaseManager) UpdateStatus(addr string) {
	ts := time.Now()
	m.Db.MustExec(upsertStatus, addr, ts)
}
