#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
[ "$1" != -- ] || shift
while [ "$#" -ge 1 ]; do
  echo -n "'$1'="
  wub filesys/lnkFile.ps1 lnkFile "$1" readLnk dumpJson
  shift
done
