
function yaml-validator {
  local DONT_PRINT_SUCCESS=0
  for i in $@; do
    [[ $i == '-h' ]] && {
      help_message=$(cat <<EOF
yaml-validator

This snippet is part of hkj for validating YAML files. It will scan files with
suffix '.yml' from current directory and point out the file which not follow
YAML syntax.

Usage:
    yaml-validator [option]

Option:
    -s          do not print correct files
    -h          show this help message
EOF
)
      echo -e "$help_message"
      return 0
    }
    [[ $i == '-s' ]] && {
      DONT_PRINT_SUCCESS=1
    }
  done
  for i in $(find -name *.yml); do 
    if ruby -e "require 'yaml';puts YAML.load_file('$i')" > /dev/null; then
      [[ $DONT_PRINT_SUCCESS -eq 1 ]] || echo -e "\e[1;32m[SUCCESS]\e[0m $i"
    else
      echo -e "\e[41m\e[1;37m[FAIL]\e[0m $i"
    fi
  done
}
