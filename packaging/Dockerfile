FROM alpine:3.10
WORKDIR app
COPY --from=dashi:frontend /usr/share/nginx/html ./frontend/
COPY --from=dashi:backend /app/server ./
RUN ls
CMD ./server