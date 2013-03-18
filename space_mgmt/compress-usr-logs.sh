#!/bin/bash
#cleanup script for user logs
#
#
#find /logr/* -name "*-*.zip" -type f -size -1 -exec rm {} \;

#logcat Files
# move files older then 30 days to archives
find /logr -name "logcat-*.zip" -type f -mtime +30 -exec mv {} /logr/archives \;
#move fiels older then 31 days to seperate folders
find /logr/archives -name "logcat-*.zip" -type f -mtime +31 -exec mv {} /logr/archives/logcat \;


#logcat Files

#move files older then 30 days to archives
find /logr -name "netlog-*.zip" -type f -mtime +30 -exec mv {} /logr/archives \;
#move files older then 31 days to seperate folder
find /logr/archives -name "netlog-*.zip" -type f -mtime +31 -exec mv {} /logr/archives/netlog \;


# Delete files older then 90 days
find /logr/archives/* "*-*.zip" -type f -mtime +90 -exec rm {} \;

