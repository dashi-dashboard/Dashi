package config

import "testing"

var testingConfig = Config{
	Apps: map[string]App{
		"app1": {
			URL:         "http://app1",
			AccessRoles: []string{"role1"},
		},
		"app2": {
			URL:         "http://app2",
			AccessRoles: []string{},
		},
	},
	Users: []User{
		{
			Username: "myusername",
			Role:     "role1",
		},
	},
}

func TestPublicAppsList(t *testing.T) {
	apps := testingConfig.GetPublicAppsList()

	if len(apps) != 1 {
		t.Errorf("Expected 1 public app, got %d", len(apps))
	}

	if _, ok := apps["app1"]; ok {
		t.Error("Apps array contained non-public app")
	}

	if _, ok := apps["app2"]; !ok {
		t.Error("Apps array did not contain public app")
	}
}

func TestFilteredAppsList(t *testing.T) {
	apps := testingConfig.GetFilteredAppsList(&testingConfig.Users[0])

	if len(apps) != 2 {
		t.Errorf("Expected 2 public apps, got %d", len(apps))
	}

	if _, ok := apps["app1"]; !ok {
		t.Error("Apps array contained non-public app")
	}

	if _, ok := apps["app2"]; !ok {
		t.Error("Apps array did not contain public app")
	}
}
