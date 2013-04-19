#! /bin/bash
####### Begin Check######

###Check Hobbit Location
if [ -d "/etc/hobbit" ]; then 
	basepath=`cat /etc/hobbit/hobbitclient.cfg |grep 'HOBBITCLIENTHOME='|cut -d"\"" -f2`
	hobxy="hobbit"
elif [ -d "/etc/xymon-client" ]; then
	basepath=`cat /etc/xymon-client/xymonclient.cfg |grep 'XYMONCLIENTHOME='|cut -d"\"" -f2`
	hobxy="xymon"
elif [ -f "/etc/default/xymon-client" ]; then 
	basepath="/usr/lib/xymon/client"
	hobxy="xymon"
else 
	echo 2>&1 "ERROR: Hobbit/Xymon not installed/or found"
	exit 1
fi
echo "$basepath"
###Check Redhat or Ubuntu and Which version of Ubuntu
if [ -f /etc/redhat-release ]; then
	os="redhat"
elif [ "$(grep DISTRIB_RELEASE= /etc/lsb-release| cut -d"=" -f2)" = "12.04" ]; then
	os="U12.04"
else
	os="Ubuntu"
fi

if [ -f /etc/redhat-release ]; then 
	manager=yum
else
	manager=apt-get
fi

### Check for RAID controller and which type
if [ `lspci |grep -qi 'RAID'` ]; then
	raid= `lspci |grep -i 'RAID'`
else 
	echo 2>&1 'No raid controller found'
	exit 1
fi

if [ `$raid | grep -qi 'lsi'` ]; then
	raidtype="hard"
elif [ $raid | grep -fqi 'Intel' ]; then
	raidtype="soft"
else
	echo 2>&1 "Error: Issue defineing RAID"
	exit 1
fi
#### Begin Deployment

$manager update 

##### Copy CFG files to Client paths
echo "copying files to Hobbit/Xymon paths"
if [ $raidtype = "hard" ]; then
	cp check_sm_lsi* "$basepath/ext/"
elif [ $raidtype = "soft" ]; then
	cp check_sm_soft* "$basepath/ext/"


if [ $hobxy = "xymon" ]; then
cat sm_xy_hardware.cfg >> "$basepath/etc/clientlaunch.cfg"
else
cat sm_hob_hardware.cfg >> "$basepath/etc/clientlaunch.cfg"
fi
###### Apply needed permissions for Xymon and hobbit
if [ ! `grep -Fq 'xymon' /etc/sudoers` ]; then  
cat <<EOF >> /etc/sudoers
xymon ALL = NOPASSWD: /sbin/hplog
xymon ALL = NOPASSWD: /usr/sbin/hpacucli
xymon ALL = NOPASSWD: /sbin/hpasmcli
hobbit ALL = NOPASSWD: /sbin/hplog
hobbit ALL = NOPASSWD: /usr/sbin/hpacucli
hobbit ALL = NOPASSWD: /sbin/hpasmcli

Defaults:xymon !requiretty
Defaults:hobbit !requiretty
EOF

fi

