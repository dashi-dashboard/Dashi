package main

import (
	"fmt"
	"io/ioutil"

	"github.com/pelletier/go-toml"
)

// Config stores the global user-defined configuration and content to be served throuth the API.
type Config struct {
	Apps  map[string]App `toml:"Apps"`
	Users []User         `toml:"Users"`
}

// App represents a single clickable app on the dashboard.
type App struct {
	URL       string `toml:"url"`
	Tag       string `toml:"tag"`
	EnableAPI bool   `toml:"enable_api"`
	Icon      string `toml:"icon"`
}

// User represents a single dashboard user who can view restricted items.
type User struct {
	Name string `toml:"name"`
	Role string `toml:"role"`
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
