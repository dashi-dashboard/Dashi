docker build \
  --tag dashi:latest \
  --build-arg http_proxy=${HTTP_PROXY} \
  --build-arg https_proxy=${HTTPS_PROXY} \
  --build-arg no_proxy=${no_proxy} \
  -f packaging/Dockerfile \  
  .

docker run -d \
  -p 8443:8443 \
  --name dashi \
  dashi:latest 

docker run -d \
  -p 8443:8443 \
  -v ${PWD}/config.toml:/config.toml \
  --name dashi \
  dashi:latest 