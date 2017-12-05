
function wait-until {
    target=$1
    echo ${target} | grep -q -P '\d{2}:\d{2}:\d{2}' || {
        echo "参数不正确, 应为 $(date +%T) 这样的格式"
        return
    }
    while [[ "${target}" != "$(date +%T)" ]]; do
        sleep 1
    done
}

