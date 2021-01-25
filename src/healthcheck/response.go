package healthcheck

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
