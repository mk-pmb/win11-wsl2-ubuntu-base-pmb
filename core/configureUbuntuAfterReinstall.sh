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
  local "$@"
  local WINPATH_REPO="$(wslpath -aw .)"
  [ -n "${WINPATH_REPO%.}" ] || return 4$(
    echo E: 'Cannot detect WINPATH_REPO' >&2)
  local WINPATH_PROFILE="$(cmd.exe /c echo %USERPROFILE% | tr -d '\r')"
  local MNTPATH_PROFILE="$(wslpath -u "$WINPATH_PROFILE")"
  local -p; echo

  echo D: "Install the wub.cmd command:"
  local WINAPPS="$MNTPATH_PROFILE/AppData/Local/Microsoft/WindowsApps"
  # Win 10: %USERPROFILE%\AppData\Local\Microsoft\WindowsApps is in PATH
  ( echo '@echo off'
    echo '"'"$WINPATH_REPO"'\wub.cmd" %*'
    echo 'exit /b %ERRORLEVEL%'
  ) >"$WINAPPS/wub.cmd" || return $?

  rere_add_default_ssh_authorized_keys || return $?
  echo
  ./core/runParts.sh core/unpack.user 'Unpack user parts' || return $?
  echo
  rere_ensure_keepalive || return $?

  echo
  echo D: 'Post-install configuration completed successfully.'
  # debian_chroot='reinstalled' bash -i
}


function rere_add_default_ssh_authorized_keys () {
  echo D: 'Ensuring default SSH keys:'
  local CFG_AK="$HOME"/.config/ssh
  mkdir --parents -- "$CFG_AK"
  [ -L "$HOME"/.ssh ] || ln --symbolic --no-target-directory \
    -- .config/ssh "$HOME"/.ssh || return $?$(
    echo E: 'Failed to create ~/.ssh symlink!' >&2)
  CFG_AK+='/authorized_keys'
  >>"$CFG_AK" || return $?$(echo E: 'Failed to touch $CFG_AK!' >&2)
  ( LANG=C sed -re 's~^\xEF\xBB\xBF~~;s~\r~~' -- \
    cfg.@.defaults/ssh_authorized_keys.txt \
    2>/dev/null | grep -vFf "$CFG_AK" || true
  ) >>"$CFG_AK" || return $?$(echo E: 'Failed to update $CFG_AK!' >&2)
}


function rere_ensure_keepalive () {
  echo D: "Install the keep-alive autorun shortcut:"
  local PROG='wub.cmd'
  local ARGS='core/runHide bash.exe wub core/keepWslAlive on_startup'
  wub filesys/lnkFile prog "$PROG" args "$ARGS" \
    lnkFile '@:\Startup\Start WSL2 Ubuntu.lnk' icon 'pifmgr.dll,32' \
    winStyle min saveLnk || return $?
  "$PROG" $ARGS || return $?
}













rere_cli_init "$@"; exit $?
