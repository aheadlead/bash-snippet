function make-flash-kernel {
    # it doesn't work at the moment.
    if [[ -n $1 ]]; then
        sn="-s $1"
    else
        sn=
    fi

    make -j8 bootimage &&
        pushd out/target/product/ &&
        cd $(ls -1 | head -n 1) &&
        adb $sn reboot bootloader &&
        fastboot $sn flash boot boot.img &&
        fastboot $sn reboot

}

