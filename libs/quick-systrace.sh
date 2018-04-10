

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
    echo "  -a      强制采集所有的 category (忽略环境变量 SYSTRACE_CATEGORY)"
    echo
    echo "可设置环境变量 SYSTRACE_CATEGORY 指定要采集的 category."
    echo "若未设置环境变量 SYSTRACE_CATEGORY, 则采集所有支持的 category."
    echo "如:"
    echo "   export SYSTRACE_CATEGORY='gfx input view webview am res sched freq idle load'"
    echo
}


function __quick-systrace-setup-intro {
    echo "看起来你是第一次使用."
    echo
    echo "请在 ~/.bash_profile 中使用 export 设置环境变量以配置 quick-systrace :"
    echo
    echo "  SYSTRACE_PATH 为 systrace 所在的\"目录\""
    echo "  SYSTRACE_STORAGE_PATH 为 systrace 采集结果存放的目录"
    echo "  SYSTRACE_CATEGORY 为要采集的 category (可选)"
    echo
    echo "若未设置环境变量 SYSTRACE_CATEGORY, 则采集所有支持的 category."
    echo "但采集所有 category 会导致 Chrome 很卡, 建议 SYSTRACE_CATEGORY 设置为:"
    echo
    echo "   export SYSTRACE_CATEGORY='gfx input view webview am res sched freq idle load'"
}


function quick-systrace {
    if [[ -z ${SYSTRACE_PATH} ]] || [[ -z ${SYSTRACE_STORAGE_PATH} ]]; then
        __quick-systrace-setup-intro
        return
    fi

    local serial=

    if [[ 3 -eq $(adb devices | wc -l) ]]; then
        # 当前只有一台 adb 设备
        local serial=$(adb devices | awk 'NR == 2 { print $1 }')
    fi

    local tag=$(date +%T)
    local save_to_tempdir=false
    local seconds=
    local ignore_category_environ=false

    # 解析 args
    local OPTERR
    local OPTARG
    local OPTIND
    while getopts "ade:hs:t:T:" OPT; do
        case ${OPT} in
            a)  ignore_category_environ=true ;;
            d)  save_to_tempdir=true ;;
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

    if ${save_to_tempdir}; then
        local abspath=$(mktemp)
    else
        local abspath=${dname}/${fname}
    fi

    echo "输出文件: ${abspath}"

    pushd ${SYSTRACE_PATH} > /dev/null && {

        # 决定使用哪些 category
        local use_all_support_category=false

        if ${ignore_category_environ}; then
            # 用户在命令行里指定忽略环境变量 SYSTRACE_CATEGORY
            use_all_support_category=true
        else
            # 不忽略环境变量 SYSTRACE_CATEGORY
            if [[ -z ${SYSTRACE_CATEGORY} ]]; then
                # 环境变量 SYSTRACE_CATEGORY 为空
                use_all_support_category=true
            else
                # 环境变量 SYSTRACE_CATEGORY 非空
                local -r categories=${SYSTRACE_CATEGORY}
            fi
        fi

        if ${use_all_support_category}; then
            local -r categories=$(
                python ${SYSTRACE_PATH}/systrace.py -e ${serial} \
                    --list-categories | awk '$2 == "-" { printf("%s ", $1); }'
            )
        fi

        echo "将采集的 Categories: ${categories}"
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

