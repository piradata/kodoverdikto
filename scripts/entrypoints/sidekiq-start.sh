#!/bin/sh

if [ -f "$PIDFILE-sidekiq" ]; then
  rm -f "$PIDFILE-sidekiq"
fi

echo "... Starting Sidekiq Server ..."
bundle exec sidekiq -q default -q mailers
