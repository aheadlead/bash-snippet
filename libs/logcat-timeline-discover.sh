
function __ltd_coloring {
    color_code=$1
    regex=$2
    GREP_COLORS="${color_code}" grep --color=always --line-buffered -P "${regex}|$"
}

function logcat-timeline-discover {
    if [[ -n "$1" ]]; then
        local -r sn_string="-s $1"
    fi

    adb ${sn_string} logcat -T1 \
        | grep --color=always --line-buffered Timeline \
        | __ltd_coloring "mt=01;32" "Activity_launch_request" \
        | __ltd_coloring "mt=01;34" "Activity_windows_visible" \
        | __ltd_coloring "mt=01;35" " cmp=.*?/.*? " \
        | __ltd_coloring "mt=0;101" "cat=\[android.intent.category.LAUNCHER\]"
}

#function timeline {
    ## WIP
    #local -r fname=$1
    #local -r app=${2:-'.*?'}
    #if [[ -z ${fname} ]]; then
        #read -p "path to logcat: " fname
    #fi

    #cat ${fname} \
        #| grep --color=always --line-buffered "Timeline\|^$\|^======>$"\
        #| __ltd_coloring "mt=01;32" "Activity_launch_request" \
        #| __ltd_coloring "mt=01;34" "Activity_windows_visible" \
        #| __ltd_coloring "mt=01;35" " cmp=${app}/.*? " \
        #| __ltd_coloring "mt=0;101" "^$\|^======>.*$"
#}

