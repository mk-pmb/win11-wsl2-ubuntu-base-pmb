@echo off
:: -*- coding: latin-1, tab-width: 2 -*-
del "tmp.%~n0.reg" 2>nul:
sed -nre "s~\r~~g; s~^\[~\n&~p; /^\x22|^@/p" -- *.reg ^
  | sed -re "1s~^~REGEDIT4\n~; $s~$~\n~" >"tmp.%~n0.new"
ren "tmp.%~n0.new" "tmp.%~n0.reg"
