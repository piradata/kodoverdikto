#!/bin/sh

cd $APP_ROOT/mainapp

if [ -f $PIDFILE ]; then
  rm -f $PIDFILE
fi

echo "... Starting Rails Server ..."
bundle exec rails server -p $WEBSITES_PORT -b 0.0.0.0 -P $PIDFILE
