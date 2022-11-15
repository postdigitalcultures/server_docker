#!/bin/bash
# @cron: Set to run on root crontab at 1200 everyday
# 00 12 * * * /home/cpc_admin/docker/ssl_renew.sh >> /var/log/cron.log 2>&1

COMPOSE="/usr/local/bin/docker-compose --ansi never"
DOCKER="/usr/bin/docker"

cd /home/cpc_admin/docker/
$COMPOSE run certbot renew && $COMPOSE kill -s SIGHUP webserver
$DOCKER system prune -af
