
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
