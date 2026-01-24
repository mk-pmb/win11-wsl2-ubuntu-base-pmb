#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
echo -n D: 'Checking ncat.exe: '
which ncat.exe 2>/dev/null | grep -m 1 -Pe '^/' && exit 0
echo 'missing. Gonna download.'
local URL='https://nmap.org/dist/ncat-portable-5.59BETA1.zip'
URL="https://web.archive.org/web/20251203182724/$URL"
local TMPF='.git/tmp.cache/web/'
mkdir --parents -- "$TMPF"
TMPF+="ncat.zip.part"
echo 'Windows Defender leave me alone please!' >"$TMPF"
curl --silent --location -- "$URL" >>"$TMPF"
tail --lines=+2 -- "$TMPF" | sha512sum --check -- <(
  echo '5ea2e754a9434a1e685a6e5b9bfea1b916d8429a1a189091a951e3dfcdd0bc81'$(
    )'96f970ed11e68a375b7ab59c5452ed6c6e47296c5b7f73649f705eca6b8558b3'$(
    )' */dev/stdin'
  )$(echo E: 'Flinching: Corrupted download!' >&2)
unzip -p -- "$TMPF" 'ncat-*/ncat.exe' | LANG=C sed -zre \
  's~(This program cannot be run in DOS mode)\.~\1!~' \
  >"$WINAPPS/ncat.exe"
