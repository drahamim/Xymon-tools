#! /bin/bash
####### Begin Check and ENV configuration for Deployment######

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
echo "${os} with ${manager}"
### Check for RAID controller and which type
if [ 'lspci |grep -qi RAID' ]; then
	raid="`lspci |grep -i 'RAID'`"
else 
	echo 2>&1 'No raid controller found'
	exit 1
fi

if [ '$raid | grep -qi 'MegaRAID'' ]; then
	raidtype="hard"
elif [ $raid | grep -fqi 'Intel' ]; then
	raidtype="soft"
else
	echo 2>&1 "Error: Issue defineing RAID"
	exit 1
fi

echo " ${raid} and ${raidtype}"

### Check fro IPMI utilitiy
if [ -f /usr/bin/ipmitool ]; then 
	ipmit="yes"
else
	ipmit="no"
fi

echo "${ipmit}"
####### END CHECK SECTION######

#### Begin Deployment

$manager update 

### If the OS is redhat and has an LSI controller install MPT-status
if [[ $os = "redhat" && $raidtype = "hard" ]]; then 
	rpm -i MegaCli*
fi

### If ipmitool is not installed install it
if [[ $ipmit = "no" ]]; then 
	$manager install ipmitool
fi

###### Apply needed permissions for Xymon and hobbit
if [ ! `grep -Fq 'xymon' /etc/sudoers` ]; then
cat <<EOF >> /etc/sudoers
xymon  ALL = NOPASSWD: /opt/MegaRAID/MegaCli/MegaCli64
hobbit ALL = NOPASSWD: /opt/MegaRAID/MegaCli/MegaCli64
xymon  ALL = NOPASSWD: /usr/bin/ipmitool
hobbit ALL = NOPASSWD: /usr/bin/ipmitool
xymon  ALL = NOPASSWD: /sbin/dmraid
hobbit ALL = NOPASSWD: /sbin/dmraid

Defaults:xymon !requiretty
Defaults:hobbit !requiretty
EOF

fi



##### Copy CFG files to Monitoring Client paths
echo "copying files to Hobbit/Xymon paths"
if [ $raidtype = "hard" ]; then
	cat check_sm_lsi* >> "$basepath/ext/check_sm_raid.sh"
elif [ $raidtype = "soft" ]; then
	cat check_sm_soft* >> "$basepath/ext/check_sm_raid.sh"
fi

chmod +x $basepath/ext/check_sm_raid.sh

if [[ $hobxy = "xymon" ]]; then
	cat sm_xy_hardware.cfg >> "$basepath/etc/clientlaunch.cfg"
else
	cat sm_hob_hardware.cfg >> "$basepath/etc/clientlaunch.cfg"
fi

if [ "$hobxy = 'xymon' && $ipmilaunch = 'no'" ]; then
	cat sm_xy_ipmi.cfg >> "$basepath/etc/clientlaunch.cfg"
else
	cat sm_hob_ipmi.cfg >> "$basepath/etc/clientlaunch.cfg"
fi
