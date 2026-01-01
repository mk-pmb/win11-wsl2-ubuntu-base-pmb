# -*- coding: utf-8, tab-width: 2 -*-

try {
  $spf = (New-Object -ComObject WScript.Shell).SpecialFolders
} catch {
  Write-Warning 'Failed to import WScript.Shell.'
}

$render = {
  param ( [string]$OrigPath )
  $parts = $OrigPath.Split('\')
  if ($parts.Count -ge 2 -and $parts[0] -eq '@:') {
    $null, $where, $sub = $parts
    $where = try { $spf.Item($where) } catch { $null }
    if (!$where) { return '' }
    if ($parts.Length -eq 2) { return $where }
    return ((@($where) + $sub) -Join '\')
  }
  return $OrigPath
}

if ($args.Length -eq 1) {
  if ($args[0] -eq '-RenderFunc') { return $render }
}

foreach ($arg in $args) { Write-Output(& $render $arg) }
