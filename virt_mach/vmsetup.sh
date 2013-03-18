server=$1		# current ip addrress (generally dhcp assigned)
hostname=$2		# new hostname for server
ipaddr=$3		# new ip address for server

#### hostname file modification ####
echo $hostname >> vmhostname.temp

scp -prC vmhostname.temp root@$server:/etc/hostname
rm vmhostname.temp
#### /etc/network/interfaces file modification ####

cat <<EOF >> vmsetip.temp
# The loopback network interface
auto lo
iface lo inet loopback

# The primary network interface
auto eth0
iface eth0 inet static
        address $ipaddr
        netmask 255.255.248.0
        network 10.1.40.0
        broadcast 10.1.47.255
        gateway 10.1.40.1
EOF
ssh $server "cp /etc/network/interfaces /etc/network/interfaces.old"
scp -prC vmsetip.temp root@$server:/etc/network/interfaces
rm vmsetip.temp
#### RWC NTP setup #####
cat <<EOF >> vmsetresolve.tmp
nameserver 10.1.24.10
nameserver 10.1.24.11
EOF

scp -prC vmsetresolve.tmp root@$server:/etc/resolve.conf

rm vmsetresolve.tmp

### RWC NTP setup ####
cat <<EOF >> vmsetntp.tmp
server grasshopper.seven.com
server spider.seven.com

driftfile /var/lib/ntp/ntp.drift
statsdir /var/log/ntpstats/
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable

# By default, exchange time with everybody, but don't allow configuration.
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery

# Local users may interrogate the ntp server more closely.
restrict 127.0.0.1
restrict ::1
EOF

scp vmsetntp.tmp root@$server:/etc/ntp.conf

rm vmsetntp.tmp


