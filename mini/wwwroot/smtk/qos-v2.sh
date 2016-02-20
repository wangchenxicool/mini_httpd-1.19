#!/bin/sh

#ODEV="eth0.2"
ODEV=$1
GW_INTERFACE=br-lan
DOWNLINK=4096
DOWNLINK=10240
OTHERSLINK=400

start_routing() {
    ################################################################################################################
    ## del qdisc
    tc qdisc del dev $GW_INTERFACE root
    ## add qdisc
    tc qdisc add dev $GW_INTERFACE root handle 1: htb default 0xf0
    ## add class_1:1
    tc class add dev $GW_INTERFACE parent 1: classid 1:1 htb rate $(($DOWNLINK))kbit ceil $(($DOWNLINK))kbit prio 0
    ################################################################################################################

    ################################################################################################################
    ##----->add class_1:11--SYN,ACK,ICMP
    tc class add dev $GW_INTERFACE parent 1:1 classid 1:11 htb rate $(($DOWNLINK))kbit ceil $(($DOWNLINK))kbit prio 1 

    ##---->add class_1:12--bangbang
    tc class add dev $GW_INTERFACE parent 1:1 classid 1:12 htb rate $(($DOWNLINK))kbit ceil $(($DOWNLINK))kbit prio 2 
    
    ##---->add class_1:13--web
    tc class add dev $GW_INTERFACE parent 1:1 classid 1:13 htb rate $(($DOWNLINK))kbit ceil $(($DOWNLINK))kbit prio 3

    ##---->add class_1:14--others
    tc class add dev $GW_INTERFACE parent 1:1 classid 1:14 htb rate $((OTHERSLINK))kbps ceil $((OTHERSLINK))kbps prio 4 
    ## 采用sfq伪随机队列，并且10秒重置一次散列函数。
    tc qdisc add dev $GW_INTERFACE parent 1:14 handle 101: sfq perturb 10 
    ################################################################################################################

    ################################################################################################################
    tc filter add dev $GW_INTERFACE parent 1:0 protocol ip prio 1 handle 0x10/0xf0 fw classid 1:11 
    tc filter add dev $GW_INTERFACE parent 1:0 protocol ip prio 2 handle 0x20/0xf0 fw classid 1:12 
    tc filter add dev $GW_INTERFACE parent 1:0 protocol ip prio 3 handle 0x30/0xf0 fw classid 1:13 
    tc filter add dev $GW_INTERFACE parent 1:0 protocol ip prio 4 handle 0x40/0xf0 fw classid 1:14 
    ################################################################################################################
    
    #tc filter add dev $GW_INTERFACE parent ffff: protocol ip prio 5 u32 match ip src 0.0.0.0/0 police rate $(($DOWNLINK))kbit burst 1k drop flowid :4
}

