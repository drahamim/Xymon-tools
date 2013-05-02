#!/bin/bash
function xyIPMI {
cat <<EOF >> tmpfile1
xymon ALL = NOPASSWD: /usr/bin/ipmitool
hobbit ALL = NOPASSWD: /usr/bin/ipmitool
EOF
exit
}

while [ $# -gt 0 ] 
do 
	case $1 in 
		"-xymon") monitor=$2 
		xyIPMI
		;;
	esac
done
