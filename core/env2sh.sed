#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-
#
# `github-ci-util-2405-pmb` uses npm:`shq` via npm:`enveval2401-pmb`
# but in these early stages we don't even have node.js available,
# so this sham has to be good enough.
#
/^[A-Za-z0-9_/+,.:=-]+$/b
s~'+~'"&"'~g
s~^([A-Za-z0-9_-]+=|)~\1\n'~
s~$~'~
s~\n'{2}~~
s~'{2}$~~
s~\n~~g
