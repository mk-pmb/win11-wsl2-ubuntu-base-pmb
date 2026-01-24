#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function runparts () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local PARTS_DIR="$1"; shift
  local GROUP_TITLE="$1"; shift
  case "$GROUP_TITLE" in
    *$'\n'* ) ;;
    * ) GROUP_TITLE=$'==== '"$GROUP_TITLE"$': \n ====';;
  esac
  case "$PARTS_DIR" in
    --headline | -H ) echo "${GROUP_TITLE//$'\n'/"$*"}"; return $?;;
  esac
  PARTS_DIR="${PARTS_DIR%/}"
  case "$PARTS_DIR" in
    . ) ;;
    '' ) echo E: 'PARTS_DIR can neither be empty nor /.' >&2; return 4;;
    /* ) ;;
    * ) PARTS_DIR="$PWD/$PARTS_DIR";;
  esac
  local PART= TITLE=
  for PART in "$PARTS_DIR"/[0-9][0-9]*; do
    [ -f "$PART" ] || continue
    [ -x "$PART" ] || continue
    TITLE="$(basename -- "$PART")"
    TITLE="${TITLE%.sh}"
    echo "${GROUP_TITLE//$'\n'/"$TITLE"}"
    "$PART" || return $?$(echo E: "runparts part failed (rv=$?): $PART" >&2)
    echo
  done
  echo "${GROUP_TITLE//$'\n'/Done.}"
}


runparts "$@"; exit $?
