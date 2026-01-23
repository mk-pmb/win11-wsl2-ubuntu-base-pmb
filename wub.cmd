@echo off
: ; echo E: "You are trying to run $0 in a linux shell ($SHELL)!"; exit 11
:: -*- coding: latin-1, tab-width: 2 -*-

: init
  if "%~9" neq "" (
    echo E: Too many arguments. ^
      The wub.cmd command can only use up to 8 CLI arguments safely. ^
      In some situations you can instead use "wsl.exe wub". ^
      Your 9th argument is: %9
    exit /b 4
    )
  call :find_impl %1 || exit /b %ERRORLEVEL%
  set ERRORLEVEL=0
  %impl% %2 %3 %4 %5 %6 %7 %8 %9 || exit /b %ERRORLEVEL%
  ::  ^-- NB: The %2..%9 are because the `shift` operation doesn't update %*.
goto end


: find_impl
  set impl=%1
  if not defined impl (
    set impl=powershell.exe -NoLogo
    cd /d "%~dp0"
    goto end
    )
  if "%~1"=="--show-basedir" (
    echo %~dp0
    goto end
    )
  if "%~x1"==".exe" (
    set impl=%1
    cd /d "%~dp0"
    goto end
    )
  set impl=
  for %%s in (
    %~1
    %~1\%~n1.wub-cli
    %~1\%~n1
    %~1\wub-cli
    ) do call :find_impl__nofext %%s
  if defined impl goto end
  echo E: Unsupported subcommand: %~1
exit /b 4


: find_impl__nofext
  call :find_impl__eachfext "%~dp0%~1"
  for %%e in ( ps1 sh cmd ) do call :find_impl__eachfext "%~dp0%~1.%%e"
goto end

: find_impl__eachfext
  if defined impl goto end
  if not exist %1 goto end
  set impl=%1
  if "%~x1"==".ps1" set impl=powershell.exe -NoLogo -ExecutionPolicy Bypass -File %impl%
  if "%~x1"==".sh" set impl=wsl.exe wub %impl%
goto end



















: end
