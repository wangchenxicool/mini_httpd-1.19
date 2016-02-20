#!/bin/sh

# sbin
cp ./dnsmasq /usr/sbin/dnsmasq

# bin
#cp ./busybox /bin/
cp ./net_manager.sh /bin/
cp ./net_manager.bin /bin/
cp ./dnsmasq.sh /bin/
cp ./scan_version.sh /bin/
cp ./updata.sh /bin/
cp ./qos-v2.sh /bin/
cp ./record_start.sh /bin/
cp ./ntpd.sh /bin/

# cgi-bin
cp ./dnsmasq_start_ok /www/cgi-bin/
cp ./version /www/cgi-bin/
cp ./is_connect /www/cgi-bin/
cp ./net_cfg /www/cgi-bin/
cp ./number_of_start /www/cgi-bin/

# lib
cp ./libOpenWrt_WebGateway.so.1.0.0 /lib/OpenWrt_WebGateway.so

# etc
cp ./bangbangdog.conf /etc/
cp ./rc.local /etc/

# mnt
cp ./reboot.log /mnt
