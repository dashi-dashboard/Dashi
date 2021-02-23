package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
    "net/http"
    // "strconv"

    "github.com/pelletier/go-toml"
    "github.com/rs/cors"
    "github.com/gorilla/mux"
)

// type Config struct {
// 	Apps []struct {
// 		Name      string `toml:"name"`
// 		URL       string `toml:"url"`
// 		Tag       string `toml:"tag"`
//      EnableAPI bool   `toml:"enable_api"`
// 		Icon      string `toml:"icon"`        
//     } `toml:"Apps"`
// 	Users []struct {
// 		Name string `toml:"name"`
// 		Role string `toml:"role"`
// 	} `toml:"Users"`    
// }

type Config struct {
    Apps map[string]App `toml:"Apps"`
}

type App struct {
  URL       string `toml:"url"`
  Tag       string `toml:"tag"`
  EnableAPI bool   `toml:"enable_api"`
  Icon      string `toml:"icon"`
}

var config Config

func readConf(filename string) {
    tomlFile, err := ioutil.ReadFile(filename)
    if err != nil {
        fmt.Println("Error ", err.Error())
    } else {
        toml.Unmarshal(tomlFile, &config)
    }

    fmt.Println(config)
}

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
    readConf("../config.toml")
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