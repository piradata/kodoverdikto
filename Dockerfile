ARG RUBY_VERSION=3.2.2-alpine3.18
FROM ruby:${RUBY_VERSION}

### Define ENV Variables
ENV APP_ROOT /kodoverdikto
ENV PATH $APP_ROOT/bin:$PATH

### Configure bundler
ENV BUNDLE_PATH /usr/local/bundle
ENV GEM_PATH $BUNDLE_PATH
ENV BUNDLE_BIN $BUNDLE_PATH
ENV PATH $BUNDLE_PATH/bin:$BUNDLE_PATH/gems/bin:$PATH
ARG BUNDLER_VERSION=2.4.6

# Define container workdir location
WORKDIR $APP_ROOT

# Install system dependencies required both at runtime and build time
# tzdata (https://tips.tutorialhorizon.com/2017/08/29/tzinfodatasourcenotfound-when-using-alpine-with-docker/)
# shared-mime-info -- Dependency from gem 'mimemagic' (https://github.com/mimemagicrb/mimemagic#dependencies)
RUN apk add --update --no-cache --virtual run-dependencies \
    git \
    gnupg \
    libaio \
    libpq-dev \
    postgresql14-client \
    shared-mime-info \
    sqlite-dev \
    tzdata

### Configure bundler for production (Copy gemfiles and install gems)
# build-dependencies are deleted after gems instalation to optimize image size
# Some gems need build, example 'bcrypt', 'json', 'jaro_winkler' --> (dependency of development gem 'solargraph')
COPY Gemfile* ./
RUN apk add --update --no-cache --virtual build-dependencies make g++ build-base && \
    gem update --system && \
    gem install bundler -v $BUNDLER_VERSION --no-document && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle config set jobs 20 && \
    bundle check || bundle install && \
    apk del build-dependencies

###### PROD ONLY
# Add code to container (only production, as in development the code is cached on runtime as a volume)
COPY ./ $APP_ROOT
# Assets pipeline (only production, as in development js files are dinamically recompiled) (nodejs is needed by terser to compress js files)
RUN apk add --update --no-cache --virtual node-build-dependencies nodejs && \
    RAILS_ENV=production bundle exec rails assets:clean && \
    RAILS_ENV=production bundle exec rails assets:precompile && \
    rm -rf node_modules && \
    apk del node-build-dependencies

### Define app version
ARG COMMIT_HASH=untagged
ENV COMMIT_HASH=${COMMIT_HASH}

# Open port 80 for HTTP access
EXPOSE 80
# Open port 443 and 8443 for HTTPS access
EXPOSE 443 8443

ENTRYPOINT [ "/kodoverdikto/scripts/entrypoints/web-create.sh" ]
CMD [ "/kodoverdikto/scripts/entrypoints/web-start.sh" ]
