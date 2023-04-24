#!/bin/sh

cd $APP_ROOT

# if [ "$RAILS_ENV" == "development" ]
# then
#   # Check if gems already installed
#   GEMS_INSTALLED=$(bundle check)
#   IS_INSTALLED="The Gemfile's dependencies are satisfied"
#   SLEEP_TIME=5
#   MAX_SLEEP_TIME=60
#   SLEEP_STEP=5
#   while [[ "$GEMS_INSTALLED" != "$IS_INSTALLED" ]]
#   do
#     GEMS_INSTALLED=$(bundle check)
#     echo "Awaiting gems are installed...";

#     sleep $SLEEP_TIME;
#     if [ $SLEEP_TIME -lt $MAX_SLEEP_TIME ]
#     then
#       SLEEP_TIME=$(($SLEEP_TIME + $SLEEP_STEP))
#     fi
#   done
# fi

if [ -f $PIDFILE ]; then
  rm -f $PIDFILE
fi

echo "... Starting Sidekiq Server ..."
bundle exec sidekiq -q default -q mailers -q import_model
