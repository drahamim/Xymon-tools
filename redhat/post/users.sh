#!/bin/sh

groupadd -g 65533 nobody
useradd -c "Seven Manage User" -d /usr/local/seven -g nobody -m -p \$1\$4n3rWxfh\$AWoryssh59c/D7kNJ84ZC1 -s /bin/bash -u 8001 seven
useradd -c "Monitoring User" -d /usr/local/nagios -g nobody -m -p \$1\$q0wNkFOt\$BByS7J6rylFYRH7Vw.Fne0 -s /bin/bash -u 8111 nagios
useradd -c "Log-Watcher and Unpriv Access Pseudo-Account" -d /home/voyeur -g nogroup -m -p \$1\$0a.SekBb\$z8uSWNTg9xqzecIJZajgc1 -s /bin/bash -u 8003 voyeur
