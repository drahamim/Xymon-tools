#!/bin/sh
#
# Compress the CAVA logfiles
#
find /var/logs/hadoop-* -name "*.log-????-??-??" -print -exec gzip  {} \;
find /var/logs/hadoop-* -name "*.log-????-??-??-??.gz" -mtime +90 -print -exec rm {} \;
