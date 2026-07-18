#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-

function install_autorun_lnk () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  [ -n "$LNK_NAME" ] || return 4$(echo E: 'Missing LNK_NAME!' >&2)
  [ -n "$LNK_PROG" ] || return 4$(echo E: 'Missing LNK_PROG!' >&2)
  local LNK_DEST='@:\Startup\'"$LNK_NAME.lnk"
  echo -n D: "Install the '$LNK_NAME' autorun shortcut: "
  [ -n "$LNK_ICON" ] || local LNK_ICON="$LNK_PROG,0"
  wub filesys/lnkFile.ps1 prog "$LNK_PROG" args "$LNK_ARGS" \
    icon "$LNK_ICON" winStyle min lnkFile "$LNK_DEST" saveLnk ||
    return 4$(echo E: "Failed (rv=$?) to create shortcut: $LNK_DEST" >&2)
  echo ok.
}

install_autorun_lnk "$@"; exit $?