start_mangle() {
    ## SYN,RST,ACK
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -j MARK --or-mark 0x10 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --tcp-flags SYN,RST,ACK SYN -j RETURN 

    ## icmp,ping
    iptables -t mangle -A POSTROUTING -p icmp -j MARK --or-mark 0x10 
    iptables -t mangle -A POSTROUTING -p icmp -j RETURN 

    ## small packets
    iptables -t mangle -A POSTROUTING -p tcp -m length --length :64 -j MARK --or-mark 0x20 
    iptables -t mangle -A POSTROUTING -p tcp -m length --length :64 -j RETURN 

    ## bangbang
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 2060 -j MARK --or-mark 0x20
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 2060 -j RETURN
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 7000 -j MARK --or-mark 0x20
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 7000 -j RETURN
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 7002 -j MARK --or-mark 0x20 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 7002 -j RETURN 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 8000 -j MARK --or-mark 0x20 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 8000 -j RETURN 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 7887 -j MARK --or-mark 0x20 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 7887 -j RETURN 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 9300 -j MARK --or-mark 0x20 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 9300 -j RETURN 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 9500 -j MARK --or-mark 0x20 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 9500 -j RETURN 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 9400 -j MARK --or-mark 0x20 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 9400 -j RETURN 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 80 -m string --string "bangzone.cn" --algo kmp -j MARK --or-mark 0x20 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 80 -m string --string "bangzone.cn" --algo kmp -j RETURN 
    
    ## http
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 80 -j MARK --or-mark 0x30 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 80 -j RETURN
    iptables -t mangle -A PREROUTING -p tcp -m tcp --sport 80 -j MARK --or-mark 0x40 
    #iptables -t mangle -A PREROUTING -p tcp -m tcp --sport 80 -j MARK --or-mark 0x30 
    iptables -t mangle -A PREROUTING -p tcp -m tcp --sport 80 -j RETURN

    ## https
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 443 -j MARK --or-mark 0x30 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 443 -j RETURN 
    iptables -t mangle -A PREROUTING -p tcp -m tcp --sport 443 -j MARK --or-mark 0x40 
    #iptables -t mangle -A PREROUTING -p tcp -m tcp --sport 443 -j MARK --or-mark 0x30
    iptables -t mangle -A PREROUTING -p tcp -m tcp --sport 443 -j RETURN 

    ## local data
    iptables -t mangle -A OUTPUT -p tcp -m tcp --dport 22 -j MARK --or-mark 0x10 
    iptables -t mangle -A OUTPUT -p tcp -m tcp --dport 22 -j RETURN 
    iptables -t mangle -A OUTPUT -p icmp -j MARK --or-mark 0x10 
    iptables -t mangle -A OUTPUT -p icmp -j RETURN 

    ## small packets (probably just ACKs)
    iptables -t mangle -A OUTPUT -p tcp -m length --length :64 -j MARK --or-mark 0x20 
    iptables -t mangle -A OUTPUT -p tcp -m length --length :64 -j RETURN 

    ## ssh
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 22 -j MARK --or-mark 0x10 
    iptables -t mangle -A POSTROUTING -p tcp -m tcp --dport 22 -j RETURN 

    ## name-domain server
    iptables -t mangle -A POSTROUTING -p udp -m udp --dport 53 -j MARK --or-mark 0x10 
    iptables -t mangle -A POSTROUTING -p udp -m udp --dport 53 -j RETURN 

    ## others
    iptables -t mangle -A POSTROUTING -d 192.168.43.0/24 -j MARK --or-mark 0x40 
    iptables -t mangle -A POSTROUTING -d 192.168.43.0/24 -j RETURN 
    iptables -t mangle -A PREROUTING -s 192.168.43.0/24 -j MARK --or-mark 0x40 
    iptables -t mangle -A PREROUTING -s 192.168.43.0/24 -j RETURN 
    
    ## 每IP限制TCP连接数100，UDP连接数150，并且对DNS,WEB等端口例外
    iptables -t mangle -N CONNLMT
    iptables -t mangle -I FORWARD -m state --state NEW -s 192.168.43.0/24 -j CONNLMT
    iptables -t mangle -I FORWARD -m state --state NEW -d 192.168.43.0/24 -j CONNLMT
    iptables -t mangle -A CONNLMT -p tcp -m connlimit --connlimit-above 100 -j DROP
    iptables -t mangle -A CONNLMT -p udp -m connlimit --connlimit-above 100 -j DROP
    iptables -t mangle -A CONNLMT -p udp -m limit --limit 5/sec -j DROP
    iptables -t mangle -I CONNLMT -p udp --dport 53 -j RETURN
    iptables -t mangle -I CONNLMT -p tcp --dport 80 -j RETURN
    iptables -t mangle -I CONNLMT -p tcp --dport 2060 -j RETURN
    iptables -t mangle -I CONNLMT -p tcp --dport 7000 -j RETURN
    iptables -t mangle -I CONNLMT -p tcp --dport 7002 -j RETURN
    iptables -t mangle -I CONNLMT -p tcp --dport 8000 -j RETURN
    iptables -t mangle -I CONNLMT -p tcp --dport 7887 -j RETURN
    iptables -t mangle -I CONNLMT -p tcp --dport 9300 -j RETURN
    iptables -t mangle -I CONNLMT -p tcp --dport 9500 -j RETURN
    iptables -t mangle -I CONNLMT -p tcp --dport 9400 -j RETURN
    
    #iptables -I FORWARD -p tcp -m connlimit --connlimit-above 10 -j DROP
    #iptables -I FORWARD -p udp -m limit --limit 2/sec -j DROP
    #iptables -I FORWARD -p tcp --dport 80 -j RETURN
}

stop_mangle() {
    iptables -t mangle -F 
}

stop_routing() {
    tc qdisc del dev $GW_INTERFACE root
    #tc qdisc del dev $GW_INTERFACE root && tc qdisc del dev $GW_INTERFACE ingress
    #tc qdisc del dev $IDEV root && tc qdisc del dev $IDEV ingress
}

status() {
    echo "1.show qdisc $ODEV----------------------------------------------"
    tc -s qdisc show dev $ODEV
    echo "2.show class $ODEV----------------------------------------------"
    tc class show dev $ODEV
    echo "3. tc -s class show dev $ODEV-----------------------------------"
    tc -s class show dev $ODEV
    echo "UPLIND:$UPLINK k."
    echo "1. classid 1:11 ssh/dns/SYN"
    echo "2. classid 1:12 bangbang"
    echo "3. classid 1:13 web"
    echo "4. classid 1:14 others"
}

case "$2" in
start)
    start_routing 
    start_mangle
    exit 0
    ;;
stop)
    stop_routing 
    stop_mangle
    exit 0
    ;;
restart)
    stop_routing
    stop_mangle
    start_routing
    start_mangle
    ;;
status)
    status
    ;;
mangle)
    iptables -t mangle -nL
    ;;
*) 
    exit 1
    ;;
esac
