FROM joshdev/alpine-oraclejdk8:8u102

# Set environment
ENV UNDERLYING_SBT /usr/lib/bin/sbt

# Install packages
RUN apk add --no-cache bash
RUN apk add --no-cache --virtual=build-dependencies wget ca-certificates
RUN apk add --no-cache git
RUN apk add --no-cache openssh
RUN apk add --no-cache curl
RUN apk add --no-cache jq
RUN apk add --no-cache ruby
RUN apk add --no-cache ruby-bundler ruby-dev ruby-irb ruby-rdoc libatomic readline readline-dev \
    libxml2 libxml2-dev libxslt libxslt-dev zlib-dev zlib libffi-dev build-base nodejs

RUN export PATH="/root/.rbenv/bin:$PATH"
RUN gem update --system
RUN gem install sass
RUN gem install jekyll

RUN mkdir /usr/lib/bin
RUN curl -s https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt > /usr/lib/bin/sbt
RUN chmod 0755 /usr/lib/bin/sbt

# Add all scripts in image
COPY bin /usr/local/bin
COPY sbt.boot /sbt.boot

# Copy our custom sbt to the default location, replace previous
RUN mv /usr/local/bin/sbt /usr/bin/sbt
RUN $UNDERLYING_SBT about -sbt-create -Dsbt.boot.properties=/sbt.boot

# Remove dependencies
RUN apk del build-dependencies
RUN apk del build-base zlib-dev ruby-dev readline-dev libffi-dev libxml2-dev

# Set up and warm sbt
RUN git clone https://github.com/olafurpg/warm-sbt
RUN cd warm-sbt && git checkout v0.2 && $UNDERLYING_SBT "+run" -Dsbt.boot.properties=/sbt.boot && cd .. && rm -rf warm-sbt
RUN mv /root/.sbt/* /drone/.sbt
RUN rm -rf /root/.sbt

RUN rm -rf /tmp/*
