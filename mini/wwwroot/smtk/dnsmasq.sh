#!/bin/sh

DNSMASQ_STS_FILE=/var/log/dnsmasq-dhcp.log

__readINI() {
     INIFILE=$1; SECTION=$2; ITEM=$3
     _readIni=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$ITEM'/{print $2;exit}' $INIFILE`
    echo ${_readIni}
}

start_dnsmasq() {
    echo "[DNSMASQ_INFO]" > $DNSMASQ_STS_FILE
    echo "dnsmasq-dhcp=ng" >> $DNSMASQ_STS_FILE

    /etc/init.d/dnsmasq restart

    sleep 2

    for i in 1 2 3 4 5 6 7 8; do
        DNSMASQ_STS=$(__readINI ${DNSMASQ_STS_FILE} DNSMASQ_INFO dnsmasq-dhcp)
        #echo $i $DNSMASQ_STS
        [ $DNSMASQ_STS = "ok" ] && {
            #echo "dnsmasq sts:ok"
            break;
        } || {
            echo "dnsmasq restart.."
            /etc/init.d/dnsmasq restart
            sleep 2
        }
    done

    echo "dnsmasq end!"
}

start_dnsmasq
