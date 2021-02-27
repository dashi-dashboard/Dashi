<h1 align="center"> Dashi </h1>
<p align="center"> 
  <a align="center">
    <img src="README/Icon.png?raw=true" alt="Logo" align="center">
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
  -v ${PWD}/config.toml:/config.toml \
  --name dashi \
  dashi:latest 
```
 
To run Dashi with a config and Icons
 
```bash
docker run -d \
  -p 8443:8443 \
  -v ${PWD}/images/:/app/frontend/assets/images/ \
  -v ${PWD}/config.toml:/config.toml \
  dashi:latest
```
 
## Config
 
Config for Dashi is driven by [TOML](https://github.com/toml-lang/toml)
 
```toml
[Apps]
 
    [Apps."<APP NAME>"]
    url="<APP URL>"
    tag="<TAG>"
    enable_api=false
    icon="images/<ICON PATH>.png"
    color="#ffffff"
 
[Dashboard]
background="#D7D9CE"
background_image="images/background.png"
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