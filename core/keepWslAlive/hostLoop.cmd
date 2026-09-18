@echo off
:: -*- coding: latin-1, tab-width: 2 -*-
::
::  Sometimes, WSL seems to stop unexpectedly, despite the guest's
::  very long sleep task. With WSL stopped, we lose remote SSH access
::  to the interactive desktop session. So we need something inside the
::  desktop session that can auto-restart WSL.
::  A Windows scheduled task should be quite a robust mechanism for that.
::  However, if WUB is in a transient state and not ready to run (e.g. during
::  updates), a task could cause unwanted noise in the Windows event logs.
::  To reduce that noise, this script acts as an intermediate layer.

: forever
cd /d "%~dp0\..\.." || (
  echo Failed to chdir!>&2
  exit /b 3
  goto end
  )
if not exist .@local\var\lock\ mkdir .git\var\lock
( bash.exe ./core/keepWslAlive/guestStartup.sh on_startup %* ^
    7>.@local\var\lock\wub-instable.lock ^
    8>.@local\var\lock\wub-keepalive.lock ^
    & timeout /t 30 & goto forever
) 9>.@local\var\lock\wub-hostloop.lock || (
  echo Failed to obtain the loop mutex.>&2
  exit /b 9
  goto end
)

: end
