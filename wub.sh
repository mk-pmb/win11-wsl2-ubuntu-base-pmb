#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function wub_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local REPO_DIR="$(readlink -m -- "$BASH_SOURCE"/..)"
  case "$1" in
    '' ) set -- pwsh "${@:2}"; cd -- "$REPO_DIR" || return $?;;
    --show-basedir ) echo "$REPO_DIR"; return 0;;
    *.exe ) ;;
    * ) set -- $(wub_find_impl "$1") "${@:2}";;
  esac
  case "$1" in
    pwsh ) set -- $(wub_pwsh_cmd "$1") "${@:2}";;
  esac
  case "$1" in
    powershell.exe )
      [ "${2%.ps1}" == "$2" ] || set -- "$1" -File "${@:2}"
      [ "$2" == -File ] && set -- "$1" -ExecutionPolicy Bypass "$2" "$(
        wslpath -aw -- "$3")" "${@:4}"
      [ "$2" == -NoLogo ] || set -- "$1" -NoLogo "${@:2}"
      ;;
  esac
  exec -- "$@"
}


function wub_find_impl () {
  local PROG="$1"
  local BFN="$(basename -- "$PROG")"
  BFN="${BFN%.*}"
  local CANDIDATES=(
    "$PROG"
    "$PROG"/"$BFN".wub-cli
    "$PROG"/"$BFN"
    "$PROG"/wub-cli
    )
  local MAYBE= FEXT= FULL=
  for MAYBE in "${CANDIDATES[@]}"; do
    for MAYBE in "$REPO_DIR/$MAYBE"{,.ps1,.sh,.cmd} ''; do
      [ -f "$MAYBE" ] || continue
      PROG="$MAYBE"
      break
    done
  done
  case "$PROG" in
    *.cmd ) echo -n 'cmd.exe /c ';;
    *.ps1 ) echo -n 'pwsh -File ';;
  esac
  echo "$PROG"
}


function wub_pwsh_cmd () {
  local EXE='powershell.exe'
  if which $EXE 2>/dev/null | grep -qe '^/'; then
    echo $EXE
  else
    echo pwsh
  fi
}










wub_cli_init "$@"; exit $?
