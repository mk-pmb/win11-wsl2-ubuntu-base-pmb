#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function merge_env_vars__cli_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELF_ABS="$(readlink -m -- "$BASH_SOURCE")"
  local SELF_DIR="${SELF_ABS%/*}"
  local REPO_DIR="${SELF_DIR%/*/*}"
  local REPO_DBN="${REPO_DIR##*/}"
  local ENV_DUMP="/mnt/wsl/$REPO_DBN/env.session.raw"
  echo "< $ENV_DUMP"
  exec <"$ENV_DUMP" || return $?
  local KEY= VAL= OLD= ACCUM=
  while IFS= read -r VAL; do
    KEY="${VAL%%=*}"
    VAL="${VAL:${#KEY}+1}"
    [ -n "$VAL" ] || continue
    eval 'OLD="$'"$KEY"'"'
    case "$KEY" in
      OLDPWD | \
      USER | \
      '' ) continue;;
      DISPLAY ) VAL="${VAL%.0}"; OLD="${OLD%.0}";;
    esac
    [ "$OLD" != "$VAL" ] || continue
    if [ -z "$OLD" ]; then ACCUM+="$KEY=$VAL"$'\n'; continue; fi
    case "$KEY" in
      PATH )
        VAL="$("$SELF_DIR"/merge.paths.sh "$OLD" "$VAL")"
        [ -n "$VAL" ] || continue$(echo W: $FUNCNAME: >&2 \
          'Failed to merge PATHs!')
        ACCUM+="$KEY=$VAL"$'\n'
        continue;;
      DBUS_SESSION_BUS_* | \
      XDG_* | \
      '' ) continue;;
    esac
    echo "# ?? No merge strategy for '$KEY' = '$OLD' vs. '$VAL'"
  done
  echo "$ACCUM" | wub core/env2sh.sed | sed -nre 's~^\S~export &~p'
}










merge_env_vars__cli_main "$@"; exit $?
