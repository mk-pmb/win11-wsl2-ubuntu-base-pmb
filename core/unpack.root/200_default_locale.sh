#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
WIN_LANG="$(powershell.exe Get-WinUserLanguageList |
  sed -nre 's~\r$~~; s!-!_!; s~^LanguageTag\s+:\s+~~p')"
WIN_LANG="${WIN_LANG%%$'\n'*}"
case "$WIN_LANG" in
  [a-z][a-z]_[A-Z][A-Z]* ) ;;
  * ) WIN_LANG='en_US'; echo W: 'Failed to detect Windows locale!';;
esac
printf -- '%s="%s.UTF-8"\n' \
  LANG en_US \
  LC_TIME "$WIN_LANG" \
  >/etc/default/locale
