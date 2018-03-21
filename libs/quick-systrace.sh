
# 配置项 SYSTRACE_PATH 为 systrace 所在的目录
# 配置项 SYSTRACE_STORAGE_PATH 为 systrace 采集结果所在目录


function __quick-systrace-show_help {
    echo "快速启动 systrace"
    echo
    echo "用法: quick-systrace [-e/-s SERIAL] [-t TAG] [-h]"
    echo
    echo "  -s      指定序列号"
    echo "  -e      指定序列号 (和 -s 等价)"
    echo "  -t      指定附在文件名中的标签"
    echo "  -h      显示本帮助"
    echo "  -d      trace 文件保存到临时目录"
}


function quick-systrace {
    if [[ 3 -eq $(adb devices | wc -l) ]]; then
        # 当前只有一台 adb 设备
        local serial=$(adb devices | awk 'NR == 2 { print $1 }')
    fi

    local tag=$(date +%T)
    local save_to_tempdir=

    # 解析 args
    while getopts "de:hs:t:" OPT; do
        case ${OPT} in
            d)  save_to_tempdir=1 ;;
            e)  serial=${OPTARG} ;;
            s)  serial=${OPTARG} ;;
            h)  __quick-systrace-show_help
                return ;;
            t)  tag=${OPTARG} ;;
        esac
    done

    if [[ -z ${serial} ]]; then
        echo '目前不止一台设备连接, 请使用 -s 指定一台设备'
        return
    fi

    local product=$(adb -s ${serial} shell getprop ro.build.product \
                    | xargs)  # trim white charactors
    echo "product: ${product}"

    local date_str=$(date +%F)
    local fname="${date_str}-${tag}.html"

    local dname=${SYSTRACE_STORAGE_PATH}/${product}/${serial}/

    mkdir -p ${dname}

    if [[ -n ${save_to_tempdir} ]]; then
        local abspath=$(mktemp)
    else
        local abspath=${dname}/${fname}
    fi

    echo "输出文件: ${abspath}"

    pushd ${SYSTRACE_PATH} > /dev/null && {

        local categories=$(
            python ${SYSTRACE_PATH}/systrace.py -e ${serial} --list-categories \
            | awk '$2 == "-" { printf("%s ", $1); }'
        )   

        echo "类别: ${categories}"
        echo

        python ${SYSTRACE_PATH}/systrace.py -e ${serial} -o ${abspath} ${categories} && {
            xdg-open ${abspath}
        }
        popd > /dev/null
    }

}


function quick-systrace-open {
    # 快速打开 systrace 结果的目录
    if [[ -n ${SYSTRACE_STORAGE_PATH} ]]; then
        if [[ -d ${SYSTRACE_STORAGE_PATH} ]]; then
            xdg-open ${SYSTRACE_STORAGE_PATH}
        else
            echo "目录 ${SYSTRACE_STORAGE_PATH} 不存在"
            return 1
        fi
    else
        echo "你没有设置环境变量 SYSTRACE_STORAGE_PATH"
        return 1
    fi
}

