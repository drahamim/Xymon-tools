#!/bin/bash

###### NOTES SECTION
#function hobxyIPMIsudo ## deploy IPMI sudo priv
#function ttydisable    ## disable tty for mon
#function megaclisudo  	## megacli sudo priv
#function HPsudo        ## hp mon tools sudo priv
#function xyRAIDcfg     ## xymon RAID mon client launch cfg
#function hobRAIDcfg    ## hobbit RAID mon client launch cfg
#function HPhobRAIDcfg  ## hp hob RAID mon client launch cfg
#function HPxyRAIDcfg   ## HP xy RAID mon client launch cfg
#function HPhobHWcfg    ## HP hob HW mon client launch cfg
#function HPxyHWcfg     ## hp xy HW mon client launch cfg
#function softRAIDsh    ## software RIAD mon script deploy
#function hardRAIDsh    ## hardware RAID mon script deploy
#function IPMIsh       	## IPMI mon script deploy
#function hpRAIDsh      ## hp RAID mon script deploy
#function hpHWsh        ## HP hardware mon script deploy
#function HPtools      	## hp mon tools installation
#function hardRAIDtools	## software RAID mon tools installation REDhat
                                                            
function usage {
   echo "Usage:"
   echo "$(basename $0) --xymon ipmi"
   echo "$(basename $0) --xymon lsi"
   echo "$(basename $0) --xymon soft"
   echo "$(basename $0) --hobbit ipmi"
   echo "$(basename $0) --hobbit lsi"
   echo "$(basename $0) --hobbit soft"
   echo "$(basename $0) --hp hobbit"
   echo "$(basename $0) --hp xymon"
   echo "$(basename $0) --tty"
   echo "$(basename $0) --help"
   echo "Options:"
   echo "--xymon, -xymon"
   echo "--hobbit, -hobbit"
   echo "--hp, -hp"
   echo "--tty, -tty"
   echo "--help, -help -H, -h"
}

### Environment pre-flight checks
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
        echo >&2 "ERROR: Hobbit/Xymon not installed/or found"
        exit 1
fi

if [ -f /etc/redhat-release ]; then
        manager=yum
	os=redhat
else
        manager=apt-get
	os=ubuntu
fi

###### Sudo Entries Section
function hobxyIPMIsudo {
if [ ! `grep -Fq "ipmitool" /etc/sudoers` ]; then
	echo "Sudo for IPMI"
	 cat <<EOF >> hobxyipmisudo
xymon ALL = NOPASSWD: /usr/bin/ipmitool
hobbit ALL = NOPASSWD: /usr/bin/ipmitool
EOF
fi
}

function ttydisable {
if [ ! `grep -Fq "Defaults:xymon" /etc/sudoers` ]; then
	echo "sudo tty for monitoring"
cat <<EOF >> ttydisable
Defaults:xymon !requiretty
Defaults:hobbit !requiretty
EOF
else 
	echo "tty disable failed"
	exit 1
fi
}

function megaclisudo {
if [ ! `grep -Fq "MegaCli64" /etc/sudoers` ]; then
	ehco "sudo for MegaCli Monitor"
echo "xymon  ALL=NOPASSWD:  /opt/MegaRAID/MegaCli/MegaCli64" #>> megacli
echo "hobbit ALL=NOPASSWD:  /opt/MegaRAID/MegaCli/MegaCli64" #>> megacli
fi
}

function HPsudo {
if [ ! `grep -Fq 'hp' /etc/sudoers` ]; then
	echo "HP sudo"
cat <<EOF >> /etc/sudoers
xymon ALL = NOPASSWD: /sbin/hplog
xymon ALL = NOPASSWD: /usr/sbin/hpacucli
xymon ALL = NOPASSWD: /sbin/hpasmcli
hobbit ALL = NOPASSWD: /sbin/hplog
hobbit ALL = NOPASSWD: /usr/sbin/hpacucli
hobbit ALL = NOPASSWD: /sbin/hpasmcli
EOF
fi
}

#### ClientLaunch Config Functions
function xyRAIDcfg {
if [ ! `grep -fq "sm_raid" $basepath/etc/clientlaunch.cfg` ]; then
	echo "xymon Raid CFG"
cat << EOF >> $basepath/etc/clientlaunch.cfg
[sm_raid]
        ENVFILE $XYMONCLIENTHOME/etc/xymonclient.cfg
        CMD $XYMONCLIENTHOME/ext/check_sm_raid.sh
        LOGFILE $XYMONCLIENTHOME/logs/check_sm_raid.log
        INTERVAL 5m
EOF
fi
}

