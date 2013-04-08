#! /bin/bash
####### Begin Check######

###Check Hobbit Location
if [ -d "/etc/hobbit" ]; then 
	basepath='cat /etc/hobbit/hobbitclient.cfg |grep 'HOBBITCLIENTHOME='|cut -d"\"" -f2'
elif [ -d "/etc/xymon-client" ]; then
	basepath='cat /etc/xymon-client/xymonclient.cfg |grep 'XYMONCLIENTHOME='|cut -d"\"" -f2'
elif [ -f "/etc/default/xymon-client" ]; then 
	basepath='~xymon/client'
else 
	echo >&2 "ERROR: Hobbit/Xymon not installed/or found"
	exit 1
fi

###Check Redhat or Ubuntu and Which version of Ubuntu
if [ -f /etc/redhat-release ]; then
	product="SPP"
elif [ "$(grep DISTRIB_RELEASE= /etc/lsb-release| cut -d"=" -f2)" = "12.04" ]; then
	product="MCP"
else
	product="PSP"
fi

if [-f "/etc/redhat-release"]; then 
	manager=yum
else
	manager=apt-get
fi
#### Begin Deployment

./bootstrap.sh $product

$manager install hp-health

cp check_hp_raid.sh check_hp.sh  $basepath/ext/
cat hp_hardware.cfg >> $basepath/etc/clientlaunch.cfg


