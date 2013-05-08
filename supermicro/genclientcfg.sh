#!/bin/bash

function usage {
   echo "Usage:" 
   echo "$(basename $0) --xymon ipmi"
   echo "$(basename $0) --xymon lsi"
   echo "$(basename $0) --xymon soft"
   echo "$(basename $0) --hobbit ipmi"
   echo "$(basename $0) --hobbit lsi"
   echo "$(basename $0) --hobbit soft"
   echo "$(basename $0) --tty"
   echo "$(basename $0) --help"
   echo "Options:"
   echo "--xymon, -xymon"
   echo "--hobbit, -hobbit"
   echo "--tty, -tty"
   echo "--help, -help -H, -h"
 
}

function hobxyIPMIsudo {
if [ ! `grep -Fq "ipmitool" /etc/sudoers` ]; then
   cat <<EOF >> hobxyipmisudo
xymon ALL = NOPASSWD: /usr/bin/ipmitool
hobbit ALL = NOPASSWD: /usr/bin/ipmitool
EOF
fi
}

function ttydisable {
if [ ! `grep -Fq "Defaults:xymon" /etc/sudoers` ]; then
   cat <<EOF >> ttydisable
Defaults:xymon !requiretty
Defaults:hobbit !requiretty
EOF
else 
	echo "tty failed"
	exit 1
fi
}

function megaclisudo {
if [ ! `grep -Fq "MegaCli64" /etc/sudoers` ]; then
echo "xymon  ALL=NOPASSWD:  /opt/MegaRAID/MegaCli/MegaCli64" #>> megacli
echo "hobbit ALL=NOPASSWD:  /opt/MegaRAID/MegaCli/MegaCli64" #>> megacli
fi
}

function xyRAIDsoft {


[sm_raid]
        ENVFILE $XYMONCLIENTHOME/etc/xymonclient.cfg
        CMD $XYMONCLIENTHOME/ext/check_sm_raid.sh
        LOGFILE $XYMONCLIENTHOME/logs/check_sm_raid.log
        INTERVAL 5m

}

function xyRAIDhard {

}

function hobRAIDsoft {

}

function hobRAIDhard {

}
###### Functions for HP servers
function HPhobRAID {

}

function HPxyRAID {

}

function HPhobMON {

}

function HPxyMON {

}

function hpSUDO {

}




case $1 in 
	"-xymon") 
		monitor=$2; client="xymon"
		;;
	"-hobbit") 
		monitor=$2; client="hobbit"
		;;
	"-h"|"--help"|"-H"|"-help")
		usage
		;;
	"--tty"|"-tty") 
		ttydisable
		;;
	*)
		usage
		exit 1
		;;	
	esac
