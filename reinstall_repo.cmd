@echo off
:: -*- coding: latin-1, tab-width: 2 -*-
title Reinstalling WUB...
cd /d "%~dp0" || ( echo Failed to chdir!>&2& goto failed )

:: For explanation of the lock files, see `core/keepWslAlive/lockfiles.md`.
if not exist .@local\var\lock\ mkdir .@local\var\lock
( wsl.exe --shutdown && wsl.exe --user root bash -c ^
    "eval $(grep -Fe REPO'=' -A 9009 -- %~nx0 | tr -d '\r')" ^
    -- %* && goto success & goto failed
) 8>.@local\var\lock\wub-instable.lock 9>.@local\var\lock\wub-reinstall.lock
echo.
echo H: Consider: wsl.exe --shutdown
echo E: Failed to obtain lockfile(s) on %COMPUTERNAME%.>&2
goto failed

:failed
echo Reinstall failed on %COMPUTERNAME%.>&2
timeout /t 180
goto end

:success
echo Reinstall succeeded on %COMPUTERNAME%.
timeout /t 30
goto end

export REPO='https://github.com/mk-pmb/win11-wsl2-ubuntu-base-pmb/'
export BRANCH='master'
export UNPACK_TASK='post_unpack'
exec 8<&- 9<&-
while [ "$#" -ge 1 ]; do
  VAL="$1"; shift
  case "$VAL" in
    reex )
      # Approximate hard-reset to experimental branch
      export BRANCH='experimental'
      export UNPACK_TASK='skip'
      VAL=clear;;
  esac
  case "$VAL" in
    clear )
      VAL='clearAwayOldGitFiles'
      echo D: $VAL:
      ./filesys/$VAL.sh;;
    ex ) export BRANCH='experimental';;
    [A-Z]*=* ) export "$VAL";;
    * ) echo E: "Unsupported argument: $VAL" >&2; exit 4;;
  esac
done

export BALL="$REPO/archive/refs/heads/$BRANCH.tar.gz"
echo D: "Gonna download and extract onto $HOSTNAME: $BALL"
( curl --location -- "$BALL" |
  tar --extract --gzip --strip-components=1 --
) && ./core/configureUbuntuAfterReinstall.sh $UNPACK_TASK || (
  echo $'\n'"E: Reinstall failed on $HOSTNAME, rv=$?"
  debian_chroot='reinstall' exec bash -i
)

# Next line's bash no-op doubles as a batch label:
: end
