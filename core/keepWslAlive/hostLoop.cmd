@echo off
:: -*- coding: latin-1, tab-width: 2 -*-
::
::  Sometimes, WSL seems to stop unexpectedly, despite the guest's very long
::  sleep task. With WSL stopped, we lose remote SSH access to the interactive
::  desktop session. So we need something inside the desktop session that can
::  auto-restart WSL.
::
::  A Windows scheduled task should be quite a robust mechanism for that.
::  However, if WUB is in a transient state and not ready to run (e.g. during
::  updates), a task could cause unwanted noise in the Windows event logs.
::  To reduce that noise, this script acts as an intermediate layer.
::
::  However, I then found that a scheduled task gives no benefit,
::  see discussion in `installTask.deprecated.ps1`.
::  Thus I revert to autorun shortcut.
::  Now the hostLoop bears the primary responsibility.

cd /d "%~dp0..\.." || (
  echo Failed to chdir!>&2
  exit /b 3
  goto end
  )
if not exist .@local\var\lock\ mkdir .@local\var\lock

for /l %%i in (0,0,1) do (
  :: See `core/repeatedly.cmd` for why we use `for /l`.
  :: Do not use bash.exe: Saves some characters but seems to be deprecated:
  :: > * `bash.exe` has been replaced with `wsl.exe`.
  :: @ github.com/MicrosoftDocs/WSL/blob/a1473a69/WSL/troubleshooting.md
  wsl.exe bash core/keepWslAlive/guestStartup.sh on_startup %* ^
    6>.@local\var\lock\wub-hostloop-bash.lock ^
    7>.@local\var\lock\wub-instable.lock ^
    8>.@local\var\lock\wub-keepalive.lock ^
    & ping.exe -n 30 127.0.0.1 >nul: 2>&1 ^
    6>.@local\var\lock\wub-hostloop-wait.lock ^
) 9>.@local\var\lock\wub-hostloop-loop.lock || (
  echo Failed to obtain the loop mutex.>&2
  exit /b 9
  goto end
)

:: Jumping to end label may be fragile if this file has been replaced.
:: But it's only a fallback meachnism for when `exit /b` fails, and in
:: that case, we already have exotic control flow anyway, so goto is
:: probably the best remaining damage control mechanism.
: end
