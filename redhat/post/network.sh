#!/bin/bash
#
# This is a First Boot RedHat Configuration Script
#
#chkconfig: 2345 9 20
#
case "$1" in 
	start)

echo "Fully Qualified Domain Name of this Host?"
read FQDN

echo "What is to be the IP?"
read address

net=`echo $address|cut -d'.' -f3`
echo $net

if[ 1 <= $net <= 5]
then
	network=10.1.0.0
	netmask=255.255.248.0
	gateway=10.1.0.1

elif[16 <= $net <= 23]
then 
        network=10.1.16.0
        netmask=255.255.248.0
        gateway=10.1.16.1

elif[24 <= $net <= 31]
then 
        network=10.1.24.0
        netmask=255.255.248.0
        gateway=10.1.24.1
elif[32 <= $net <= 39]
then
        network=10.1.32.0
        netmask=255.255.248.0
        gateway=10.1.32.1
elif[40 <= $net <= 47]
then
        network=10.1.40.0
        netmask=255.255.248.0
        gateway=10.1.40.1
elif[48 <= $net <= 55]
then
        network=10.1.48.0
        netmask=255.255.248.0
        gateway=10.1.48.1
elif[56 <= $net <= 63]
then
        network=10.1.56.0
        netmask=255.255.248.0
        gateway=10.1.56.1
elif[64 <= $net <= 71]
then
        network=10.1.64.0
        netmask=255.255.248.0
        gateway=10.1.64.1
elif[72 <= $net <= 79]
then
        network=10.1.72.0
        netmask=255.255.248.0
        gateway=10.1.72.1
elif[$net = 130]
then
        network=10.1.130.0
        netmask=255.255.255.0
        gateway=10.1.130.1
else	
	echo "incorrect IP"
	exit

fi


echo "Configuring Hostname"

hostname $FQDN

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

echo "$macaddr"
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
