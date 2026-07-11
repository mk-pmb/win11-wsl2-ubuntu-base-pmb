#!/bin/sed -nrf
# -*- coding: utf-8, tab-width: 2 -*-
/^DISPLAY=/p
/^PATH=/p
/^PULSE_/p
/^WAYLAND_/p
/^WSL[0-9]*_/p
/^XDG_/p
