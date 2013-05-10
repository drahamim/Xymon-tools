#!/bin/bash

function isnum() {
a=$1
[ ! -z "${a##[0-9]*}" ] && a=U
[ -z "$a" ] && a=U
echo $a
}

function ucheck() {
if [[ "$1"   =~ U ]]
then
 echo "U"
else
 echo ""
fi
}

id='th'
cd `dirname $0`
host=`hostname`
port=7199
count=1
MSG=""

while read line
do
 class=`echo $line|awk -F# '{print $1}'`
 attribute=`echo $line|awk -F# '{print $2}'`
 echo "class is $class and attr is $attribute"
 javacmd="java  -classpath nagtomcat.jar com.groundworkopensource.tomcat.nagios.plugin.Shell  -s $host -p $port -m $class -a $attribute"
 v$count=`javacmd`|awk -F= '{print $3}'`
 v$count=`isnum v$count`
 count=`expr $count + 1`
 MSG=$MSG+$class+' '+$attribute+'\n'

done < ${id}.yml.tab

COLUMN=cass_heapsize
COLOUR=green
[ "`ucheck "${v1}${v2}${v3}${v4}"`" = "U" ] && COLOUR=yellow

MACHINE=`echo $host | tr '.' ','`
$BB $BBDISP "status $MACHINE.$COLUMN $COLOUR `date`

$MSG

"

