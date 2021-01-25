package utils

import (
	"io/ioutil"
	"log"
	"net/http"
)

func GetInternalIP() (addr string) {
	// internal YC url
	resp, err := http.Get("http://169.254.169.254/latest/meta-data/local-ipv4")
	if err != nil {
		log.Print("Error getting internal IP from YC")
		return "111.111.111.111"
	}

	defer resp.Body.Close()

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Print("Error reading internal IP body")
		log.Fatal(err)
	}

	return string(body)
}
