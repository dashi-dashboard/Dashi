package config

import (
	"fmt"
	"io/ioutil"
	"log"

	"github.com/pelletier/go-toml"
)

// FromFile creates a new instance of the config struct from the contents of a given toml file.
func FromFile(filename string) (*Config, error) {
	tomlFile, err := ioutil.ReadFile(filename)
	if err != nil {
		return nil, fmt.Errorf("Failed reading config file: %w", err)
	}

	config, err := Parse(tomlFile)

	return config, nil
}

// Parse creates a new instance of the config struct by parsing the bytes containing a toml file.
func Parse(bytes []byte) (*Config, error) {
	var config Config

	// Default login timeout to 60 minutes.
	config.LoginTimeout = 60
	// Default bcrypt password hash cost.
	config.PasswordHashCost = 10
	// Disable debug by default
	config.DebugEnabled = false

	err := toml.Unmarshal(bytes, &config)
	log.Println(config)

	return &config, err
}
