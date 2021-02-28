package config

import (
	"fmt"
	"time"

	"github.com/dgrijalva/jwt-go"
)

// Config stores the global user-defined configuration and content to be served throuth the API.
type Config struct {
	Apps             map[string]App `toml:"Apps"`
	Users            []User         `toml:"Users"`
	JWTKey           string         `toml:"jwt_key"  json:"-"`
	PasswordHashCost int            `toml:"password_hash_cost"`
	LoginTimeout     int            `toml:"login_timeout"  json:"-"`
	Dashboard        Dashboard      `toml:"Dashboard"`
	DebugEnabled     bool           `toml:"enable_debug" json:"-"`
}

// AuthenticateUser will find and a user authenticte using provided username/password.
// Returns a jwt token which can be passed to AuthenticateToken to check validity and find the user.
func (c *Config) AuthenticateUser(username string, password string) (string, error) {
	user, err := c.FindUserByUsername(username)
	if err != nil {
		return "", err
	}

	return user.Authenticate(password, c)
}

// AuthenticateToken will take a jwt token and first confirm it is valid (e.g. not expired)
// once confirmed valid, it will find the user object used to authenticate and return.
func (c *Config) AuthenticateToken(tokenString string) (*User, error) {
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
	}

	return nil, fmt.Errorf("Error getting token claims")
}

// GetFilteredAppsList returns a copy of the Config.Apps field with only the apps user is allowed to see.
func (c *Config) GetFilteredAppsList(user *User) map[string]App {
	filteredList := make(map[string]App)

	for name, app := range c.Apps {
		if app.RoleAuthorized(user.Role) {
			filteredList[name] = app
		}
	}

	return filteredList
}

// GetPublicAppsList returns a copy of the Config.Apps field with only publically viewable apps.
func (c *Config) GetPublicAppsList() map[string]App {
	filteredList := make(map[string]App)

	for name, app := range c.Apps {
		if len(app.AccessRoles) == 0 {
			filteredList[name] = app
		}
	}

	return filteredList
}

// FindUserByUsername returns the full user object of a given username.
func (c *Config) FindUserByUsername(username string) (*User, error) {
	for _, user := range c.Users {
		if user.Username == username {
			return &user, nil
		}
	}

	return nil, fmt.Errorf("No user with username %s found", username)
}
