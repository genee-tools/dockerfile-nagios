#!/bin/sh

service apache2 start
service nagios start

while true; do
	sleep 1
done
