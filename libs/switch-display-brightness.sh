function brightness {
    if [[ -z $1 ]]; then echo 'need parameter brightness value'
        return
    fi
    ddcutil --async --sn GN64V68824CL setvcp 0x10 $1
    ddcutil --async --sn C9G5D6BU3HGB setvcp 0x10 $1
}

function auto-brightness {
    pyscript="$(dirname "${BASH_SOURCE[0]}")/switch-display-brightness.py"
    new_brightness_value=$(python3 $pyscript)
    echo 新的亮度值为 $new_brightness_value
    brightness $new_brightness_value
}

