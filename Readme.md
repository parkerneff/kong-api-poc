# Run sample service in local docker
    docker run -d --name sample-api -p 80:80 proff116/service-api-sample

## Sample endpoints
* http://localhost/users/1
* http://localhost/posts
* http://localhost/posts/1


# Local Docker Instructions
    docker network create kong-net

## Create DB
    docker run -d --name kong-database \
               --network=kong-net \
               -p 5432:5432 \
               -e "POSTGRES_USER=kong" \
               -e "POSTGRES_DB=kong" \
               -e "POSTGRES_PASSWORD=kong" \
               postgres:9.6
## Setup DB
    docker run --rm \
     --network=kong-net \
     -e "KONG_DATABASE=postgres" \
     -e "KONG_PG_HOST=kong-database" \
     -e "KONG_PG_USER=kong" \
     -e "KONG_PG_PASSWORD=kong" \
     -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
     kong:latest kong migrations bootstrap

## Start Kong
    docker run -d --name kong \
     --network=kong-net \
     -e "KONG_DATABASE=postgres" \
     -e "KONG_PG_HOST=kong-database" \
     -e "KONG_PG_USER=kong" \
     -e "KONG_PG_PASSWORD=kong" \
     -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
     -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
     -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
     -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
     -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
     -p 8000:8000 \
     -p 8443:8443 \
     -p 127.0.0.1:8001:8001 \
     -p 127.0.0.1:8444:8444 \
     kong:latest

## Verify Installation
    curl -i -X GET --url http://localhost:8001/services

    curl -i -X GET http://localhost:8001

## Create A Service
    curl -i -X POST http://localhost:8001/services \
    --data name=example_service \
    --data url='http://mockbin.org'

## Verify Service
    curl -i http://localhost:8001/services/example_service

## Add a route
    curl -i -X POST http://localhost:8001/services/example_service/routes \
    --data 'paths[]=/mock' \
    --data name=mocking

## Verify route in browser
http://localhost:8000/mock

## Setup Key Authentication Plugin
    curl -X POST http://localhost:8001/routes/mocking/plugins \
    --data name=key-auth

## Try to access without auth
    curl -i http://localhost:8000/mock

## Set up Consumers and Credentials
    curl -i -X POST http://localhost:8001/consumers/ \
    --data username=consumer \
    --data custom_id=consumer

## Provision Key for Consumer
    curl -i -X POST http://localhost:8001/consumers/consumer/key-auth \
    --data key=apikey

Responded with 
{"consumer":{"id":"eb90fd89-b79e-4627-9a21-90f41ba4a0fe"},"key":"apikey","id":"56a55ffe-5d94-4e6d-9e99-a44e15fad69c","tags":null,"ttl":null,"created_at":1616780518}