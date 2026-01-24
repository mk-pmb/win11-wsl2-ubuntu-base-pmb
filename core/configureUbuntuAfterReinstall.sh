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
  rere_unpack_as_root || return $?
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


function rere_unpack_as_root () {
  ./core/runParts.sh core/unpack.root 'Unpack root parts' || return $?

  echo D: "Prevent syslog spam from the wsl-pro-service daemon:"
  # https://github.com/microsoft/WSL/issues/12992
  systemctl disable wsl-pro.service || return $?
  systemctl stop wsl-pro.service || return $?

  rere_ensure_apt_pkg || return $?
  rere_set_default_locale || return $?
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
  rere_ensure_ncat || return $?
  rere_ensure_keepalive || return $?

  echo
  echo D: 'Post-install configuration completed successfully.'
  # debian_chroot='reinstalled' bash -i
}


function rere_ensure_apt_pkg () {
  echo -n D: 'Check basic apt packages to install: '
  local LIST=(
    aptitude
    fuse3 # would otherwise be uninstalled when purging snapd.
    nano
    openssh-server
    pv
    screen
    squashfs-tools # would otherwise be uninstalled when purging snapd.
    unzip
    zip
    )
  local ITEM= TODO= APT="env debian_frontend='noninteractive' apt"
  for ITEM in "${LIST[@]}"; do
    [ -f "/usr/share/doc/$ITEM/copyright" ] ||
      TODO+=" ${ITEM%%:*}"
  done
  if [ -z "$TODO" ]; then
    echo 'None missing.'
  else
    echo 'Some packages are missing.'
    echo 'D: Update apt package lists:'
    $APT update || return $?
    echo 'D: Install missing apt packages:'
    $APT install --assume-yes -- $TODO || return $?
    echo 'D: Packages have been installed.'
  fi

  echo -n D: 'Check basic apt packages to remove: '
  LIST=(
    snapd
    # nope, would uninstall sudo. -> # ubuntu-pro-client{,-l10n}
    )
  TODO=
  for ITEM in "${LIST[@]}"; do
    [ -f "/usr/share/doc/$ITEM/copyright" ] || continue
    TODO+=" $ITEM"
  done
  if [ -z "$TODO" ]; then
    echo 'Found none.'
  else
    echo 'Found some.'
    ${APT}itude purge --assume-yes -- $TODO || return $?
    echo 'D: Packages have been purged.'
  fi
}


function rere_ensure_ncat () {
  echo -n D: 'Checking ncat.exe: '
  which ncat.exe 2>/dev/null | grep -m 1 -Pe '^/' && return 0
  echo 'missing. Gonna download.'
  local URL='https://nmap.org/dist/ncat-portable-5.59BETA1.zip'
  URL="https://web.archive.org/web/20251203182724/$URL"
  local TMPF='.git/tmp.cache/web/'
  mkdir --parents -- "$TMPF"
  TMPF+="ncat.zip.part"
  echo 'Windows Defender leave me alone please!' >"$TMPF" || return $?
  curl --silent --location -- "$URL" >>"$TMPF" || return $?
  tail --lines=+2 -- "$TMPF" | sha512sum --check -- <(
    echo '5ea2e754a9434a1e685a6e5b9bfea1b916d8429a1a189091a951e3dfcdd0bc81'$(
      )'96f970ed11e68a375b7ab59c5452ed6c6e47296c5b7f73649f705eca6b8558b3'$(
      )' */dev/stdin'
    ) || return $?$(echo E: 'Flinching: Corrupted download!' >&2)
  unzip -p -- "$TMPF" 'ncat-*/ncat.exe' | LANG=C sed -zre \
    's~(This program cannot be run in DOS mode)\.~\1!~' \
    >"$WINAPPS/ncat.exe" || return $?
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


function rere_set_default_locale () {
  local WIN_LANG="$(powershell.exe Get-WinUserLanguageList |
    sed -nre 's~\r$~~; s!-!_!; s~^LanguageTag\s+:\s+~~p')"
  WIN_LANG="${WIN_LANG%%$'\n'*}"
  case "$WIN_LANG" in
    [a-z][a-z]_[A-Z][A-Z]* ) ;;
    * ) WIN_LANG='en_US';;
  esac
  printf -- '%s="%s.UTF-8"\n' LANG en_US LC_TIME "$WIN_LANG" \
    >/etc/default/locale || return $?
}













rere_cli_init "$@"; exit $?
