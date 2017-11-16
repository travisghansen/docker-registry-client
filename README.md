# docker-registry-curl

This program will allow you to delete image tags that are in a private
container registry.  Please see [docker's api](https://docs.docker.com/registry/spec/api/) for more details on how
this is done.

# Example
```
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}" "${DOCKER_REGISTRY}"
export DOCKER_ETAG=$(docker-registry-curl -H "Accept: application/vnd.docker.distribution.manifest.v2+json" -X GET "https://${DOCKER_REGISTRY}/v2/${DOCKER_PROJECT}/manifests/${DOCKER_TAG}" -si | egrep -e "^Etag: " | cut -d " " -f2 | tr -d \" | sed 's/\r//')
echo "Attempting to remove ${DOCKER_ETAG}"
docker-registry-curl -vsL -X DELETE "https://${DOCKER_REGISTRY}/v2/${DOCKER_PROJECT}/manifests/${DOCKER_ETAG}"
```

# Variables to the application
| Environmental Variable | Why |
| --- | --- |
| DOCKER_USERNAME | The username to authenticate against the registry  |
| DOCKER_PASSWORD | The password for the aforementioned account        |
| DOCKER_REGISTRY | The docker registry - cannot be hub.docker.com     |
| DOCKER_PROJECT  | The project of the image (_`acmecompany/service-a`_) |
| DOCKER_TAG      | The tag of the image you want to delete            |

# Docker Image
This can be converted into a docker container image - which can be
useful in a CI/CD environment.  Please see the Dockerfile

## Example Usage: GitLab CI/CD
If you want images in gitlab to be deleted upon failure, a possible
job could be:

```yaml
cleanup:broken-build:
  stage: cleanup
  variables:
    DOCKER_REGISTRY: $CI_REGISTRY
    DOCKER_PROJECT: $CI_PROJECT_PATH
    DOCKER_TAG: $CI_COMMIT_TAG
    DOCKER_USERNAME: $REGISTRY_USERNAME # Should be provided as a protected pipeline variable
    DOCKER_PASSWORD: $REGISTRY_PASSWORD # Should be provided as a protected pipeline variable
  only:
    - tags
  when: on_failure
  allow_failure: true
  image: URI_to_this_docker_image:version
  script:
  - /entrypoint.sh
```

Note: Currently gitlab-ci user account does not have delete access to
container registry, so you will have to use a separate account.  The
`DOCKER_USERNAME` and `DOCKER_PASSWORD` are variables that would be set
in the CI/CD protected variables section.
