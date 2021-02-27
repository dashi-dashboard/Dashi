package config

// Dashboard contains config regarding display of the dashboard as a whole rather than individual apps.
type Dashboard struct {
	Background      string `toml:"background"`
	BackgroundImage string `toml:"background_image"`
}
