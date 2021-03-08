package main

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"

	"server/lib/config"
	"server/lib/eventbus"

	"github.com/google/uuid"
	"github.com/gorilla/handlers"
	"github.com/gorilla/mux"
	"github.com/howeyc/fsnotify"
	"github.com/rs/cors"
	log "github.com/sirupsen/logrus"
	"golang.org/x/crypto/bcrypt"
)

var serverConfig *config.Config
var serverConfigLock sync.RWMutex

var events *eventbus.EventBus

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
			logger.Trace("No authorization header supplied")

			ctx := context.WithValue(r.Context(), authenticatedRequestKey, false)
			next.ServeHTTP(w, r.WithContext(ctx))

			return
		}

		logger.Tracef("Authorization header: %s", reqToken)
		splitToken := strings.Split(reqToken, "Bearer ")
		reqToken = splitToken[1]

		logger.Tracef("JWT Token: %s", reqToken)

		user, err := serverConfig.AuthenticateToken(reqToken)
		if err != nil {
			logger.Warnf("Error authenticating token: %s", err)
			http.Error(w, fmt.Sprintf("Error authenticating token: %s", err), http.StatusUnauthorized)
			return
		}

		logger = logger.WithFields(log.Fields{
			"authenticatedRequest": true,
			"username":             user.Username,
			"role":                 user.Role,
		})

		logger.Info("Token successfully authenticated")
		ctx := context.WithValue(r.Context(), authenticatedRequestKey, true)
		ctx = context.WithValue(ctx, authenticatedUserKey, user)
		ctx = context.WithValue(ctx, loggerKey, logger)
		logger = getLogger(ctx)

		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

type authenticateResponse struct {
	Success bool
	Message string
	Token   string
}

func authenticate(w http.ResponseWriter, r *http.Request) {
	logger := getLogger(r.Context())

	var response authenticateResponse
	response.Success = true

	r.ParseForm()
	username := r.Form.Get("username")
	password := r.Form.Get("password")

	logger.Tracef("Authenticating user %s", username)

	token, err := serverConfig.AuthenticateUser(username, password)
	if err != nil {
		response.Success = false
		response.Message = err.Error()
		logger.Warnf("Error authenticating user: %s", err)
	}

	logger.Infof("Successfully authenticated user: %s", username)

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
		ret.Trace("Got logger")
		return ret
	}

	log.Trace("No logger found")
	return nil
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		reqID := uuid.New()

		requestLogger := log.WithFields(log.Fields{
			"requestID": reqID,
		})

		requestLogger.Trace("Initialized Request Logging")
		requestLogger.Infof("%s %s %s", r.RemoteAddr, r.Method, r.URL.Path)

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

	return wrapped
}

func watchConfig() {
	watcher, err := fsnotify.NewWatcher()
	if err != nil {
		log.Fatal(err)
	}

	// Process events
	go func() {
		for {
			select {
			case ev := <-watcher.Event:
				log.Trace("Config filesystem event:", ev)

				serverConfigLock.Lock()
				// It seems that without a small wait, about 50% of the time we end up with an empty config file.
				// I'm not sure if this is a race condition elsewhere in the OS or something, but a small wait here sorts the issue.
				time.Sleep(50 * time.Millisecond)
				serverConfig, err = config.FromFile("../config.toml")
				serverConfigLock.Unlock()
				if err != nil {
					log.Errorf("Error reading config file: %s", err)
					break
				}

				events.Publish("config_update", serverConfig)
			case err := <-watcher.Error:
				log.Error("Error in config update watcher:", err)
			}
		}
	}()

	err = watcher.Watch("../config.toml")
	if err != nil {
		log.Fatal(err)
	}
}

func getAppsPoll(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	configsub := events.Subscribe("config_update")
	defer events.UnSubscribe("config_update", configsub)

	timeout := make(chan bool)

	go func() {
		time.Sleep(30e9)
		timeout <- true
	}()

	select {
	case newConfigInterface := <-configsub:
		newConfig := newConfigInterface.(*config.Config)

		serverConfigLock.RLock()
		defer serverConfigLock.RUnlock()

		if !r.Context().Value(authenticatedRequestKey).(bool) {
			json.NewEncoder(w).Encode(newConfig.GetPublicAppsList())
			return
		}

		user := r.Context().Value(authenticatedUserKey).(*config.User)

		json.NewEncoder(w).Encode(newConfig.GetFilteredAppsList(user))
	case _ = <-timeout:
		return
	}
}

func main() {
	var err error

	events = eventbus.New()

	serverConfig, err = config.FromFile("../config.toml")
	if err != nil {
		log.Printf("Error reading config file: %s", err)
	}

	watchConfig()

	c := cors.New(cors.Options{
		AllowedOrigins:   []string{"*"},
		AllowedMethods:   []string{"GET", "HEAD", "POST", "DELETE", "PUT", "OPTIONS"},
		AllowCredentials: true,
		AllowedHeaders:   []string{"Authorization", "Content-Type"},
	})

	if serverConfig.DebugEnabled {
		log.Info("Debug logging enabled")
		log.SetLevel(log.TraceLevel)
	}

	commonMiddleware := []Middleware{
		// Gracefully recover from panic returning HTTP 500.
		handlers.RecoveryHandler(),
		// Generate a unique ID and initilize structured logging for request.
		loggingMiddleware,
	}

	authMiddleware := append(commonMiddleware, []Middleware{
		authorizeMiddleware,
	}...)

	router := mux.NewRouter()
	router.Handle("/api/apps", multipleMiddleware(http.HandlerFunc(getApps), authMiddleware...)).Methods("GET")
	router.Handle("/api/apps/poll", multipleMiddleware(http.HandlerFunc(getAppsPoll), authMiddleware...)).Methods("GET")
	router.Handle("/api/dashboard", multipleMiddleware(http.HandlerFunc(getDashboardConfig), authMiddleware...)).Methods("GET")

	router.Handle("/api/authenticate", multipleMiddleware(http.HandlerFunc(authenticate), commonMiddleware...)).Methods("POST")
	router.Handle("/api/generate-password", multipleMiddleware(http.HandlerFunc(generatePassword), commonMiddleware...)).Methods("POST")

	router.PathPrefix("/").Handler(http.FileServer(http.Dir("./frontend")))

	log.Fatal(http.ListenAndServe(":8443", c.Handler(router)))
}
