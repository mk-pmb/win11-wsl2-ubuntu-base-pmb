#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-
s~^ +Insgesamt +Kopiert.*$~&\
               Total    Copied   Skipped   NoMatch     Error LocalOnly~
