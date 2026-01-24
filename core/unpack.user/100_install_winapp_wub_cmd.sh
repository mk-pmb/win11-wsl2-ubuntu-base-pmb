#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
[ -n "$WINPATH_REPO" ] || exit $?$(echo E: 'Empty WINPATH_REPO' >&2)
WINAPPS="$MNTPATH_PROFILE/AppData/Local/Microsoft/WindowsApps"
# Win 10: %USERPROFILE%\AppData\Local\Microsoft\WindowsApps is in PATH
( echo '@echo off'
  echo '"'"$WINPATH_REPO"'\wub.cmd" %*'
  echo 'exit /b %ERRORLEVEL%'
) >"$WINAPPS/wub.cmd"
