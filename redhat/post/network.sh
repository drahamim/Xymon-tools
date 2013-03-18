#!/bin/bash
#
# This is a First Boot RedHat Configuration Script
#
#chkconfig: 2345 9 20
#
case "$1" in 
	start)

hostmac=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep "HWADDR" |cut -d"\"" -f2`

infoline=`cat /tmp/network.tab | grep -i $hostmac`

FQDN=`echo $infoline |cut -d',' -f2`
address=`echo $infoline |cut -d',' -f3`
netmask=`echo $infoline |cut -d',' -f4`
gateway=`echo $infoline |cut -d',' -f5`



sed -i.BAK -e "s/HOSTNAME=.*/HOSTNAME=$FQDN/" /etc/sysconfig/network

echo "Configuring Bond0 Master Interface"
cat << EOF >> /tmp/ifcfg-bond0.temp
DEVICE=bond0
IPADDR=$address
NETMASK=$netmask
GATEWAY=$gateway
USERCTL=no
BOOTPROTO=static
ONBOOT=yes
BONDING_OPTS="mode=2 miimon=100"

EOF

echo "Configureing Bond0 slave Eth0 Interface"
cat <<EOF >> /tmp/ifcfg-eth0.temp
DEVICE=eth0
ONBOOT=yes
USERCTL=no
BOOTPROTO=static
MASTER=bond0
SLAVE=yes

EOF

macaddr=`cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep HWADDR`

echo "$macaddr" >> /tmp/ifcfg-eth0.temp

echo "Configuring Bond0 slave Eth1 Interface"
cat <<EOF >> /tmp/ifcfg-eth1.temp
DEVICE=eth1
ONBOOT=yes
USERCTL=no
BOOTPROTO=static
MASTER=bond0
SLAVE=yes

EOF

macaddr=`cat /etc/sysconfig/network-scripts/ifcfg-eth1|grep HWADDR`

echo "$macaddr" >> /tmp/ifcfg-eth1.temp

mv /tmp/ifcfg-bond0.temp /etc/sysconfig/network-scripts/ifcfg-bond0
mv /tmp/ifcfg-eth0.temp /etc/sysconfig/network-scripts/ifcfg-eth0
mv /tmp/ifcfg-eth1.temp /etc/sysconfig/network-scripts/ifcfg-eth1

chkconfig network.sh off
;;
stop|status|restart|reload|force-reload)
	#do nothing
;;
esac
