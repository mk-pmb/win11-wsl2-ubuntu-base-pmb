#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function rere_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local RERE_SELF="$(readlink -m -- "$BASH_SOURCE")"
  local WUB_REPO_DIR="${RERE_SELF%/*/*}"
  RERE_SELF="${RERE_SELF:${#WUB_REPO_DIR}+1}"
  [ -n "$USER" ] || local USER="$(whoami)"
  cd -- "$WUB_REPO_DIR" || return $?
  export WUB_REPO_DIR
  rere_"$@" || return $?
}


function rere_post_unpack () {
  [[ "$HOSTNAME" == [a-z]* ]] || return 4$(
    echo E: "Flinching: Hostname doesn't start with lowercase letter!" >&2)
  [ "${HOSTNAME/[A-Z]/}" == "$HOSTNAME" ] || return 4$(
    echo E: "Flinching: Hostname contains uppercase letter!" >&2)

  echo
  ./core/runParts.sh core/unpack.root 'Unpack root parts' || return $?
  echo

  local WINPATH_WINDIR=
  rere_detect_windir || return $?

  # Earlier versions had used `wsl.exe` only for `whoami`, to detect the
  # default username and then `sudo` to it. However, with `sudo` we'd lose
  # the capability for running `.exe` files, so instead, we'll have to run
  # the entire user stage in another instance of `wsl.exe`.
  wsl.exe ./"$RERE_SELF" unpack_as_user \
    WINPATH_WINDIR="$WINPATH_WINDIR" \
    || return $?
}


function rere_detect_windir () {
  local VAL="$(cmd.exe /c echo %WINDIR% 2>&1)"
  VAL="${VAL%$'\r'}"
  case "${VAL,,}" in
    [a-z]:'\'* ) ;;
    *': exec format error' )
      echo E: "Cannot detect %WINDIR%:${VAL##*:}" \
        '=> WSL bug (https://github.com/microsoft/WSL/issues/13885).' \
        'As a work-around, please run `wsl.exe --shutdown` and retry.' >&2
      return 4;;
    * )
      echo E: "Cannot detect %WINDIR%: Unknown error: $VAL" >&2
      return 4;;
  esac
  WINPATH_WINDIR="$VAL"
}


function rere_unpack_as_user () {
  exec &> >(tee -- "tmp.${FUNCNAME#*_}.log")
  local RP_TITLE='Unpack user parts'
  ./core/runParts.sh --headline "$RP_TITLE" 'Detected paths:'
  [ "$#" == 0 ] || local "$@"
  local WINPATH_REPO="$(wslpath -aw .)"
  [ -n "${WINPATH_REPO%.}" ] || return 4$(
    echo E: 'Cannot detect WINPATH_REPO' >&2)
  local WINPATH_PROFILE="$(cmd.exe /c echo %USERPROFILE% | tr -d '\r')"
  local MNTPATH_PROFILE="$(wslpath -u "$WINPATH_PROFILE")"

  # Display and export all local variables.
  local VARS="$(local -p | sed -nre 's~^declare -\S* ([A-Z0-9_]+=)~\1~p' |
    sort --version-sort)"
  echo D: "${VARS//$'\n'/; }"
  export $(echo "$VARS" | cut -d = -sf 1)

  ./core/runParts.sh core/unpack.user "$RP_TITLE" || return $?

  echo
  echo D: 'Post-install configuration completed successfully.'
  # debian_chroot='reinstalled' bash -i
}













rere_cli_init "$@"; exit $?
