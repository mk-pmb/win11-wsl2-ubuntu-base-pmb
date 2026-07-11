#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function libdir_gits_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELF_ABS="$(readlink -m -- "$BASH_SOURCE")"
  local WUB_DBN="${WUB_REPO_DIR##*/}"
  ln --symbolic --no-clobber --target-directory="$HOME"/lib/ -- "$WUB_DBN"

  local DEST="$HOME/.config/bash/local.rcd/r10_wsl2_interop.sh"
  mkdir --parents -- "${DEST%/*}"
  echo 'eval "$(wub core/wslSessionEnvVars/merge.sh)"' >"$DEST"
}










libdir_gits_cli_init "$@"; exit $?
