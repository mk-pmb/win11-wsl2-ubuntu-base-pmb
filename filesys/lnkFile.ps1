# -*- coding: utf-8, tab-width: 2 -*-

$resolveSpecialFolders = . ($PSScriptRoot +
  '/csidl/resolveSpecialFolders.ps1') -RenderFunc

try {
  $winShell = New-Object -ComObject WScript.Shell
} catch {
  Write-Warning 'Failed to import WScript.Shell.'
}


function Init-DefaultProps () {
  return [ordered]@{
    prog = ''
    args = ''
    icon = ''
    winStyle = ''
    workDir  = ''
  }
}


$lnkProps = Init-DefaultProps
$cliState = @{
  jsonFile = ''
  lnkFile = ''
}
$cliActions = @{}


function Optimize-LoadedProps () {
  try { $lnkProps.winStyle = [int]$lnkProps.winStyle } catch {}
  if ($lnkProps.winStyle -eq 3) { $lnkProps.winStyle = 'max' }
  if ($lnkProps.winStyle -eq 7) { $lnkProps.winStyle = 'min' }
}


$cliActions.reset = { $lnkProps = Init-DefaultProps }


$cliActions.readJson = {
  $fromFile = & $resolveSpecialFolders $cliState.jsonFile
  $data = Get-Content -Path $fromFileFile -Encoding utf8
  Import-LnkJson -Data $data -SourceDescr ('file ' + $fromFile)
}


function Import-LnkJson () {
  param ( [string]$Data, [string]$SourceDescr )
  $Data = ( $Data | ConvertFrom-Json )
  # $lnkProps [ordered]
  $trace = ' in JSON from ' + $SourceDescr
  foreach ($key in $Data) {
    $val = $Data[$key]
    if ($val -eq $null) { continue }
    if ($key -in $lnkProps) {
      $lnkProps[$key] = $val
    } else {
      Write-Warning ('W: Unsupported key "' + $key + '"' + $trace)
    }
  }
  Optimize-LoadedProps
}


$cliActions.saveJson = {
  $destFile = & $resolveSpecialFolders $cliState.jsonFile
  $lnkProps | ConvertTo-Json -Depth 5 | Out-File $destFile -Encoding utf8
}


$cliActions.dumpJson = { $lnkProps | ConvertTo-Json -Depth 5 }
$cliActions.dumpJsonLine = { $lnkProps | ConvertTo-Json -Depth 5 -Compress }


$cliActions.readLnk = {
  $srcFile = & $resolveSpecialFolders $cliState.lnkFile
  $lnkFile = $winShell.CreateShortcut($srcFile)
  $lnkProps.prog  = $lnkFile.TargetPath
  $lnkProps.args  = $lnkFile.Arguments
  $lnkProps.icon  = $lnkFile.IconLocation
  $lnkProps.winStyle  = $lnkFile.WindowStyle
  $lnkProps.workDir   = $lnkFile.WorkingDirectory
  Optimize-LoadedProps
}


$cliActions.saveLnk = {
  $destFile = & $resolveSpecialFolders $cliState.lnkFile
  $lnkFile = $winShell.CreateShortcut($destFile)
  $lnkFile.TargetPath   = $lnkProps.prog
  $lnkFile.Arguments    = $lnkProps.args
  $lnkFile.IconLocation = $lnkProps.icon

  $val = $lnkProps.winStyle;
  if ($val) {
    if ($val -eq 'max') { $val = 3 }
    if ($val -eq 'min') { $val = 7 }
    $lnkFile.WindowStyle = $val
  }

  $lnkFile.WorkingDirectory = $lnkProps.workDir
  $lnkFile.Save()
}


function Process-AllArguments () {
  param ( [array]$todo )
  while ($todo.Length -ge 1) {
    $nx, $todo = $todo
    if ($nx -eq 'fromJson') {
      $nx, $todo = $todo
      Import-LnkJson -Data $nx -SourceDescr 'CLI argument'
      continue
    }
    if ($cliActions.ContainsKey($nx)) {
      & $cliActions[$nx]
      continue
    }
    if ($cliState.ContainsKey($nx)) {
      $cliState[$nx], $todo = $todo
      continue
    }
    if ($lnkProps.Contains($nx)) {
      $lnkProps[$nx], $todo = $todo
      Optimize-LoadedProps
      continue
    }
    throw [ArgumentException]"Unsupported CLI argument: $nx"
  }
}












Process-AllArguments $args
