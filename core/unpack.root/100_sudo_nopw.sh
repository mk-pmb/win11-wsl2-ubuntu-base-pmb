#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
NOPW='/etc/sudoers.d/nopw-groups'
echo -n D: "Ensure $NOPW: "
[ -f "$NOPW" ] || wsl.exe --user root sh \
  -c 'echo "%sudo   ALL=(ALL:ALL) NOPASSWD: ALL"'" >>$NOPW"
echo done.
