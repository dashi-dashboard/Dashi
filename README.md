<h1 align="center"> Dashi </h1>
<p align="center"> 
  <a align="center">
    <img src="README/Icon.png?raw=true" alt="Logo" align="center">
  </a>
</p>

<p align="center">
  <a href="https://cloud.drone.io/declanthebritton/Dashi">
    <img src="https://cloud.drone.io/api/badges/declanthebritton/Dashi/status.svg" />
  </a>
  <a href="https://hub.docker.com/r/declanisbritton/dashi">
    <img alt="Docker Image Version (latest by date)" src="https://img.shields.io/docker/v/declanisbritton/dashi?arch=amd64&label=docker&logo=docker">
  </a>
</p>

Dashi is a config driven, application dashboard SPA (Single Page Application) built with a Go API backend and a Flutter frontend, bundled up into a docker container for good measure.

## Prerequisites
 
 
In order to run this container you'll need docker installed.
 
* [Windows](https://docs.docker.com/windows/started)
* [OS X](https://docs.docker.com/mac/started/)
* [Linux](https://docs.docker.com/linux/started/)
 
## Building Dashi
 
To build Dashi, simply run:
```bash
docker build \
  --tag dashi:latest \
  -f packaging/Dockerfile \  
  .
```
## Using Dashi
 
To run Dashi with a config:
 
```bash
docker run -d \
  -p 8443:8443 \
  -v "${PWD}/config.toml":/config.toml \
  --name dashi \
  declanisbritton/dashi:latest 
```
 
To run Dashi with a config and Icons
 
```bash
docker run -d \
  -p 8443:8443 \
  -v "${PWD}/images/":/app/frontend/assets/images/ \
  -v "${PWD}/config.toml":/config.toml \
  --name dashi \
  declanisbritton/dashi:latest
```

## Docker Images
 
Dashi is split over three docker images:
* Frontend
* Backend
* Full Stack
 
The frontend and backend images are built for the amd64 architecture and can be pulled with the following:
###### Frontend:
```
docker pull declanisbritton/dashi:frontend
```
###### Backend:
```
docker pull declanisbritton/dashi:backend
```
The full stack container is build for all officially supported docker architectures and can be retrieved with the following command
###### Full Stack:
```
docker pull declanisbritton/dashi:latest
```
 
When pulling you may specify a version down to each [Semantic Version](https://semver.org/). for example:
###### Major Verison:
```
docker pull declanisbritton/dashi:1
```
###### Minor Version:
```
docker pull declanisbritton/dashi:1.2
```
###### Patch Version:
```
docker pull declanisbritton/dashi:1.2.4
```

## Config
 
Config for Dashi is driven by [TOML](https://github.com/toml-lang/toml)

Apps are configured as a toml map. If you have apps that you want to only be accessible to certain users, you can assign one or more roles under the `access_roles` key. If set, only users who have their `role` set to one of the roles listed will be able to see the app in the dashboard. If you do not set `access_roles` the app will be viewable to everyone including anonymous users.
 
```toml
[Apps]
 
    [Apps."<APP NAME>"]
    url="<APP URL>"
    tag="<TAG>"
    enable_api=false
    icon="images/<ICON PATH>.png"
    color="#ffffff"
    access_roles=["<ROLE NAME 1>", "<ROLE NAME 2>"]
```

Global dashboard configuration is described under the Dashboard section. Here you can control overall looks of the dashboard such as background images.

```toml
[Dashboard]
background="#D7D9CE"
background_image="images/background.png"
```

Users can be added to Dashi by adding one or more user entries. The password should be a bcrypt hash of the password. This can be generated through the provided Dashi UI, third party sites, or any other method of generating bcrypt hashes. Adding a role to a user will allow them to see restricted apps which have their role listed.

```toml
[[Users]]
name = "myusername"
password = "$2y$12$IeDH28Rgta36lZ.JEhI.qeqky3OTxMM806jhmm4rI91Peg91OLqhi" # mypassword bcrypt'ed
role = "myrole"

[[Users]]
name = "mysecondusername"
role = "differentrole"
```

There are also some global configuration options. The most important of which for authentication is `jwt_key` which must be set. `jwt_key` should be set to a random 32 character string. This can be generated on linux with `openssl rand -base64 22`. On windows, or for those not comfortable with the command line, we recommend using [the Lastpass password generator](https://www.lastpass.com/password-generator). Changing this value will log out all currently logged in users.

Below is a full example configuration file with any options not previously discussed commented.

```toml
jwt_key = "zTvGErBLHJ0lc3CbxmB7gPU8Vo1ihg=="

# control the bcrypt cost factor used by UI hash generator.
# https://wildlyinaccurate.com/bcrypt-choosing-a-work-factor/
# Defaults to 10.
password_hash_cost = 10

# Time (in minutes) each login should be valid for.
# Defaults to 60.
login_timeout = 60

# Enables debug output in the console. Mostly useful for bug reports and developers.
# Defaults to false.
enable_debug = false

[Apps]

    [Apps."My App Name"]
    url="http://127.0.0.1"
    tag="mytag"
    enable_api=false

    [Apps."My Restricted App Name"]
    url="http://127.0.0.1"
    tag="mytag"
    access_roles=["myrole"]
    enable_api=false

[[Users]]
name = "myusername"
password = "$2y$12$IeDH28Rgta36lZ.JEhI.qeqky3OTxMM806jhmm4rI91Peg91OLqhi" # mypassword bcrypt'ed
role = "myrole"

[[Users]]
name = "mysecondusername"
role = "differentrole"
```
 
## Adding icons
 
If you wish to add your own icon into the path inside the container to bind is:
```
/app/frontend/assets/images/
```
You can then use the icon option in the toml config with `image/<icon file>`.
mounting with a sub directory would have the same effect such as:
```
/app/frontend/assets/images/extras
```
You would reference this in the config like
```
icon="images/extras/<ICON PATH>.png"
```
 
## Authors

* declanthebritton - 💻 - [declanthebritton](https://github.com/declanthebritton)
* SavoirFaire - 💻 - [SavoirFaire](https://github.com/savoiringfaire) 

## License
 
This project uses the following license:
[MIT](https://choosealicense.com/licenses/mit/)
See `LICENSE.md` for more information.