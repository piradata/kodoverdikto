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
fi

if [ -f $PIDFILE ]; then
  rm -f $PIDFILE
fi

echo "... Starting Rails Server ..."
# if [ "$RDEBUG" == "true" ]
# then
#   echo "### DEBUG MODE ###"
#   rdbg --command --open --stop-at-load -- bundle exec ruby /kodeverdikto/bin/rails server -p $WEBSITES_PORT -b 0.0.0.0 -P $PIDFILE
# else
#   bundle exec rails server -p $WEBSITES_PORT -b 0.0.0.0 -P $PIDFILE
# fi

bundle exec rails server -p $WEBSITES_PORT -b 0.0.0.0 -P $PIDFILE