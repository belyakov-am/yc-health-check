package healthcheck

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"strconv"
	"time"

	"healthcheck/db"
)

// TODO: make json method for responses

type StatusResp struct {
	Ip string `json:"ip"`
	Status string `json:"status"`
}

type HealthResp struct {
	Ip string `json:"ip"`
	Services []StatusResp `json:"services"`
}

type ErrorResp struct {
	Error string `json:"error"`
}

type Service struct {
	Manager *db.DatabaseManager
}

func GetInternalIP() (addr string) {
	resp, err := http.Get("http://169.254.169.254/latest/meta-data/local-ipv4")
	if err != nil {
		log.Print("Error getting internal IP")
		log.Fatal(err)
	}

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Print("Error reading internal IP body")
		log.Fatal(err)
	}

	return string(body)
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
		Ip:       GetInternalIP(),
		Services: statusesResp,
	}
	js, _ := json.Marshal(resp)
	w.Header().Set("Content-Type", "application/json")
	_, _ = w.Write(js)
}
