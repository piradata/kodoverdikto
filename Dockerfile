ARG RUBY_VERSION=3.1.2-alpine3.16
FROM ruby:${RUBY_VERSION}

ARG APP_VERSION=untagged
ARG BUNDLER_VERSION=2.3.17

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

# Add ssh to Devcontainer
RUN apk add --update --no-cache openssh

### Define ENV Variables
ENV APP_VERSION=${APP_VERSION}
ENV APP_ROOT /kodeverdikto
ENV BUNDLE_PATH /usr/local/bundle
ENV PATH $APP_ROOT/bin:$PATH

# tzdata (https://tips.tutorialhorizon.com/2017/08/29/tzinfodatasourcenotfound-when-using-alpine-with-docker/)
# shared-mime-info -- Dependency from gem 'mimemagic' (https://github.com/mimemagicrb/mimemagic#dependencies)
# less -- Necessary for 'pry' on bigger objects (https://github.com/pry/pry/issues/1248#issuecomment-767676627)

### Update an install packages dependencies
RUN apk add --update --no-cache \
    freetds-dev \
    git \
    gnupg \
    less \
    libaio \
    libpq-dev \
    npm \
    postgresql14-client \
    shared-mime-info \
    sqlite-dev \
    tzdata \
    && npm install --global yarn

# Some gems need build, example 'bcrypt', 'json', 'jaro_winkler' --> (dependency of development gem 'solargraph')
RUN apk add --no-cache make g++ build-base

### Configure bundler
RUN gem update --system && \
    gem install bundler -v $BUNDLER_VERSION && \
    bundle config set deployment 'false' && \
    bundle config set jobs 20

# [Optional] Set the default user. Omit if you want to keep the default as root.
USER $USERNAME

# Define container workdir location
WORKDIR $APP_ROOT

EXPOSE 80

ENTRYPOINT [ "/kodeverdikto/entrypoints/web-create.sh" ]
CMD [ "/kodeverdikto/entrypoints/web-start.sh" ]
