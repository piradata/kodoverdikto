#!/bin/sh

cd $APP_ROOT

if [ "$RAILS_ENV" == "development" ]
then
  # Check if postgres already start
  IS_READY='accepting connections'
  PG_READY=$(pg_isready -h $DB_HOST -U postgres 2>&1 >/dev/null && echo $IS_READY)
  SLEEP_TIME=5
  MAX_SLEEP_TIME=60
  SLEEP_STEP=5
  while [[ "$PG_READY" != "$IS_READY" ]]
  do
    PG_READY=$(pg_isready -h $DB_HOST -U postgres 2>&1 >/dev/null && echo $IS_READY)
    echo "Awaiting postgres start...";
    sleep $SLEEP_TIME;
    if [ $SLEEP_TIME -lt $MAX_SLEEP_TIME ]
    then
      SLEEP_TIME=$(($SLEEP_TIME + $SLEEP_STEP))
    fi
  done
fi

if [ "$RAILS_ENV" == "development" ]
then
  echo "Using bundler under development mode"
  # Install gems for development
  bundle check || bundle install
else
  echo "Using bundler under production mode"
  # Start ssh server on container
  # ssh-keygen -A
  # /usr/sbin/sshd

  # Migrate database
  bundle exec rails db:migrate
fi

exec "$@"
