#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
UNSAFE="$*"
UNSAFE="${UNSAFE//[A-Za-z0-9_+@.:= -]/}"
UNSAFE="${UNSAFE//'/'/}"
[ -z "$UNSAFE" ] || exit 11$(echo E: >&2 \
  'You invoked the `wub.cmd` stub from inside a linux shell,' \
  'but the arguments given contain characters that currently we' \
  "cannot quote properly, so you'll have to invoke it via "'`cmd.exe`.')
exec cmd.exe /c "wub.cmd $*"; exit $?
