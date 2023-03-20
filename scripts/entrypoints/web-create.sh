#!/bin/sh

# cd $APP_ROOT/kodeverdikto

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
  echo "Gems OK"

  # solargraph bundle

  # Check if gems already installed
  GEMS_INSTALLED=$(bundle check)
  IS_INSTALLED="The Gemfile's dependencies are satisfied"
  SLEEP_TIME=5
  MAX_SLEEP_TIME=60
  SLEEP_STEP=5
  while [[ "$GEMS_INSTALLED" != "$IS_INSTALLED" ]]
  do
    GEMS_INSTALLED=$(bundle check)
    echo "Awaiting gems are installed...";

    sleep $SLEEP_TIME;
    if [ $SLEEP_TIME -lt $MAX_SLEEP_TIME ]
    then
      SLEEP_TIME=$(($SLEEP_TIME + $SLEEP_STEP))
    fi
  done

  # bin/yarn
  # echo "Yarn OK"

  rails db:create
  echo "Database OK"
else
  echo "Using bundler under production mode"
  # Start ssh server on container
  ssh-keygen -A
  /usr/sbin/sshd
  # Run update of process
  rails r lib/update_processes.rb
  # Migrate database
  rails db:migrate
fi

exec "$@"
