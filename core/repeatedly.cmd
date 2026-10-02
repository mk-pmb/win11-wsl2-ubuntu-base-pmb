@echo off
:: -*- coding: latin-1, tab-width: 2 -*-

::  arg 1: Repeat delay in seconds
::  args 2..9: Command to be repeated
::  Unfortunately, `shift` doesn't affect `%*`,
::  so we have an effective limit of 8 args.

::  One of the usecases for `repeatedly.cmd` is to auto-restart stuff after
::  you hard-reset or rebase the git repo or replace its files with the
::  latest tarball. With all of these operations, especially if they fail
::  midway, you may encounter an intermediate state where none of the usual
::  batch files exist on disk.

::  In earlier versions, we had a `:forever` label and a `goto forever`
::  command inside the loop. But `goto` will make cmd.exe re-read the
::  batch file, thus making it fail if the batch file is deleted.

::  Instead, we have to force a situation where cmd.exe pauses parsing
::  inside a line and will never have an opportunity to continue reading
::  that line. The closing parens of the for loop body should already
::  accomplish this. Appending another command in the same line gives
::  double assurance.

for /l %%i in (0,0,1) do (
  call %2 %3 %4 %5 %6 %7 %8 %9
  ping.exe -n %1 127.0.0.1 >nul: 2>&1
) & echo Exotic control flow: Infinite loop quit?!>&2
