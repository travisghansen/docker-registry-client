#!/bin/bash

# REQUIREMENTS
#  curl
#  jq
#  base64
#  egrep
#  cut
#  sed

#set -x

console() {
    :
    return
    echo "${@}"
}

main() {
    OUTPUT=$(curl "${@}" --head -vsi 2>&1 | egrep -e "^<|^>")
    REGISTRY_HOST=$(echo "${OUTPUT}" | egrep "> Host: " | cut -d ":" -f2 | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    WWW_AUTHENTICATE=$(echo "${OUTPUT}" | egrep "< Www-Authenticate: " | cut -d ":" -f2- | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    console "${OUTPUT}"
    console "${REGISTRY_HOST}"
    console "${WWW_AUTHENTICATE}"

    if [ "x${WWW_AUTHENTICATE}" != "x" ];then
        # we need to get a token
        DOCKER_AUTH_TYPE=$(echo "${WWW_AUTHENTICATE}" | cut -d " " -f 1)
        DETAILS=$(echo "${WWW_AUTHENTICATE}" | cut -d " " -f 2-)
        console "${DOCKER_AUTH_TYPE}"
        console "${DETAILS}"
        console "${REGISTRY_HOST}"
        if [ "${DOCKER_AUTH_TYPE}" == "Bearer" ];then
            REALM=$(echo "${DETAILS}" | cut -d ',' -f 1 | cut -d "=" -f 2 | tr -d '"')
            SERVICE=$(echo "${DETAILS}" | cut -d ',' -f 2 | cut -d "=" -f 2 | tr -d '"')
            SCOPE=$(echo "${DETAILS}" | cut -d ',' -f 3 | cut -d "=" -f 2 | tr -d '"')
            if [ "x${DOCKER_AUTH}" != "x" ];then
                :
            elif [[ "x${DOCKER_USERNAME}" != "x" && "x${DOCKER_PASSWORD}" != "x" ]];then
                DOCKER_AUTH="${DOCKER_USERNAME}:${DOCKER_PASSWORD}"
            elif [ -e ~/.docker/config.json ];then
                DOCKER_AUTH=$(jq -r ".[\"auths\"][\"${REGISTRY_HOST}\"][\"auth\"]" ~/.docker/config.json | base64 -d)
            fi
            console "${REALM}"
            console "${SERVICE}"
            console "${SCOPE}"
            console "${DOCKER_AUTH}"
            if [ "x" != "x${DOCKER_AUTH}" ];then
                DOCKER_AUTH_TOKEN=$(curl -m 10 -u "${DOCKER_AUTH}" "${REALM}?service=${SERVICE}&scope=${SCOPE}" -s 2>/dev/null | jq -r .token | xargs echo)
            fi 
            console "${DOCKER_AUTH_TOKEN}"
        fi
    fi

    curl -H "Authorization: ${DOCKER_AUTH_TYPE} ${DOCKER_AUTH_TOKEN}" "${@}"
}

main "${@}"
