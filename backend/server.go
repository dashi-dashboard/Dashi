package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"

	"server/lib/config"

	"github.com/google/uuid"
	"github.com/gorilla/mux"
	"github.com/rs/cors"
	log "github.com/sirupsen/logrus"
	"golang.org/x/crypto/bcrypt"
)

var serverConfig *config.Config

type contextKey int

const authenticatedRequestKey contextKey = 0
const authenticatedUserKey contextKey = 1
const loggerKey contextKey = 2

func getApps(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	if !r.Context().Value(authenticatedRequestKey).(bool) {
		json.NewEncoder(w).Encode(serverConfig.GetPublicAppsList())
		return
	}

	user := r.Context().Value(authenticatedUserKey).(*config.User)

	json.NewEncoder(w).Encode(serverConfig.GetFilteredAppsList(user))
}

func getDashboardConfig(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")
	json.NewEncoder(w).Encode(serverConfig.Dashboard)
}

func authorizeMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		logger := getLogger(r.Context())

		reqToken := r.Header.Get("Authorization")
		if reqToken == "" {
			logger.Info("No authorization header supplied")

			ctx := context.WithValue(r.Context(), authenticatedRequestKey, false)
			next.ServeHTTP(w, r.WithContext(ctx))

			return
		}

		logger.Info("Authorization header supplied")
		splitToken := strings.Split(reqToken, "Bearer ")
		reqToken = splitToken[1]

		user, err := serverConfig.AuthenticateToken(reqToken)
		if err != nil {
			logger.Warn("Error authenticating token: %s", err)
			http.Error(w, fmt.Sprintf("Error authenticating token: %s", err), http.StatusUnauthorized)
			return
		}

		ctx := context.WithValue(r.Context(), authenticatedRequestKey, true)
		ctx = context.WithValue(ctx, authenticatedUserKey, user)

		log.Println(r.Context())

		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

type authenticateResponse struct {
	Success bool
	Message string
	Token   string
}

func authenticate(w http.ResponseWriter, r *http.Request) {
	var response authenticateResponse
	response.Success = true

	r.ParseForm()
	username := r.Form.Get("username")
	password := r.Form.Get("password")

	token, err := serverConfig.AuthenticateUser(username, password)
	if err != nil {
		response.Success = false
		response.Message = err.Error()
	}

	response.Token = token

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	json.NewEncoder(w).Encode(response)
}

type generatePasswordResponse struct {
	Success bool
	Message string
	Hash    string
}

func generatePassword(w http.ResponseWriter, r *http.Request) {
	var response generatePasswordResponse
	response.Success = true

	r.ParseForm()
	password := r.Form.Get("password")

	hash, err := bcrypt.GenerateFromPassword([]byte(password), serverConfig.PasswordHashCost)
	if err != nil {
		response.Success = false
		response.Message = err.Error()
	}

	response.Hash = string(hash)

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	json.NewEncoder(w).Encode(response)
}

type Middleware func(http.Handler) http.Handler

func getLogger(ctx context.Context) *log.Entry {

	reqID := ctx.Value(loggerKey)

	if ret, ok := reqID.(*log.Entry); ok {
		ret.Info("Got logger")
		return ret
	}

	log.Info("No logger found")
	return nil
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		reqID := uuid.New()

		requestLogger := log.WithFields(log.Fields{
			"requestID": reqID,
		})

		requestLogger.Warn("Initialized Request Logging")

		ctx := context.WithValue(r.Context(), loggerKey, requestLogger)

		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

func multipleMiddleware(h http.Handler, m ...Middleware) http.Handler {
	if len(m) < 1 {
		return h
	}

	wrapped := h

	// loop in reverse to preserve middleware order
	for i := len(m) - 1; i >= 0; i-- {
		wrapped = m[i](wrapped)
	}

	// for _, middleware := range m {
	// 	wrapped = middleware(wrapped)
	// }

	return wrapped
}

func main() {
	var err error

	serverConfig, err = config.FromFile("../config.toml")
	if err != nil {
		log.Printf("Error reading config file: %s", err)
	}

	c := cors.New(cors.Options{
		AllowedOrigins: []string{"*"},
		AllowedMethods: []string{"GET", "HEAD", "POST", "DELETE", "PUT", "OPTIONS"},
		Debug:          serverConfig.DebugEnabled,
	})

	commonMiddleware := []Middleware{
		// Gracefully recover from panic returning HTTP 500.
		// handlers.RecoveryHandler(),
		// Generate a unique ID and initilize structured logging for request.
		loggingMiddleware,
	}

	authMiddleware := append(commonMiddleware, []Middleware{
		authorizeMiddleware,
	}...)

	router := mux.NewRouter()
	router.Handle("/api/apps", multipleMiddleware(http.HandlerFunc(getApps), authMiddleware...)).Methods("GET")
	router.Handle("/api/dashboard", multipleMiddleware(http.HandlerFunc(getDashboardConfig), authMiddleware...)).Methods("GET")

	router.HandleFunc("/api/authenticate", authenticate).Methods("POST")
	router.HandleFunc("/api/generate-password", generatePassword).Methods("POST")

	router.PathPrefix("/").Handler(http.FileServer(http.Dir("./frontend")))

	log.Fatal(http.ListenAndServe(":8443", c.Handler(router)))
}
