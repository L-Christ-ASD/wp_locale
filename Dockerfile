FROM ubuntu:24.04

WORKDIR /app

COPY ./ ./

EXPOSE 80
EXPOSE 443

# SERVICES

# http://localhost:8080
# http://wordpress.localhost:81
# http://localhost:82 
# http://sonarqube.localhost:9000
