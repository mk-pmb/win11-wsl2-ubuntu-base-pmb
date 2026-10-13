#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function caog_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELF_ABS="$(readlink -m -- "$BASH_SOURCE")"
  local APP_NAME='clearAwayOldGitFiles'

  exec <.gitignore || return $?$(
    echo E: $APP_NAME: 'Cannot read .gitignore file!' >&2)
  local LIST=()
  local VAL=
  while IFS= read -r VAL; do
    case "$VAL" in
      *' '* | *'#'* ) ;;
      /* ) LIST+=( -o -name "${VAL:1}" );;
    esac
  done
  local DEST_DIR="tmp.$APP_NAME/$(printf -- '%(%y%m%d-%H%M%S)T' -1)-$$"
  mkdir --parents -- "$DEST_DIR"

  exec < <(find -mindepth 1 -maxdepth 1 -xdev \
    -not '(' -false "${LIST[@]}" ')' | sed -re 's!^\./!!')
  readarray -t LIST
  [ -n "${LIST[0]}" ] || return $?$(
    echo E: $APP_NAME: 'Found no old files!' >&2)
  mv --target-directory="$DEST_DIR" -- "${LIST[@]}" || return $?
}



caog_cli_init "$@"; exit $?
