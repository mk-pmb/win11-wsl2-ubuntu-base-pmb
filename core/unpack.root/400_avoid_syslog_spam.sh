#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
set -- wsl-pro.service

echo D: "Prevent syslog spam from the $1 daemon:"
# https://github.com/microsoft/WSL/issues/12992

if ! systemctl cat sshd2.service &>/dev/null; then
  echo D: "Seems to not be installed => ignore."
else
  systemctl disable $1
  systemctl stop $1
fi
