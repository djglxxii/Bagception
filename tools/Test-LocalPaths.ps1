[CmdletBinding()]
param()

Import-Module (Join-Path $PSScriptRoot "BG3Tools.psm1") -Force

Get-BG3Paths -Validate | Format-List
