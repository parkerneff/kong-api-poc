#!/bin/bash

docker rm -f kong-ee
docker rm -f kong-ee-database
docker network remove kong-ee-net