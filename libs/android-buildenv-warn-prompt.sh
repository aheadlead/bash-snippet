
function android_buildenv_warn_prompt {
    [[ -n ${MIUI_BUILD_VERSION} ]] &&
        echo -e "\\033[1;48;5;160;38;5;226m[Android 编译环境]\\033[0m"
}
trap "android_buildenv_warn_prompt" DEBUG

