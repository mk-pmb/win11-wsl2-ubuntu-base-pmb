#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e

echo D: "Prevent syslog spam from the wsl-pro-service daemon:"
# https://github.com/microsoft/WSL/issues/12992
systemctl disable wsl-pro.service
systemctl stop wsl-pro.service
