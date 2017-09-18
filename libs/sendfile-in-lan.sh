

function receive-file {
    echo '这是你的 IP 地址: '
    while read ; do
        echo "  $REPLY";
    done <<< $(hostname -I)
    echo '挑选一个合适的(可能只有一个), 告诉你的小伙伴吧'
    echo '发送方运行 $ send-file <ip-addr> <file-or-directory>'

    nc -l 23333 | tar -xf -
}


function send-file {
    if [[ -z "$1" ]]; then
        echo '需要接收方的 IP 地址'
        echo
        echo '用法: $ send-file <remote-ip-addr> <path-to-file-or-dir>'
        return
    fi
    if [[ -z "$2" ]]; then
        echo '需要填写待发送的文件'
        echo
        echo '用法: $ send-file <remote-ip-addr> <path-to-file-or-dir>'
        return
    fi
    tar -cf - $2 | nc $1 23333
}

