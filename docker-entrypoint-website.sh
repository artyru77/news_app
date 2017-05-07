#!/bin/sh
set -e

CONTAINER_TIMEZONE=Europe/Moscow
echo ${CONTAINER_TIMEZONE} > /etc/timezone && dpkg-reconfigure -f noninteractive tzdata
echo "Container timezone set to: $CONTAINER_TIMEZONE"

ntpd -gq
service ntp start

BACKGROUND=y rails news:run_observer &>>"$(pwd)/log/news_observer.log"

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

puma -C config/puma.rb