function hobRAIDcfg {
if [ ! `grep -fq "sm_raid" $basepath/etc/clientlaunch.cfg` ]; then
	echo "hobbit Raid CFG"
cat << EOF >> $basepath/etc/clientlaunch.cfg
[sm_raid]
        ENVFILE $HOBBITCLIENTHOME/etc/hobbitclient.cfg
        CMD $HOBBITCLIENTHOME/ext/check_sm_raid.sh
        LOGFILE $HOBBITCLIENTHOME/logs/check_sm_raid.log
        INTERVAL 5m
EOF
fi
}

function HPhobRAIDcfg {
if [ ! `grep -fq "hp_raid" $basepath/etc/clientlaunch.cfg` ]; then
	echo "HP hobbit RAID config"
cat << EOF >> $basepath/etc/clientlaunch.cfg
[hp_raid]
        ENVFILE $HOBBITCLIENTHOME/etc/hobbitclient.cfg
        CMD $HOBBITCLIENTHOME/ext/check_hp_raid.sh
        LOGFILE $HOBBITCLIENT/logs/hp_raid.log
        INTERVAL 5m
EOF
fi
}

function HPxyRAIDcfg {
if [ ! `grep -fq "hp_raid" $basepath/etc/clientlaunch.cfg` ]; then
	echo "HP xymon Raid cfg"
cat << EOF >> $basepath/etc/clientlaunch.cfg
[hp_raid]
        ENVFILE $XYMONCLIENTHOME/etc/xymonclient.cfg
        CMD $XYMONCLIENTHOME/ext/check_hp_raid.sh
        LOGFILE $XYMONCLIENTHOME/logs/hp_raid.log
        INTERVAL 5m
EOF
fi
}

function HPhobHWcfg {
if [ ! `grep -fq "hp_hardware" $basepath/etc/clientlaunch.cfg` ]; then
	echo "HP hob health cfg"
cat << EOF >> $basepath/etc/clientlaunch.cfg
[hp_hardware]
        ENVFILE $HOBBITCLIENTHOME/etc/hobbitclient.cfg
        CMD $HOBBITCLIENTHOME/ext/check_hp.sh
        LOGFILE $HOBBITCLIENTHOME/logs/hp_hardware.log
        INTERVAL 5m
EOF
fi
}

function HPxyHWcfg {
if [ ! `grep -fq "hp_hardware" $basepath/etc/clientlaunch.cfg` ]; then
	echo "HP xymon health CFG"
cat << EOF >> $basepath/etc/clientlaunch.cfg
[hp_hardware]
        ENVFILE $XYMONCLIENTHOME/etc/xymonclient.cfg
        CMD $XYMONCLIENTHOME/ext/check_hp.sh
        LOGFILE $XYMONCLIENTHOME/logs/hp_hardware.log
        INTERVAL 5m
EOF
fi
}

function hobIPMIcfg {
if [ ! `grep -fq "ipmi" $basepath/tc/clientlaunch.cfg` ]; then
	echo "hobbit ipmi CFG"
cat << EOF >> $basepath/etc/clientlaunch.cfg
[ipmi]
        #DISABLED
        ENVFILE $HOBBITCLIENTHOME/etc/hobbitclient.cfg
        CMD $HOBBITCLIENTHOME/ext/ipmi
        LOGFILE $HOBBITCLIENTHOME/logs/hobbitclient.log
	INTERVAL 5m
EOF
fi
}

function xyIPMIcfg {
if [ ! `grep -fq "ipmi" $basepath/etc/clientlaunch.cfg` ]; then
	echo "xymon ipmi cfg"
cat << EOF >> $basepath/etc/clientlaunch.cfg
[ipmi]
        #DISABLED
        ENVFILE $XYMONCLIENTHOME/etc/xymonclient.cfg
        CMD $XYMONCLIENTHOME/ext/ipmi
        LOGFILE $XYMONCLIENTHOME/logs/xymonclient.log
        INTERVAL 5m
EOF
fi
}

###### Monitoring Script Deployment
function softRAIDsh {
cp check_sm_soft.sh "$basepath/ext/"
}

function hardRAIDsh {
cp check_sm_lsi.sh "$basepath/ext/"
}

function IPMIsh {
cp ipmi "$basepath/ext/"
}

function hpRAIDsh {
cp check_hp_raid.sh "$basepath/ext/"
}

function hpHWsh {
cp check_hp.sh "$basepath/ext/"
}
###### Tool installatin section
function HPtools {
if [ -f /etc/redhat-release ]; then
        product="SPP"
elif [ "$(grep DISTRIB_RELEASE= /etc/lsb-release| cut -d"=" -f2)" = "12.04" ]; then
        product="MCP"
else
        product="PSP"
fi
$manager remove hp-health -y
./bootstrap.sh $product
$manager update
$manager install hp-health -y
$manager install hpacucli -y
}

