FROM alpine

RUN apk --no-cache add skopeo jq bash curl

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]