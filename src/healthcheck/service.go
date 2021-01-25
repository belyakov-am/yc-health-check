package healthcheck

import (
	"encoding/json"
	"healthcheck/utils"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	"healthcheck/db"
)

type Service struct {
	Manager *db.DatabaseManager
}

func (s *Service) HealthHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Received healthcheck request")

	statuses, err := s.Manager.GetStatuses()
	if err != nil {
		log.Printf("Database is unavailable: %e", err)

		resp := ErrorResp{"Database is unavailable"}
		js, _ := json.Marshal(resp)
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write(js)
		return
	}

	var statusesResp []StatusResp
	now := time.Now()
	updateStatusTimeStr := os.Getenv("UPDATE_STATUS_TIME")
	updateStatusTime, _ := strconv.ParseFloat(updateStatusTimeStr, 10)

	for _, status := range statuses {
		statusResp := StatusResp{Ip: status.Ip}
		diff := now.Sub(status.Ts)

		if diff.Seconds() > updateStatusTime {
			statusResp.Status = "UNAVAILABLE"
		} else {
			statusResp.Status = "AVAILABLE"
		}

		statusesResp = append(statusesResp, statusResp)
	}

	resp := HealthResp{
		Ip:       utils.GetInternalIP(),
		Services: statusesResp,
	}
	js, _ := json.Marshal(resp)
	w.Header().Set("Content-Type", "application/json")
	_, _ = w.Write(js)
}
