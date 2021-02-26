package main

import (
	"fmt"
	"io/ioutil"

	"github.com/pelletier/go-toml"
)

// Config stores the global user-defined configuration and content to be served throuth the API.
type Config struct {
	Apps  map[string]App  `toml:"Apps"`
	Users map[string]User `toml:"Users"`
	Dashboard Dashboard `toml:"Dashboard"`
}

// App represents a single clickable app on the dashboard.
type App struct {
	URL       string `toml:"url"`
	Tag       string `toml:"tag"`
	EnableAPI bool   `toml:"enable_api"`
	Icon      string `toml:"icon"`
	Color     string `toml:"color"`
}

// User represents a single dashboard user who can view restricted items.
type User struct {
	Role string `toml:"role"`
}

type Dashboard struct {
	Background 		string `toml:"background"`
	BackgroundImage string `toml:"background_image"`
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
