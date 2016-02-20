#!/bin/sh

LOCAL_PATH=/mnt/update
logfile=./update.log

__readINI() {
 INIFILE=$1; SECTION=$2; ITEM=$3
 _readIni=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$ITEM'/{print $2;exit}' $INIFILE`
echo ${_readIni}
}

. /bin/cd.sh ${LOCAL_PATH}

# read MTK_PKG_LOCAL
MTK_PKG_LOCAL=$(__readINI version.ini FILE_INFO mtk_pkg_name)
if [ $? -eq 0 ];then
    echo "MTK_PKG_LOCAL:${MTK_PKG_LOCAL}"
else
    echo "Get MTK_PKG_LOCAL err!"
    return
fi

# read is_update
IS_UPDATE=$(__readINI version.ini FILE_INFO is_update)
if [ $? -eq 0 ];then
    echo "is_update:${IS_UPDATE}"
else
    echo "Get MTK_PKG_LOCAL err!"
    return
fi

if [ "$IS_UPDATE" -eq "1" ];then
    echo "update..."
    cd pkg
    ./install.sh
    sync
    cd ../
    echo [FILE_INFO] > ./version.ini
    echo "mtk_pkg_name=$MTK_PKG_LOCAL" >> ./version.ini
    echo "is_update=0" >> ./version.ini
    echo "installed new pkg:$MTK_PKG_LOCAL ------- $(date)" >> $logfile
    rm $LOCAL_PATH/*.tgz
fi
