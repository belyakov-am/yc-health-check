package db

import (
	"github.com/jmoiron/sqlx"
	"log"
	"time"
)

type Status struct {
	Ip string `db:"ip"`
	Ts time.Time `db:"ts"`
}

type DatabaseManager struct {
	Db *sqlx.DB
}

func NewDatabaseManager(database string, options string) DatabaseManager {
	db, err := sqlx.Connect(database, options)
	if err != nil {
		log.Print(err)
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
	_, err := m.Db.Exec(upsertStatus, addr, ts)
	if err != nil {
		log.Printf("Update status failure: %e\n", err)
	}
}

func (m *DatabaseManager) GetStatuses() (statuses []Status, err error) {
	err = m.Db.Select(&statuses, selectStatuses)
	if err != nil {
		return nil, err
	}

	return statuses, nil
}
