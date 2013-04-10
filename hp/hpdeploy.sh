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
	basepath=`/usr/lib/xymon/client`
	hobxy="xymon"
else 
	echo >&2 "ERROR: Hobbit/Xymon not installed/or found"
	exit 1
fi
echo "$basepath"
###Check Redhat or Ubuntu and Which version of Ubuntu
if [ -f /etc/redhat-release ]; then
	product="SPP"
elif [ "$(grep DISTRIB_RELEASE= /etc/lsb-release| cut -d"=" -f2)" = "12.04" ]; then
	product="MCP"
else
	product="PSP"
fi

if [ -f /etc/redhat-release ]; then 
	manager=yum
else
	manager=apt-get
fi
#### Begin Deployment

./bootstrap.sh $product
$manager update
$manager install hp-health


echo "copying files to Hobbit/Xymon paths"
cp check_hp* $basepath/ext/
if [ $hobxy = "xymon" ]; then
cat hp_xy_hardware.cfg >> $basepath/etc/clientlaunch.cfg
else
cat hp_hob_hardware.cfg >> $basepath/etc/clientlaunch.cfg
fi

if [ ! `grep -Fxq 'xymon' /etc/sudoers` ]; then  
cat <<EOF >> /etc/sudoers
xymon ALL = NOPASSWD: /sbin/hplog
xymon ALL = NOPASSWD: /usr/sbin/hpacucli
xymon ALL = NOPASSWD: /sbin/hpasmcli
hobbit ALL = NOPASSWD: /sbin/hplog
hobbit ALL = NOPASSWD: /usr/sbin/hpacucli
hobbit ALL = NOPASSWD: /sbin/hpasmcli
EOF

fi

if grep -Fxq requiretty /etc/sudoers; then
	sed '/\ \ requiretty/^/#/' /etc/sudoers
fi 

