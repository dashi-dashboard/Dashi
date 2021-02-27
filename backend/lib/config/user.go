package config

import (
	"time"

	"github.com/dgrijalva/jwt-go"
	"golang.org/x/crypto/bcrypt"
)

// User represents a single dashboard user who can view restricted items.
type User struct {
	Username string `toml:"name"`
	Role     string `toml:"role"`
	Password string `toml:"password" json:"-"`
}

// Authenticate checks that password matches the password hash of the user in config.
// If it does, Authenticate generates and returns a new JWT.
func (u *User) Authenticate(password string, config *Config) (string, error) {
	err := bcrypt.CompareHashAndPassword([]byte(u.Password), []byte(password))
	if err != nil {
		return "", err
	}

	return u.generateToken(config)
}

func (u *User) generateToken(config *Config) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"username": u.Username,
		"exp":      time.Now().Unix() + (int64(config.LoginTimeout) * 60),
	})

	tokenString, err := token.SignedString([]byte(config.JWTKey))

	return tokenString, err
}
