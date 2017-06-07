
function check_root_privilege {
  [[ 0 -eq $EUID ]]
  return $?
}



function root_guard {
  check_root_privilege || exit_with 'You should run this script with root privilege.'
}

