
function adb-device-selector {
    declare -i cnt=1
    tmp=$(mktemp)
    adb devices -l | sed '1d;$d' > $tmp
    cat $tmp | while read; do
        echo -en "\e[1;33m$cnt\e[0m" 1>&2
        echo " $REPLY" | GREP_COLOR='01;30;106' grep -P '(?<=:).*?(?= |$)|$' 1>&2
        cnt+=1
    done
    echo 1>&2
    read -p 选择一个设备 -n1 choice 1>&2
    echo 1>&2
    serial=$(sed "${choice}q;d" $tmp | awk '{print $1}')
    rm $tmp

    if [[ -z "$*" ]]; then
        adb -s $serial shell
    elif [[ "$1" == "echo-sn" ]]; then
        echo $serial
    else
        adb -s $serial $*
    fi
}

function copy-serial {
    declare -i cnt=1
    tmp=$(mktemp)
    adb devices -l | sed '1d;$d' > $tmp
    cat $tmp | while read; do
        echo -en "\e[1;33m$cnt\e[0m" 1>&2
        echo " $REPLY" | GREP_COLOR='01;30;106' grep -P '(?<=:).*?(?= |$)|$' 1>&2
        cnt+=1
    done
    echo 1>&2
    read -p 选择一个设备 -n1 choice 1>&2
    echo 1>&2
    serial=$(sed "${choice}q;d" $tmp | awk '{print $1}')
    rm $tmp

    echo -n ${serial} | xsel -b -i
}
