@echo off
:: -*- coding: latin-1, tab-width: 2 -*-
title Reinstalling WUB...
cd /d "%~dp0" & wsl.exe --shutdown & wsl.exe --user root bash -c ^
  "eval $(grep -Fe REPO'=' -A 9009 -- %~nx0 | tr -d '\r')" -- %*
echo.
pause
goto end

export REPO='https://github.com/mk-pmb/win11-wsl2-ubuntu-base-pmb/'
export BRANCH='master'
while [ "$#" -ge 1 ]; do export "$1"; shift; done

export BALL="$REPO/archive/refs/heads/$BRANCH.tar.gz"
echo D: "Gonna download and extract: $BALL"
( curl --location -- "$BALL" |
  tar --extract --gzip --strip-components=1 --
) && ./core/configureUbuntuAfterReinstall.sh post_unpack || (
  echo $'\n'"E: reinstall failed, rv=$?"
  debian_chroot='reinstall' exec bash -i
)

: end
