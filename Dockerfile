FROM alpine AS builder
WORKDIR /root
RUN set -ex \
	&& VERSION="v1.14.1" \
	&& apk add --no-cache git build-base make cmake boost-dev openssl-dev mariadb-connector-c-dev \
	&& git clone --branch ${VERSION} --single-branch https://github.com/trojan-gfw/trojan.git \
	&& cd trojan \
	&& cmake . \
	&& make \
	&& strip -s trojan

FROM alpine
LABEL maintainer="Primovist"

RUN set -ex \
	&& apk add --no-cache tzdata ca-certificates libstdc++ boost-system boost-program_options mariadb-connector-c

COPY --from=builder /root/trojan/trojan /usr/bin
COPY config.json /etc/trojan/config.json
VOLUME /etc/trojan
ENV TZ=Asia/Shanghai
CMD [ "trojan", "-c", "/etc/trojan/config.json" ]
