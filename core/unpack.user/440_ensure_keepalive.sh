#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
echo D: "Install the keep-alive autorun shortcut:"
PROG='wub.cmd'
ARGS='core/runHide bash.exe wub core/keepWslAlive on_startup'
wub filesys/lnkFile prog "$PROG" args "$ARGS" \
  lnkFile '@:\Startup\Start WSL2 Ubuntu.lnk' icon 'pifmgr.dll,32' \
  winStyle min saveLnk
"$PROG" $ARGS
