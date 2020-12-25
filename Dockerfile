FROM alpine

RUN apk --no-cache add \
	skopeo \
	jq \
	bash \
	curl \
	grep \
	coreutils

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
