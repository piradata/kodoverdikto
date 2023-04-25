#!/bin/sh

# cd $APP_ROOT/kodoverdikto

if [ -f "$PIDFILE-web" ]; then
rm -f "$PIDFILE-web"
fi

echo "... Starting Rails Server ..."
bundle exec rails server -p $WEBSITES_PORT -b 0.0.0.0 -P "$PIDFILE-web"
