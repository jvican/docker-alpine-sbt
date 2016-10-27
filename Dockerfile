FROM joshdev/alpine-oraclejdk8:8u102

# Set environment
ENV SBT_HOME /usr/lib/sbt
ENV PATH $PATH:$SBT_HOME/bin

COPY .gnupg/platform.pubring.asc $HOME/.gnupg/
COPY .gnupg/platform.secring.asc $HOME/.gnupg/

RUN apk add --no-cache bash \
  && apk add --no-cache --virtual=build-dependencies wget ca-certificates \
  && apk add --no-cache git \
  && apk add --no-cache gnupg \
  && apk add --no-cache curl \
  && mkdir /usr/lib/bin \
  && curl -s https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt > /usr/lib/bin/sbt \
  && chmod 0755 /usr/lib/bin/sbt \
  && mv /usr/lib/bin/sbt /usr/bin/sbt \
  && /usr/bin/sbt about -sbt-create \
  && apk del build-dependencies \
  && rm -rf /tmp/*
