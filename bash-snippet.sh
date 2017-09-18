function import {
    lib_to_import=$1
    path=$(dirname "${BASH_SOURCE[0]}")/libs/$lib_to_import.sh
    . "$path"
}

