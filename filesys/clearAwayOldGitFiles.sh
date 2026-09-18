#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function caog_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELF_ABS="$(readlink -m -- "$BASH_SOURCE")"
  local SELF_BFN="$(basename -- "$SELF_ABS" .sh)"

  exec <.gitignore || return $?$(
    echo E: $SELF_BFN: 'Cannot read .gitignore file!' >&2)
  local LIST=()
  local VAL=
  while IFS= read -r VAL; do
    case "$VAL" in
      *' '* | *'#'* ) ;;
      /* ) LIST+=( -o -name "${VAL:1}" );;
    esac
  done
  local DEST_DIR="tmp.$SELF_BFN.$(printf -- '%(%y%m%d-%H%M%S)T' -1)-$$"
  mkdir -- "$DEST_DIR" || true

  exec < <(find -mindepth 1 -maxdepth 1 -xdev \
    -not '(' -false "${LIST[@]}" ')' | sed -re 's!^\./!!')
  readarray -t LIST
  [ -n "${LIST[0]}" ] || return $?$(
    echo E: $SELF_BFN: 'Found no old files!' >&2)
  mv --target-directory="$DEST_DIR" -- "${LIST[@]}" || return $?
}



caog_cli_init "$@"; exit $?
