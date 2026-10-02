#!/usr/bin/env pwsh
# -*- coding: utf-8, tab-width: 2 -*-
#
# 2026-10-02: We keep this scheduled task installer around as example,
#   but as it turns out, it doesn't actually have any major benefits
#   over a traditional autostart menu entry. On the contrary, a simple
#   autostart entry is much easier to manage for users, so we keep that.


$ErrorActionPreference = 'Stop'
Set-StrictMode -Version 3

$scriptDir = $PSScriptRoot
$taskName = ($scriptDir -split '\\')[-3..-1] -join '\'
$hostLoopCmd = Join-Path $scriptDir 'hostLoop.cmd'

$action = New-ScheduledTaskAction -Execute $hostLoopCmd
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
$settings = New-ScheduledTaskSettingsSet `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit ([TimeSpan]::Zero) # 0 = no limit

$settings.DisallowStartIfOnBatteries = $false
$settings.StopIfGoingOnBatteries = $false
$settings.DisallowStartOnRemoteAppSession = $true

$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME `
  -LogonType Interactive -RunLevel Limited

Register-ScheduledTask `
    -TaskName $taskName `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -Principal $principal `
    -Force
