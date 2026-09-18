@echo off
:: -*- coding: latin-1, tab-width: 2 -*-
title Reinstalling WUB...
cd /d "%~dp0" || ( echo Failed to chdir!>&2& goto failed )

:: For explanation of the lock files, see `core/keepWslAlive/lockfiles.md`.
if not exist .@local\var\lock\ mkdir .git\var\lock
( wsl.exe --shutdown && wsl.exe --user root bash -c ^
    "eval $(grep -Fe REPO'=' -A 9009 -- %~nx0 | tr -d '\r')" ^
    -- %* && goto success & goto failed
) 8>.@local\var\lock\wub-instable.lock 9>.@local\var\lock\wub-reinstall.lock
echo Failed to obtain lockfile(s).>&2
goto failed

:failed
echo Reinstall failed.>&2
timeout /t 180
goto end

:success
echo Reinstall succeeded.
timeout /t 30
goto end

export REPO='https://github.com/mk-pmb/win11-wsl2-ubuntu-base-pmb/'
export BRANCH='master'
exec 8<&- 9<&-
while [ "$#" -ge 1 ]; do case "$1" in
  ex ) export BRANCH=experimental;;
  * ) export "$1";;
esac; shift; done

export BALL="$REPO/archive/refs/heads/$BRANCH.tar.gz"
echo D: "Gonna download and extract: $BALL"
( curl --location -- "$BALL" |
  tar --extract --gzip --strip-components=1 --
) && ./core/configureUbuntuAfterReinstall.sh post_unpack || (
  echo $'\n'"E: reinstall failed, rv=$?"
  debian_chroot='reinstall' exec bash -i
)

# Next line's bash no-op doubles as a batch label:
: end
