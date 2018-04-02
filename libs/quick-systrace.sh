
# 配置项 SYSTRACE_PATH 为 systrace 所在的目录
# 配置项 SYSTRACE_STORAGE_PATH 为 systrace 采集结果所在目录


function __quick-systrace-show_help {
    echo "快速启动 systrace, 并启动所有 categories"
    echo
    echo "用法: quick-systrace [-e/-s SERIAL] [-t TAG] [-T SECONDS] [-h] [-d]"
    echo
    echo "  -s      指定序列号 SERIAL"
    echo "  -e      指定序列号 SERIAL (和 -s 等价)"
    echo "  -t      指定附在文件名中的标签 TAG"
    echo "  -T      抓取 SECONDS 秒的 trace"
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
    local seconds=

    # 解析 args
    while getopts "de:hs:t:T:" OPT; do
        case ${OPT} in
            d)  save_to_tempdir=1 ;;
            e)  serial=${OPTARG} ;;
            s)  serial=${OPTARG} ;;
            h)  __quick-systrace-show_help
                return ;;
            t)  tag=${OPTARG} ;;
            T)  seconds=${OPTARG} ;;
        esac
    done

    if [[ -z ${serial} ]]; then
        echo '目前不止一台设备连接, 请使用 -s 指定一台设备'
        return
    fi

    if [[ -n ${seconds} ]]; then
        echo ${seconds} | grep -qE '^[0-9]+$' || {
            echo "参数不正确: -T ${seconds}"
            return
        }
    fi

    local product=$(adb -s ${serial} shell getprop ro.build.product \
                    | tr -d '\r\n')
    echo "Product: ${product}"

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

        echo "支持的 Categories: ${categories}"
        echo

        local issue_command="python ${SYSTRACE_PATH}/systrace.py"

        if [[ -n ${seconds} ]]; then
            issue_command+=" -t ${seconds}"
        fi

        issue_command+=" -e ${serial} -o ${abspath} ${categories}"

        ${issue_command} && xdg-open ${abspath}

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

