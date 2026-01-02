@echo off
rem
rem   This .cmd file is here mainly because it can pass along more
rem   parameters than `wub.cmd` can handle.
rem
rem   I tried for a while to make it work without a separate -File, but
rem   with -Command I couldn't find a way to pass arguments verbatim.
rem
powershell.exe -NoLogo -ExecutionPolicy Bypass -File "%~dpn0.ps1" %*
