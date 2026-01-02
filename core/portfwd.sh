#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function portfwd () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFFILE="$(readlink -m -- "$BASH_SOURCE")"
  cd /mnt/c
  local LSN_PORT="$1"; shift
  case "$LSN_PORT" in
    --hide ) wub core/runHide "$SELFFILE" "$@"; return $?;;
  esac
  local FWD_HOST="${1:-=}"; shift
  case "$FWD_HOST" in
    = ) FWD_HOST='127.0.0.1';;
  esac
  local FWD_PORT="${1:-=}"; shift
  case "$FWD_PORT" in
    = ) FWD_PORT="$LSN_PORT";;
    [+-][0-9]* ) let FWD_PORT="$LSN_PORT$FWD_PORT";;
  esac

  local PF_BASECMD=(
    ncat.exe
    )
  case "$FWD_HOST" in
    *[^0-9.]* ) ;;
    * ) PF_BASECMD+=( --nodns );;
  esac

  local PF_CMD=(
    "${PF_BASECMD[@]}"
    --idle-timeout 330
    "$FWD_HOST" "$FWD_PORT"
    )

  PF_CMD=(
    "${PF_BASECMD[@]}"
    --listen "$LSN_PORT" --keep-open
    --wait 5
    --sh-exec "${PF_CMD[*]}"
    )

  exec "${PF_CMD[@]}" |& logger --stderr --tag "portfwd:$LSN_PORT"
}










portfwd "$@"; exit $?
