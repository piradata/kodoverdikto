ARG RUBY_VERSION=3.1.3-alpine3.16
FROM ruby:${RUBY_VERSION}

### Define ENV Variables
ENV APP_ROOT /kodeverdikto

ARG BUNDLER_VERSION=2.4.1
ENV BUNDLE_PATH /usr/local/bundle
# ENV GEM_PATH $BUNDLE_PATH
# ENV BUNDLE_BIN $BUNDLE_PATH
# ENV PATH $BUNDLE_PATH/bin:$BUNDLE_PATH/gems/bin:$PATH

# Install system dependencies required both at runtime and build time
# tzdata (https://tips.tutorialhorizon.com/2017/08/29/tzinfodatasourcenotfound-when-using-alpine-with-docker/)
# shared-mime-info -- Dependency from gem 'mimemagic' (https://github.com/mimemagicrb/mimemagic#dependencies)
RUN apk add --update --no-cache --virtual run-dependencies \
    freetds-dev \
    git \
    gnupg \
    libaio \
    libpq-dev \
    postgresql14-client \
    shared-mime-info \
    sqlite-dev \
    tzdata

# Define container workdir location
WORKDIR $APP_ROOT

### Copy gemfiles
COPY Gemfile* ./

### Configure bundler
# Install system dependencies required to build some Ruby gems
# Some gems need build, example 'bcrypt', 'json', 'jaro_winkler' --> (dependency of development gem 'solargraph')
RUN apk add --update --no-cache --virtual build-dependencies make g++ build-base && \
    gem update --system && \
    gem install bundler -v $BUNDLER_VERSION --no-document && \
    bundle config set deployment 'true' && \
    bundle config set without 'development test' && \
    bundle config set jobs 20 && \
    bundle check || bundle install && \
    apk del build-dependencies

ARG APP_VERSION=untagged
ENV APP_VERSION=${APP_VERSION}

# Add code to container
COPY ./ $APP_ROOT

### Copy JS/React packages
# COPY package.json yarn.lock ./

# Run assets pipeline
# RUN apk add --update --no-cache --virtual node-build-dependencies nodejs yarn && \
#     yarn install --frozen-lockfile --check-files --silent --production && \
#     yarn cache clean && \
RUN apk add --update --no-cache --virtual node-build-dependencies nodejs && \
    RAILS_ENV=production bundle exec rails assets:clean && \
    RAILS_ENV=production bundle exec rails assets:precompile
    # RAILS_ENV=production bundle exec rails webpacker:compile && \
    # rm -rf node_modules && \
    # apk del node-build-dependencies


### Configure SSH access via azure
# Install OpenSSH and set the password for root to "Docker!". In this example, "apk add" is the install instruction for an Alpine Linux-based image.
RUN apk add --update --no-cache openssh-server && \
    echo "root:Docker!" | chpasswd && \
    mkdir /var/run/sshd

# Copy the sshd_config file to the /etc/ssh/ directory
COPY resources/ssh/sshd_config /etc/ssh/

# Open port 2222 for SSH access
EXPOSE 2222

# Open port 80 for HTTP access
EXPOSE 80

ENTRYPOINT [ "/app/entrypoints/web-create.sh" ]
CMD [ "/app/entrypoints/web-start.sh" ]
