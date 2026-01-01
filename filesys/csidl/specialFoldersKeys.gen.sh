#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#
# I investigated for several hours trying to find a way to enumerate the keys
# from `(New-Object -ComObject WScript.Shell).SpecialFolders` via reflection,
# but couldn't find any.

DOCS_URL='https://learn.microsoft.com/en-us/windows/win32/shell/csidl'
MEMENTO=2025'10'01
MEMENTO="https://web.archive.org/web/$MEMENTO/$DOCS_URL"

KEYS="$(curl --location --silent "$MEMENTO" |
  grep -oPe '<dt>FOLDERID_\w+' | cut -d _ -sf 2 | LANG=C sort -Vu)"
NL=$'\n'
[ "${KEYS##*$NL}" == 'Windows' ] || return 4$(
  echo E: 'Failed to download list.' >&2)

BFN="$(basename -- "$(readlink -f -- "$0")")"
BFN="${BFN%%.*}"
QUOT='"'
APOS="'"
echo "return @($NL'${KEYS//$NL/"',$NL'"}')" >"$BFN".ps1
echo "[$QUOT${KEYS//$NL/$QUOT$NL,$QUOT}$QUOT$NL]" >"$BFN".json
# or: pwsh -Command '.\specialFoldersKeys.ps1 | ConvertTo-Json'
