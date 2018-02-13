
function get-file-number-per-dir {
    du -a | cut -d/ -f2 | sort | uniq -c | sort -nr
}
