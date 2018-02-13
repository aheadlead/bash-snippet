function fuck-jack {
    export JACK_SERVER_VM_ARGUMENTS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4096m"
    ${ANDROID_HOST_OUT}/bin/jack-admin kill-server
    ${ANDROID_HOST_OUT}/bin/jack-admin start-server
}
