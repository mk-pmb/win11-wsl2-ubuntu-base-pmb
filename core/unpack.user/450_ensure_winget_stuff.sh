#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function ewgs_cli_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local PKG_WANT=(
    # item format: `<installer>:<exe_name>:<package_name>`
    #   * `installer` defaults to `winget`.

    # Important infrastructure first.
    :choco:Chocolatey.Chocolatey
    :node:OpenJS.NodeJS.LTS   # for npm

    # Less important stuff

    # We can't easily use choco because it would require UAC. :-(
    # choco:pythonw3:python3    # for pip3
    # choco:perl:strawberryperl
    )
  local PKG_MISS=()
  local OUTDATED_PATH=
  STRICTNESS=W ewgs_check_missing || true
  PKG_WANT=( "${PKG_MISS[@]}" )
  [ "${#PKG_WANT[@]}" -ge 1 ] || return 0
  ewgs_each_pkg ewgs_install_one_pkg || return $?
  STRICTNESS=E ewgs_check_missing || return $?
}


function ewgs_check_missing () {
  echo D: 'Checking for missing packages:'
  PKG_MISS=()
  local MISSING_PROGS=
  ewgs_each_pkg ewgs_check_missing__one_pkg || return $?
  if [ -n "$OUTDATED_PATH" ] && [ "$STRICTNESS" == E ]; then
    echo E: "WSL's PATH env var seems outdated." \
      'Search for `ERR_OUTDATED_WSL_PATH` in `README.md`.' \
      "The affected programs are:$OUTDATED_PATH" >&2
    return 4
  fi
  if [ -z "$MISSING_PROGS" ]; then
    echo D: 'Found all required programs. Nothing to do.'
    return 0
  fi
  echo $STRICTNESS: "Missing programs:$MISSING_PROGS" >&2
  [ "$STRICTNESS" == W ] && return 0
  return 4
}


function ewgs_each_pkg () {
  [ "${#PKG_WANT[@]}" -ge 1 ] || return 0
  local PKG_NTH=0 PKG_SPEC= INSTALLER= PKG_PROG= PKG_NAME=
  for PKG_SPEC in "${PKG_WANT[@]}"; do
    PKG_NAME="$PKG_SPEC"
    (( PKG_NTH += 1 ))
    INSTALLER="${PKG_NAME%%:*}"; PKG_NAME="${PKG_NAME#*:}"
    [ -n "$INSTALLER" ] || INSTALLER='winget'
    PKG_PROG="${PKG_NAME%%:*}"; PKG_NAME="${PKG_NAME#*:}"
    [ -n "$PKG_NAME" ] || return 8$(
      echo E: $FUNCNAME: "Empty package name #$PKG_NTH" >&2)
    "$@" || return $?$(echo E: $FUNCNAME: >&2 \
      "$* failed (rv=$?) for #$PKG_NTH $PKG_NAME")
  done
}


function ewgs_check_missing__one_pkg () {
  printf -- 'D:   • %s?\t' "$PKG_PROG"
  local PKG_VER="$(cmd.exe /c "$PKG_PROG.exe --version" |&
    grep -m 1 -Pe '\S' | tr -d '\r')"
  case "$PKG_VER" in
    *[0-9].[0-9]* ) echo "$PKG_VER"; return 0;;
  esac

  MISSING_PROGS+=" $PKG_PROG"
  PKG_VER="$(ewgs_check_pkgver)"
  case "$PKG_VER" in
    *[0-9].[0-9]* )
      [[ "$OUTDATED_PATH " == *" $PKG_PROG "* ]] || OUTDATED_PATH+=" $PKG_PROG"
      printf -- '%s\t' "$PKG_VER"
      echo "in $INSTALLER but PATH seems outdated!";;
    * )
      PKG_MISS+=( "$PKG_SPEC" )
      echo '—';;
  esac

}


function ewgs_check_pkgver () {
  case "$INSTALLER" in
    winget )
      wub core/winGetDetectLocalVersion.sh "$PKG_NAME" | cut -sf 2;;
    choco )
      choco.exe list 2>/dev/null |
        sed -nre 's~^(\S+) ([0-9]\S+)\r?$~< \1 >\2~p' |
        grep -Fe "< $PKG_NAME >" | cut -d '>' -sf 2;;
  esac
}


function ewgs_install_one_pkg () {
  set -- "$INSTALLER.exe" install $PKG_NAME
  echo D: "$PKG_PROG.exe <- $*"
  "$@" || return $?
}









ewgs_cli_main "$@"; exit $?
