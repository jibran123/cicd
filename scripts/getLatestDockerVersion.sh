#!/bin/sh
wget -q https://registry.hub.docker.com/v1/repositories/"$1"/"$2"/tags -O - | sed -e 's/[][]//g' -e 's/"//g' -e 's/ //g' | tr '}' '\n' | awk -F: '{print $3}' | tail -n 1