package main

import (
	"encoding/json"
	"log"
	"net/http"

	// "strconv"

	"github.com/gorilla/mux"
	"github.com/rs/cors"
)

var config *Config

func GetFullConfig(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	json.NewEncoder(w).Encode(config)
}

func GetApps(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	json.NewEncoder(w).Encode(config.Apps)
}

// func GetSingleApp(w http.ResponseWriter, r *http.Request) {
//     w.Header().Set("Content-Type", "application/json")
//     w.Header().Set("Access-Control-Allow-Origin", "*")
//     id, err := strconv.ParseInt(mux.Vars(r)["id"], 10, 64)
//     if err != nil {
//         fmt.Println("Error ", err.Error())
//     }

//     data := config.Apps[id]
//     json.NewEncoder(w).Encode(data)
// }

func PreFlight(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "DELETE, GET, OPTIONS, POST, PUT")
}

func main() {
	var err error

	config, err = readConfig("../config.toml")
	if err != nil {
		log.Printf("Error reading config file: %s", err)
	}

	// readConf("/config.toml")
	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "HEAD", "POST", "DELETE", "PUT", "OPTIONS"},
	})

	router := mux.NewRouter()
	router.HandleFunc("/api/", GetFullConfig).Methods("GET")
	router.HandleFunc("/api/apps", GetApps).Methods("GET")
	// router.HandleFunc("/api/apps/{id}", GetSingleApp).Methods("GET")
	router.PathPrefix("/").Handler(http.FileServer(http.Dir("./frontend")))

	log.Fatal(http.ListenAndServe(":8443", c.Handler(router)))
}
