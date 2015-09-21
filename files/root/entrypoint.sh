#!/bin/sh

service apache2 start
service nagios start
chown -R nagios:nagios /usr/local/nagios

while true; do
	sleep 1000
done
