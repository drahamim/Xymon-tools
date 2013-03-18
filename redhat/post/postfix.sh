#!/bin/sh

#  Script to fix Postfix config
#
PATH=/bin:/usr/sbin:/usr/bin

#HOST=`hostname`
#FQDN=`hostname -f`
#DOMAIN=`hostname -f | cut -d"." -f2-`

IPADDR=`cat /etc/network/interfaces  | grep address | cut -d" " -f10-`
FQDN=`dnsget -q $IPADDR | sed 's/.$//g'`
DOMAIN=`echo $FQDN | cut -d"." -f2-`

postconf -e "myhostname = $FQDN"
postconf -e "mydestination = $FQDN, localhost.$DOMAIN, localhost"
echo $FQDN > /etc/mailname
wget -q -O /etc/aliases http://10.1.31.25/netinstall/11.04/postinstall/common/aliases
newaliases
