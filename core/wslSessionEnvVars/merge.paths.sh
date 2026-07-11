#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function merge_paths_var () {
  local ACCUM= TODO= VAL=
  while [ "$#" -ge 1 ]; do
    case "$1" in
      :* | /* ) TODO+="$1:"; shift; continue;;
    esac
    echo E: $FUNCNAME: "Unsupported argument: $1" >&2
    return 4
  done
  while [ -n "$TODO" ]; do
    VAL="${TODO%%:*}"; TODO="${TODO:${#VAL}+1}"
    VAL="${VAL%/}"
    [ -n "$VAL" ] || continue
    [ "${ACCUM/:$VAL:/}" == "$ACCUM" ] || continue # already in ACCUM
    true [ -d "$VAL" ] || continue$(echo W: $FUNCNAME: >&2 \
      "Skipping PATH directory because it does not exist: $VAL")
    ACCUM+=":$VAL"
  done
  echo "${ACCUM:1}"
}










merge_paths_var "$@"; exit $?
