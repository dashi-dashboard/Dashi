FROM golang:1.13.1-alpine AS GO_BUILD
RUN apk add build-base
COPY backend /backend
WORKDIR /backend
RUN go build -o /go/bin/server

# Build Final Image
FROM alpine:3.10

WORKDIR app
COPY --from=declanisbritton/dashi:frontend /usr/share/nginx/html ./frontend/
COPY --from=GO_BUILD /go/bin/server ./

RUN ls

EXPOSE 8443

CMD ./server
