
function exit_with {
  message=$1
  retcode=${2:-1}
  
  echo $1
  exit $retcode
}

