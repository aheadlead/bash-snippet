
function config-for-scitools {
    path_to_scitools=$1
    if [[ ! -d ${path_to_scitools} ]]; then
        echo 'config_scitools 后应该接 scitools/ 目录'
        return
    fi
    if [[ ! -d ${path_to_scitools}/bin/linux64 ]]; then
        echo 'config_scitools 后应该接 scitools 目录, 确保里面有 bin/linux64 文件夹.'
        return
    fi
    export PATH=$PATH:$1/bin/linux64
    export STIHOME=$1
}

