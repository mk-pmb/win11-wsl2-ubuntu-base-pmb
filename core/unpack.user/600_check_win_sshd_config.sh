#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function sshcfgchk_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local FAIL_SCORE=0
  local CFG='/etc/ssh/sshd_config.d/'

  sshcfgchk_write_cfgd_file disable_password_login '
    PasswordAuthentication no
    ' || return $?

  CFG='/mnt/c/ProgramData/ssh/sshd_config'
  for CFG in $CFG; do sshcfgchk_one_file || return $?; done
  if [ "$FAIL_SCORE" == 0 ]; then
    echo D: '✅ No complaints.'
  else
    echo E: "🟥 Some SSH configs have problems." >&2
    return 4
  fi
}


function sshcfgchk_write_cfgd_file () {
  local BFN="$1" TEXT="$2"
  local DEST="$CFG"wub."$1".conf
  TEXT="$(echo "$TEXT" | sed -re 's!^\s+!!;/^$/{1d;$d}')"
  [ -f "$DEST" ] && cmp --silent -- <(echo "$TEXT") "$DEST" && return 0 || true
  echo "$TEXT" | sudo tee -- "$DEST" >/dev/null || return 4$(
    echo E: "Failed to write $DEST" >&2)
}


function sshcfgchk_one_file () {
  local KEY='PasswordAuthentication'
  local VAL="$(grep -Pe '^\s*'"$KEY"'\s' -- "$CFG")"
  if [ "$VAL" == "$KEY no" ]; then
    echo D: "✅ $CFG: $VAL"
  else
    VAL="$(grep -wFe "$KEY" -- "$CFG")"
    VAL="${VAL//$'\n'/¶ }"
    echo W: "⚠️ $CFG: $VAL" >&2
    (( FAIL_SCORE += 1 ))
  fi
}










sshcfgchk_cli_init "$@"; exit $?
