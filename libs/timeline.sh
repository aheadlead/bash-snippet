
function timeline {
    local -r fname=$1
    if [[ -z ${fname} ]]; then
        read -p "path to logcat: " fname
    fi

    cat ${fname} | grep '^$\|launch_request\|windows_visible\|^======>'
}

