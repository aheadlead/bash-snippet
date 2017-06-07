
function exit_with {
  message=$1
  retcode=${2:-0}
  
  echo $1
  exit $retcode
}

