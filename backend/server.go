package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"strings"

	"github.com/gorilla/mux"
	"github.com/rs/cors"
)

var config *Config

type contextKey int

const authenticatedRequestKey contextKey = 0
const authenticatedUserKey contextKey = 1

func getFullConfig(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	user := r.Context().Value(authenticatedUserKey).(*User)

	filteredConfig := config

	filteredConfig.Apps = config.GetPublicAppsList()

	if !r.Context().Value(authenticatedRequestKey).(bool) {
		filteredConfig.Apps = config.GetFilteredAppsList(user)
		return
	}

	json.NewEncoder(w).Encode(filteredConfig)
}

func getApps(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	if !r.Context().Value(authenticatedRequestKey).(bool) {
		json.NewEncoder(w).Encode(config.GetPublicAppsList())
		return
	}

	user := r.Context().Value(authenticatedUserKey).(*User)

	json.NewEncoder(w).Encode(config.GetFilteredAppsList(user))
}

func getDashboardConfig(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	json.NewEncoder(w).Encode(config.Dashboard)
}

func authorizeMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		reqToken := r.Header.Get("Authorization")
		if reqToken == "" {
			log.Println("No authorization header supplied")

			ctx := context.WithValue(r.Context(), authenticatedRequestKey, false)
			next.ServeHTTP(w, r.WithContext(ctx))

			return
		}

		log.Println("Authorization header supplied")
		splitToken := strings.Split(reqToken, "Bearer ")
		reqToken = splitToken[1]

		user, err := config.AuthenticateToken(reqToken, config)
		if err != nil {
			http.Error(w, fmt.Sprintf("Error authenticating token: %s", err), http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), authenticatedRequestKey, true)
		ctx = context.WithValue(ctx, authenticatedUserKey, user)

		log.Println(r.Context())

		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

type AuthenticateResponse struct {
	Success bool
	Message string
	Token   string
}

func authenticate(w http.ResponseWriter, r *http.Request) {
	r.ParseForm()

	var response AuthenticateResponse
	response.Success = true

	username := r.Form.Get("username")
	password := r.Form.Get("password")

	token, err := config.AuthenticateUser(username, password)
	if err != nil {
		response.Success = false
		response.Message = err.Error()
	}

	response.Token = token

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	json.NewEncoder(w).Encode(response)
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
	router.Handle("/api", authorizeMiddleware(http.HandlerFunc(getFullConfig))).Methods("GET")
	router.Handle("/api/apps", authorizeMiddleware(http.HandlerFunc(getApps))).Methods("GET")
	router.Handle("/api/dashboard", authorizeMiddleware(http.HandlerFunc(getDashboardConfig))).Methods("GET")

	router.HandleFunc("/api/authenticate", authenticate).Methods("POST")

	router.PathPrefix("/").Handler(http.FileServer(http.Dir("./frontend")))

	log.Fatal(http.ListenAndServe(":8443", c.Handler(router)))
}
