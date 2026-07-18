#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
export LNK_NAME='Start WSL2 Ubuntu'
export LNK_PROG='cmd.exe'
export LNK_ARGS='/c wub.cmd core/runHide bash.exe wub core/keepWslAlive on_startup'
export LNK_ICON='pifmgr.dll,32' # Running rabbit
wub filesys/lnkFile.installAutorun.sh
</dev/null setsid "$PROG" $ARGS &>/dev/null & disown $!
