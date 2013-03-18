#!/bin/sh
mkdir /root/.ssh
cat authorized_keys >> /root/.ssh/authorized_keys
rm index.html*
chmod +x users.sh
chmod +X postfix.sh
chmod +x network.sh
mv network.sh /etc/init.d/
chkconfig network.sh on
./users.sh

