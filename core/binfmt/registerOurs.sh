#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#
# https://en.wikipedia.org/wiki/Binfmt_misc
# https://manpages.ubuntu.com/manpages/resolute/man5/binfmt.d.5.html
#
# ls -l {/etc,/run,/usr/{,local/}lib}/binfmt.d/*.conf
# ls -l /proc/sys/fs/binfmt_misc/
#
# 2026-07-18: Adding /usr/lib/binfmt.d/"$KEY".conf seemed to not have any
#   effect after reboot, so instead we re-register on each startup.

set -e

SELF_ABS="$(readlink -f -- "$BASH_SOURCE")"
REPO_DIR="${SELF_ABS%/core/*}"
REPO_DBN="${REPO_DIR##*/}"
ULL="/usr/local/lib/$REPO_DBN"
[ "$ULL" -ef "$REPO_DIR" ] ||
  echo W: "Not same directory: '$ULL' != '$REPO_DIR'" >&2

cd -- /proc/sys/fs/binfmt_misc

# Unregister previous versions:
echo -1 | tee -- "$REPO_DBN"-* 2>/dev/null || true

VAL="$ULL/core/binfmt/runCmdFile.sh"
for FEXT in bat cmd ; do
  KEY="$REPO_DBN-$FEXT"
  [ -f "$KEY" ] || echo ":$KEY:E::$FEXT::$VAL:" | sudo tee register >/dev/null
done