function hardRAIDtools {
if [ "$os = 'redhat' && $raidtype = 'hard'" ]; then
        rpm -i mpt-status*
fi
}

function ipmitools {
if [ ! -e /usr/bin/ipmitool ]; then
	$manager update
	$manager install ipmitool -y
fi
}

case $1 in
	"-xymon"|"--xymon") 
		monitor=$2; client="xymon"
		xymon
		;;
	"-hobbit"|"--hobbit") 
		monitor=$2; client="hobbit"
		hobbit
		;;
	"-h"|"--help"|"-H"|"-help")
		usage
		;;
	"--hp"|"-hp")
		system="hp" client=$2
		hp
		;;
	"--tty"|"-tty") 
		ttydisable
		;;
	*)
		usage
		exit 1
		;;	
	esac

function hp {
if [ `$system="hp" && $client="hobbit"` ]; then
	HPtools
	HPsudo
	HPhobHWcfg
	HPhobRAIDcfg
	hpRAIDsh
	hpHWsh
	ttydisable
elif [ `$system="hp" && $client="xymon"` ]; then
	HPsudo
	HPtools
	HPxyHWcfg
	HPxyRAIDcfg
	hpRAIDsh
	hpHWsh
	ttydisable
else 
	echo "Error in hp function"
	exit 1
fi
}

function xymon { 
if [ "$client='xymon' && $monitor='ipmi'" ]; then
	hobxyIPMIsudo
	ttydisable
	IPMIsh
	xyIPMIcfg
	ipmitools
elif [ "$client='xymon' && $monitor='soft'" ];then
	ttydisable
	xyRAIDcfg
	softRAIDsh
elif [ "$client='xymon' && $monitor='lsi'" ];then
	ttydisable
	megaclisudo
	xyRAIDcfg
	hardRAIDsh
	hardRAIDtools
else
	echo "Error in xymon function"
	exit 1
fi
}

function hobbit {
if [ "$client='hobbit' && $monitor='ipmi'" ]; then
        hobxyIPMIsudo
        ttydisable
        IPMIsh
        hobIPMIcfg
        ipmitools
elif [ "$client='hobbit' && $monitor='soft'" ];then
        ttydisable
        hobRAIDcfg
        softRAIDsh
elif [ "$client='hobbit' && $monitor='lsi'" ];then
        ttydisable
        megaclisudo
        hobRAIDcfg
        hardRAIDsh
        hardRAIDtools
else
        echo "Error in xymon function"
        exit 1
fi
}

#function hobbit {
#if [ "$client='hobbit' && $monitor='ipmi'" ];then
	
###### NOTES SECTION
#function hobxyIPMIsudo ## deploy IPMI sudo priv
#function ttydisable    ## disable tty for mon
#function megaclisudo   ## megacli sudo priv
#function HPsudo        ## hp mon tools sudo priv
#function xyRAIDcfg     ## xymon RAID mon client launch cfg
#function hobRAIDcfg    ## hobbit RAID mon client launch cfg
#function HPhobRAIDcfg  ## hp hob RAID mon client launch cfg
#function HPxyRAIDcfg   ## HP xy RAID mon client launch cfg
#function HPhobHWcfg    ## HP hob HW mon client launch cfg
#function HPxyHWcfg     ## hp xy HW mon client launch cfg
#function softRAIDsh    ## software RIAD mon script deploy
#function hardRAIDsh    ## hardware RAID mon script deploy
#function IPMIsh        ## IPMI mon script deploy
#function hpRAIDsh      ## hp RAID mon script deploy
#function hpHWsh        ## HP hardware mon script deploy
#function HPtools       ## hp mon tools installation
#function hardRAIDtools ## software RAID mon tools installation REDhat


echo "this is the end of days"
   echo "Usage:"
   echo "$(basename $0) --xymon ipmi"
   echo "$(basename $0) --xymon lsi"
   echo "$(basename $0) --xymon soft"
   echo "$(basename $0) --hobbit ipmi"
   echo "$(basename $0) --hobbit lsi"
   echo "$(basename $0) --hobbit soft"
   echo "$(basename $0) --hp hobbit"
   echo "$(basename $0) --hp xymon"
   echo "$(basename $0) --tty"
   echo "$(basename $0) --help"
   echo "Options:"
   echo "--xymon, -xymon"
   echo "--hobbit, -hobbit"
   echo "--hp, -hp"
   echo "--tty, -tty"
   echo "--help, -help -H, -h"
