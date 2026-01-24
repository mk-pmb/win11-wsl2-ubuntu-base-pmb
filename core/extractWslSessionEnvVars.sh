#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function dump_wsl_session_env () {
  local SELF_ABS="$(readlink -m -- "$BASH_SOURCE")"
  local SELF_PRE="${SELF_ABS%.sh}"
  local SELF_DIR="${SELF_ABS%/*}"
  local DEST_BASE="$1"; shift
  [ -n "$DEST_BASE" ] || DEST_BASE="tmp.$FUNCNAME."
  env |
    "$SELF_PRE.noBoring.sed" |
    LANG=C sort --version-sort |
    tee -- "$DEST_BASE"session.raw |
    "$SELF_PRE.knownSession.sed" |
    "$SELF_PRE.knownSession.sed" |
    wub core/env2sh | sed -nre '/=\S/s~^~export ~p' \
    >"$DEST_BASE"session.join.rc
  echo "${PATH//:/$'\n'}" >"$DEST_BASE"paths.list
}










dump_wsl_session_env "$@"; exit $?
