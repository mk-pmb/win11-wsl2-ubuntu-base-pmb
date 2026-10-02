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
::
::  2026-10-02: Reverting to autorun shortcut because a scheduled task gives
::    no benefit; see discussion in `installTask.deprecated.ps1`. Now the
::    hostLoop bears the primary responsibility.
::
::  NB: Cmd.exe will only pick up hot-replace updates if you overwrite this
::    exact file that cmd.exe already has a file handle on! If you delete
::    or rename it (e.g. reinstall_repo.cmd clearing away the old files),
::    you may no longer be able to patch the alreay-running hostLoop.

: forever
cd /d "%~dp0..\.." || (
  echo Failed to chdir!>&2
  exit /b 3
  goto end
  )
if not exist .@local\var\lock\ mkdir .@local\var\lock
( bash.exe ./core/keepWslAlive/guestStartup.sh on_startup %* ^
    6>.@local\var\lock\wub-hostloop-bash.lock ^
    7>.@local\var\lock\wub-instable.lock ^
    8>.@local\var\lock\wub-keepalive.lock ^
    & timeout /t 30 6>.@local\var\lock\wub-hostloop-wait.lock & goto forever
) 9>.@local\var\lock\wub-hostloop-loop.lock || (
  echo Failed to obtain the loop mutex.>&2
  exit /b 9
  goto end
)

: end
