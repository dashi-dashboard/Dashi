package config

// App represents a single clickable app on the dashboard.
type App struct {
	URL         string   `toml:"url"`
	Tag         string   `toml:"tag"`
	EnableAPI   bool     `toml:"enable_api"`
	Icon        string   `toml:"icon"`
	Color       string   `toml:"color"`
	AccessRoles []string `toml:"access_roles"`
}

// RoleAuthorized checks if a given role should be allowed to see this app.
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
