package main

import (
	"fmt"
	"io/ioutil"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/pelletier/go-toml"
	"golang.org/x/crypto/bcrypt"
)

// Config stores the global user-defined configuration and content to be served throuth the API.
type Config struct {
	Apps         map[string]App `toml:"Apps"`
	Users        []User         `toml:"Users"`
	JWTKey       string         `toml:"jwt_key"  json:"-"`
	LoginTimeout int            `toml:"login_timeout"  json:"-"`
	Dashboard    Dashboard      `toml:"Dashboard"`
}

// App represents a single clickable app on the dashboard.
type App struct {
	URL         string   `toml:"url"`
	Tag         string   `toml:"tag"`
	EnableAPI   bool     `toml:"enable_api"`
	Icon        string   `toml:"icon"`
	Color       string   `toml:"color"`
	AccessRoles []string `toml:"access_roles"`
}

// User represents a single dashboard user who can view restricted items.
type User struct {
	Username string `toml:"name"`
	Role     string `toml:"role"`
	Password string `toml:"password" json:"-"`
}

func (a *App) RoleAuthorized(role string) bool {
	if len(a.AccessRoles) == 0 {
		return true
	}

	for _, authorizedRole := range a.AccessRoles {
		if authorizedRole == role {
			return true
		}
	}

	return false
}

func (c *Config) AuthenticateUser(username string, password string) (string, error) {
	user, err := c.FindUserByUsername(username)
	if err != nil {
		return "", err
	}

	return user.Authenticate(password, c)
}

func (u *User) Authenticate(password string, config *Config) (string, error) {
	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	if err != nil {
		return "", err
	}

	return u.GenerateToken(config)
}

func (u *User) GenerateToken(config *Config) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"username": u.Username,
		"exp":      time.Now().Unix() + (int64(config.LoginTimeout) * 60),
	})

	tokenString, err := token.SignedString([]byte(config.JWTKey))

	return tokenString, err
}

func (c *Config) AuthenticateToken(tokenString string, config *Config) (*User, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Don't forget to validate the alg is what you expect:
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
		}

		// hmacSampleSecret is a []byte containing your secret, e.g. []byte("my_secret_key")
		return []byte(c.JWTKey), nil
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		if int64(claims["exp"].(float64)) < time.Now().Unix() {
			return nil, fmt.Errorf("Token has expired")
		}

		return c.FindUserByUsername(claims["username"].(string))
	} else {
		return nil, err
	}
}

func (c *Config) GetFilteredAppsList(user *User) map[string]App {
	filteredList := make(map[string]App)

	for name, app := range c.Apps {
		if app.RoleAuthorized(user.Role) {
			filteredList[name] = app
		}
	}

	return filteredList
}

func (c *Config) GetPublicAppsList() map[string]App {
	filteredList := make(map[string]App)

	for name, app := range c.Apps {
		if len(app.AccessRoles) == 0 {
			filteredList[name] = app
		}
	}

	return filteredList
}

func (c *Config) FindUserByUsername(username string) (*User, error) {
	for _, user := range c.Users {
		if user.Username == username {
			return &user, nil
		}
	}

	return nil, fmt.Errorf("No user with username %s found", username)
}

type Dashboard struct {
	Background      string `toml:"background"`
	BackgroundImage string `toml:"background_image"`
}

func readConfig(filename string) (*Config, error) {
	tomlFile, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("Failed reading config file: %w", err)
	}

	var config Config

	config.LoginTimeout = 60

	toml.Unmarshal(tomlFile, &config)
	fmt.Println(config)

	return &config, nil
}
