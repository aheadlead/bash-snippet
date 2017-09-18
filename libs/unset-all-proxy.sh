function unset-all-proxy {
    for val in $(export | grep -i proxy | grep -Po "(?<=\-x )\w+_(PROXY|proxy)(?==\")"); do
        unset $val
    done
}

