#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
winget.exe search \
  --source "${WINGET_SOURCE:-winget}" \
  --id "$1" \
  --versions |&
  sed -nre '/^\-+\s*$/,${s~\s+~ ~g; s~ (\S+) \S+ ?$~\n\a\1~p}' |
  sed -nre 's~^\a~~p' | sort --version-sort --unique | tail --lines=1 |
  grep . # grep in order to exit non-zero if no version was found.
