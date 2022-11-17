FROM golang:1.18.4
WORKDIR /app
COPY Files/server_go/server.go ./
COPY Files/server_go/go.mod ./
COPY Files/server_go/go.sum ./
RUN go build -o server 



FROM nginx:1.23.2

LABEL maintainer="Wanetty - https://wanetty.github.io"


RUN apt update && apt install sudo -y
RUN echo 'www-data ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY --from=0 /app/server /root/server