FROM alpine

ENTRYPOINT /entrypoint.sh

ADD docker-registry-curl /usr/bin
ADD entrypoint.sh /
RUN chmod a+x /usr/bin/docker-registry-curl /entrypoint.sh

RUN apk add --no-cache curl openssl jq bash
