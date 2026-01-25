#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function winget_detect_local_version () {
  case "$*" in
    --test )
      set -- \
        Dummy.404.DoesNotExist \
        Microsoft.Edge \
        OpenJS.NodeJS.LTS \
        Wacom.WacomTabletDriver \
        ;;
  esac
  while [ "$#" -ge 2 ]; do "$FUNCNAME" "$1"; shift; done
  local PKG="$1"
  printf -- '%s\t' "$PKG"
  local OMIT_SOURCE_COLUMN='--source winget'
  local VER="$(winget.exe list $OMIT_SOURCE_COLUMN --exact --id "$PKG" |&
    tr -s '\r\n' '\n' | sed -nre '/^\-{8,}$/{n;p}' | tr -s '\t ' ' ')"
  VER="${VER% }"

  # Assuming that the version numbers do not include the package name (they
  # usually don't), cutting out the package name and everything in front of
  # it should effectively discard all non-version columns:
  case "$VER" in
    *" $PKG "* )
      VER="${VER##*" $PKG "}"
      # Now we either have just the "version" column (i.e. locally installed), or
      # the "version" column and then the "available" column. Discard the latter:
      VER="${VER%% *}"
      ;;
    * ) VER=;;
  esac
  echo "$VER"
}


winget_detect_local_version "$@"; exit $?
