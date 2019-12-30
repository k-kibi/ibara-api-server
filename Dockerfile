ARG RUBY_VERSION

FROM ruby:${RUBY_VERSION}-slim

ENV LANG=C.UTF-8 \
  LC_ALL=C.UTF-8

RUN apt-get update -q && \
  apt-get upgrade -y && \
  apt-get install -y --allow-downgrades zsh less cmake apt-transport-https gettext-base libmariadbd-dev libmariadb-dev wget

ARG BUNDLER_VERSION
ARG RUBYGEMS_VERSION

ENV BUNDLE_JOBS=4 \
  RUBYGEMS_VERSION=$RUBYGEMS_VERSION \
  BUNDLER_VERSION=$BUNDLER_VERSION \
  BUNDLE_PATH=/vendor/bundle/$RUBY_VERSION
RUN gem update --system $RUBYGEMS_VERSION && \
  gem install bundler -v $BUNDLER_VERSION

RUN useradd --create-home --user-group --uid 1000 kibi && \
  mkdir /vendor && \
  chown -R kibi:kibi /vendor $GEM_HOME $BUNDLE_BIN

ENV ENTRYKIT_VERSION 0.4.0

RUN wget https://github.com/progrium/entrykit/releases/download/v${ENTRYKIT_VERSION}/entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && tar -xvzf entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && rm entrykit_${ENTRYKIT_VERSION}_Linux_x86_64.tgz \
  && mv entrykit /bin/entrykit \
  && chmod +x /bin/entrykit \
  && entrykit --symlink

COPY docker /docker

RUN mkdir -p /app/ibara-api-server && \
  cd /app/ibara-api-server && \
  (test -z "tmp" || mkdir -p tmp) && \
  chown -R kibi:kibi /app

USER kibi

ENTRYPOINT ["prehook", "/docker/prehook", "--"]
