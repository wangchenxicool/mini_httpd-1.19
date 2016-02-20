#!/bin/sh

__readINI() {
    INIFILE=$1; SECTION=$2; ITEM=$3
    _readIni=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$ITEM'/{print $2;exit}' $INIFILE`
    echo ${_readIni}
}

NUM_OF_START=$(__readINI /mnt/reboot.log mtk number_of_starts)

NUM_OF_START=$(( $NUM_OF_START + 1 ))

echo "[mtk]" > /mnt/reboot.log
echo "number_of_starts=${NUM_OF_START}" >> /mnt/reboot.log
