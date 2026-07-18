#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function runbatch () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SRC="$1"; shift
  local ABS="$(readlink -f -- "$SRC")"
  case "$ABS" in
    /mnt/[a-z]/* ) ;;
    * )
      echo E: 'Can only run windows batch files from /mnt/[a-z]/*,' \
        "not '$SRC' = '$ABS'" >&2
      return 4;;
  esac
  case "$(readlink -f .)/" in
    /mnt/[a-z]/* ) ;;
    * ) cd -- /mnt/c || return $?;;
  esac
  SRC="$(wslpath -w -- "$ABS")"
  [ -n "$SRC" ] || return 4$(
    echo E: "WSL failed to find a windows path for '$ABS'" >&2)
  exec cmd.exe /c "$SRC" "$@"
}










runbatch "$@"; exit $?
