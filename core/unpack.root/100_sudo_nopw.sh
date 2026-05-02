#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#
# Password prompt for sudo is useless in WSL2, because anyone with a shell
# can run `/mnt/c/Windows/System32/wsl.exe -d Ubuntu -u root` anyway.
#
set -e
NOPW='/etc/sudoers.d/nopw-groups'
echo -n D: "Ensure $NOPW: "
[ -f "$NOPW" ] || wsl.exe --user root sh \
  -c 'echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL"'" >>$NOPW"
echo done.
