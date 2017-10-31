#!/bin/bash

docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}" "${DOCKER_REGISTRY}"
export DOCKER_ETAG=$(docker-registry-curl -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET "https://${DOCKER_REGISTRY}/v2/${DOCKER_PROJECT}/manifests/${DOCKER_TAG}" -si | egrep -e "^Etag: " | cut -d " " -f2 | tr -d \" | sed 's/\r//')
echo "Attempting to remove ${DOCKER_ETAG}"
docker-registry-curl -D - -sL -X DELETE "https://${DOCKER_REGISTRY}/v2/${DOCKER_PROJECT}/manifests/${DOCKER_ETAG}"
