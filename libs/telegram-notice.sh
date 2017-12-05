# push a notification when a long-time command finished
# prefix: _TGPN
function _TGPN_precommand_cbk() {
  [[ -z "$_TGPN_AT_PROMPT" ]] && return
  unset _TGPN_AT_PROMPT
  _TGPN_CMD="$BASH_COMMAND"
  _TGPN_TELEGRAM_NOTIFY_START_TIME=$(date +%s)
}
trap '_TGPN_precommand_cbk' DEBUG
_TGPN_FIRST_PROMPT=1
function _TGPN_postcommand_cbk() {
  _TGPN_AT_PROMPT=1
  if [ -n "$_TGPN_FIRST_PROMPT" ]; then
    unset _TGPN_FIRST_PROMPT
    return
  fi
  local NOW=$(date +%s)
  local DIFFERENCE=$(( $NOW - ${_TGPN_TELEGRAM_NOTIFY_START_TIME:-0} ))
  _TGPN_THRESHOLD=60
  _TGPN_IGNORE=$(cat <<EOF
^adb shell
^vi
^nano
^ssh
^man
^mail
^ftp
EOF
)
  [[ $DIFFERENCE -gt $_TGPN_THRESHOLD ]] && { 
    for pattern in $_TGPN_IGNORE; do
      echo $_TGPN_CMD | grep -qE $pattern && return
    done
    echo $_TGPN_CMD
    https_proxy=$tg_notice_prx telegram-send "✅$_TGPN_CMD" &
  }
}
PROMPT_COMMAND="_TGPN_postcommand_cbk"
