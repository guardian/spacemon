#!/bin/sh

if [ "$SLEEP_TIME" == "" ]; then
  SLEEP_TIME=60
fi

while `/bin/true`; do
  ruby /usr/local/bin/spacemon.rb --elasticsearch $ELASTICSEARCH_HOST --filter $FILTER
  if [ "$?" != "0" ]; then
    echo Command failed, exiting
    exit $?
  fi
  sleep $SLEEP_TIME
done
