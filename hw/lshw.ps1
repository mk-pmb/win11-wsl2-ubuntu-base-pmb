#!/usr/bin/env pwsh
# -*- coding: utf-8, tab-width: 2 -*-
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3
Get-PnpDevice | Where-Object { $_.Status -eq 'OK' } |
  ForEach-Object { ($_.InstanceId, $_.Class, $_.FriendlyName) -join [char]9 }
