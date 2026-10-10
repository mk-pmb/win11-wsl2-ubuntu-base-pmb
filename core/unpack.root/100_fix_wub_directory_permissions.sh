#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
# Calling the file by relative path ensures we are in the WUB directory
# and thus its filename argument `.` works as intended.
cmd.exe /c 'filesys\takeownAndResetAcl.cmd .'
