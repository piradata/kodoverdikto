ARG RUBY_VERSION=3.1.2-alpine3.16
FROM ruby:${RUBY_VERSION}

### Define ENV Variables
ENV APP_ROOT /kodeverdikto
ENV PATH $APP_ROOT/bin:$PATH

# Define container workdir location
WORKDIR $APP_ROOT

# Add ssh to Devcontainer
RUN apk add --update --no-cache openssh

### Update an install packages dependencies
# tzdata (https://tips.tutorialhorizon.com/2017/08/29/tzinfodatasourcenotfound-when-using-alpine-with-docker/)
# shared-mime-info -- Dependency from gem 'mimemagic' (https://github.com/mimemagicrb/mimemagic#dependencies)
# less -- Necessary for 'pry' on bigger objects (https://github.com/pry/pry/issues/1248#issuecomment-767676627)
RUN apk add --update --no-cache \
    freetds-dev \
    git \
    gnupg \
    less \
    libaio \
    libpq-dev \
    postgresql14-client \
    shared-mime-info \
    sqlite-dev \
    tzdata

# Some gems need build, example 'bcrypt', 'json', 'jaro_winkler' --> (dependency of development gem 'solargraph')
RUN apk add --no-cache make g++ build-base

### Configure bundler
ENV BUNDLE_PATH /usr/local/bundle
ENV GEM_PATH $BUNDLE_PATH
ENV BUNDLE_BIN $BUNDLE_PATH
ENV PATH $BUNDLE_PATH/bin:$BUNDLE_PATH/gems/bin:$PATH
ARG BUNDLER_VERSION=2.3.20
# RUN gem update --system && \
RUN gem install bundler -v $BUNDLER_VERSION && \
    bundle config set deployment 'false' && \
    bundle config set jobs 20
### saddly the bundle gems are comflicting with default gems :(
# https://stackoverflow.com/questions/70694563/bundle-conflict-with-ruby-default-gems
# RUN rm -rf /usr/local/lib/ruby/gems/${RUBY_VERSION}/gems/debug-*/
# RUN rm -rf /usr/local/bundle/gems/

# [Optional] Set the default user. Omit if you want to keep the default as root.
# https://aka.ms/vscode-remote/containers/non-root#_change-the-uidgid-of-an-existing-container-user
ARG USERNAME=root
ARG USER_UID=1000
ARG USER_GID=$USER_UID
RUN apk add --update --no-cache shadow
RUN if [[ "$USERNAME" != "root" ]] ; then \
    groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME ; \
    else echo "Running with $USERNAME user" ; \
    fi
USER $USERNAME

### Define app version
ARG APP_VERSION=untagged
ENV APP_VERSION=${APP_VERSION}

# Expose ports
EXPOSE 80

# Start Process
ENTRYPOINT [ "/kodeverdikto/scripts/entrypoints/web-create.sh" ]
CMD [ "/kodeverdikto/scripts/entrypoints/web-start.sh" ]
