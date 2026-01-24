#!/bin/sed -nrf
# -*- coding: utf-8, tab-width: 2 -*-
/^[A-Za-z]/!b
/^[^=]+=$/b

# /^DBUS_SESSION_BUS_ADDRESS=/b
/^HOME=/b
/^LANG=/b
/^LANGUAGE=/b
/^LC_=/b
/^LOGNAME=/b
/^NAME=/b
/^PWD=/b
/^SHELL=/b
/^SHLVL=/b
/^TERM=/b

p
