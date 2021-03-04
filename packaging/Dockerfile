FROM alpine:3.10
WORKDIR app
COPY --from=declanisbritton/dashi:frontend /usr/share/nginx/html ./frontend/
COPY --from=declanisbritton/dashi:backend /app/server ./
RUN ls
CMD ./server