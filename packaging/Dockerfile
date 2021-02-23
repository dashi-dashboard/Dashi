FROM debian:latest AS FLUTTER_BUILD

RUN apt-get update 
RUN apt-get install -y curl git wget unzip libgconf-2-4 gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3
RUN apt-get clean

RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter

ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

RUN flutter doctor -v
RUN flutter channel master
RUN flutter upgrade
RUN flutter config --enable-web

RUN mkdir /app
COPY frontend /app
WORKDIR /app
RUN flutter build web

FROM golang:1.13.1-alpine AS GO_BUILD
RUN apk add build-base
COPY backend /backend
WORKDIR /backend
RUN go build -o /go/bin/server

FROM alpine:3.10
WORKDIR app
COPY --from=FLUTTER_BUILD /app/build/web ./frontend/
COPY --from=GO_BUILD /go/bin/server ./
RUN ls
CMD ./server