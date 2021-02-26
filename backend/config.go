package main

import (
	"crypto/rsa"
	"fmt"
	"io/ioutil"
	"time"

	"github.com/dgrijalva/jwt-go"
	"github.com/pelletier/go-toml"
	"golang.org/x/crypto/bcrypt"
)

// Config stores the global user-defined configuration and content to be served throuth the API.
type Config struct {
	Apps           map[string]App `toml:"Apps"`
	Users          []User         `toml:"Users"`
	JWTKey         string         `toml:"jwt_key"`
	JWTKeyPassword string         `toml:"jwt_key_password"`
	LoginTimeout   int            `toml:"login_timeout"`
}

// App represents a single clickable app on the dashboard.
type App struct {
	URL         string   `toml:"url"`
	Tag         string   `toml:"tag"`
	EnableAPI   bool     `toml:"enable_api"`
	Icon        string   `toml:"icon"`
	AccessRoles []string `toml:"access_roles"`
}

// User represents a single dashboard user who can view restricted items.
type User struct {
	Username string `toml:"name"`
	Role     string `toml:"role"`
	Password string `toml:"password" json:"-"`
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

	key, err := config.parseJWTKey()
	if err != nil {
		return "", err
	}

	tokenString, err := token.SignedString(key)

	return tokenString, err
}

func (c *Config) AuthenticateToken(tokenString string, config *Config) (*User, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		// Don't forget to validate the alg is what you expect:
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("Unexpected signing method: %v", token.Header["alg"])
		}

		// hmacSampleSecret is a []byte containing your secret, e.g. []byte("my_secret_key")
		return config.parseJWTKey()
	})

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		if claims["exp"].(int64) > time.Now().Unix() {
			return nil, fmt.Errorf("Token has expired")
		}

		return c.FindUserByUsername(claims["username"].(string))
	} else {
		return nil, err
	}
}

func (c *Config) FindUserByUsername(username string) (*User, error) {
	for _, user := range c.Users {
		if user.Username == username {
			return &user, nil
		}
	}

	return nil, fmt.Errorf("No user with username %s found", username)
}

func (c *Config) parseJWTKey() (*rsa.PrivateKey, error) {
	if c.JWTKey == "" {
		return nil, fmt.Errorf("jwt_key must be defined to enable authentication")
	}

	var key *rsa.PrivateKey
	var err error

	if c.JWTKeyPassword == "" {
		key, err = jwt.ParseRSAPrivateKeyFromPEM([]byte(c.JWTKey))
	} else {
		key, err = jwt.ParseRSAPrivateKeyFromPEMWithPassword([]byte(c.JWTKey), c.JWTKeyPassword)
	}

	if err != nil {
		return nil, fmt.Errorf("error parsing JWT key for authentication: %w", err)
	}

	return key, nil
}

func readConfig(filename string) (*Config, error) {
	tomlFile, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("Failed reading config file: %w", err)
	}

	var config Config

	toml.Unmarshal(tomlFile, &config)
	fmt.Println(config)

	return &config, nil
}
