@echo off
:: Take ownership of and reset permissions on %1 and all its subdirectories

setlocal

set c=takeown.exe
:: /f = set filename:
set c=%c% /f "%~1"
:: /r = recursive
set c=%c% /r
:: /a would set owner to local admins group rather than %UserName%
:: set c=%c% /a
:: /d = decision: yes to all; but the confirmation letter depends on
::      system language settings, so we can't reliably use that.
::      On the other hand, for takeown to work reliably, you need admin
::      privileges anyway, and if you have them, there should be no reason
::      for confirmation for just listing directories.
:: set c=%c% /d y
%c% >NUL:

set c=icacls.exe
:: arg 1 = filename
set c=%c% "%~1"
:: /reset = set defaults
set c=%c% /reset
:: /t = recursive (tree)
set c=%c% /t
:: /c = continue even if errors occurr.
set c=%c% /c
:: /q = quiet on success, so errors won't scroll away as quickly.
set c=%c% /q
%c%

endlocal
