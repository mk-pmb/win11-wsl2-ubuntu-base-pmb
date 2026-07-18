#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
export LNK_NAME='Suspend-Screen'
export LNK_PROG='cmd.exe'

UICMD="$LNK_NAME"
# But sometimes the screen is quickly re-activated for unknown reasons,
# so let's make it more stubborn:
UICMD+=' -Repeats 3'
UICMD+=' -IntvSec 30'
# This also gives you an opportunity to pin it to the taskbar if you want.

export LNK_ARGS='/c uictl.cmd "'"$UICMD"'"'
export LNK_ICON='shell32.dll,25' # Screen with moon
wub filesys/lnkFile.installAutorun.sh
