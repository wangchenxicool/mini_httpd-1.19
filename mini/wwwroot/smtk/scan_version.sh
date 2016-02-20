#!/bin/sh

LOCAL_PATH=/mnt/update
IP=172.16.88.2:2060
logfile=./get_pkg.log

__readINI() {
 INIFILE=$1; SECTION=$2; ITEM=$3
 _readIni=`awk -F '=' '/\['$SECTION'\]/{a=1}a==1&&$1~/'$ITEM'/{print $2;exit}' $INIFILE`
echo ${_readIni}
}

. /bin/cd.sh ${LOCAL_PATH}

__scan() {

# read MTK_PKG_NEXT
MTK_PKG_NEXT=$(curl -l "$IP/@mac@192.168.43.1@xyz/getVersion")
[ $? -ne 0 ] && return
#[ $? -eq 0 ] && {
    [ $MTK_PKG_NEXT == "error" ] && {
        echo "MTK_PKG_NEXT is error!"
        return 0
    }
    [ -z $MTK_PKG_NEXT ] && return 0
#}
#echo "MTK_PKG_NEXT:${MTK_PKG_NEXT}"

# read MTK_PKG_CUR
MTK_PKG_CUR=$(__readINI version.ini FILE_INFO mtk_pkg_name)
[ $? -ne 0 ] && {
    echo "Get MTK_PKG_CUR err!"
    return 0
}
#echo "MTK_PKG_CUR:${MTK_PKG_CUR}"


#MTK_PKG_CUR=smtk11_0_6.tgz
#MTK_PKG_NEXT=smtk11_0_7.tgz

## get ver_no
#ver_cur=$(echo $MTK_PKG_CUR | grep -o '[0-9]\+_[0-9]\+_[0-9]\+' | sed 's/_//g')
#[ -z $ver_cur ] && return 0
#ver_next=$(echo $MTK_PKG_NEXT | grep -o '[0-9]\+_[0-9]\+_[0-9]\+' | sed 's/_//g')
#[ -z $ver_next ] && return 0

#ver_cur="smtk11_0_6.tgz"
ver_cur=$MTK_PKG_CUR
ver_cur=${ver_cur#*mtk}
ver_cur=${ver_cur%.*}
ver_cur=$(echo $ver_cur | sed 's/_//g')
[ -z $ver_cur ] && return 0

#ver_next="smtk11_0_6.tgz"
ver_next=$MTK_PKG_NEXT
ver_next=${ver_next#*mtk}
ver_next=${ver_next%.*}
ver_next=$(echo $ver_next | sed 's/_//g')
[ -z $ver_next ] && return 0

echo "ver_cur:${ver_cur}, ver_next:${ver_next}"

[ ${ver_next} -gt ${ver_cur} ] && {
    echo "update..."
    wget -c $IP/@mac@192.168.43.1@xyz/file/downloadmaterial?fileName=/mnt/sdcard/media/$MTK_PKG_NEXT
    [ $? -eq 0 ] && {
        tar xzvf $MTK_PKG_NEXT -C pkg
        [ $? -eq 0 ] && {
            echo "Get new pkg:$MTK_PKG_NEXT ------- $(date)" >> $logfile
            #change ini file
            echo [FILE_INFO] > ./version.ini
            echo "mtk_pkg_name=$MTK_PKG_NEXT" >> ./version.ini
            echo "is_update=1" >> ./version.ini
            #del local pkg
            [ -e $MTK_PKG_CUR ] && rm $MTK_PKG_CUR
        }
        sync
    }
} || {
    echo "not update!"
}

}

while [ true ] ; do
    __scan
    sleep 120
done
