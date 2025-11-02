#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs required PowerShell modules for testing.

.DESCRIPTION
    This script installs the required PowerShell modules for running tests:
    - Pester 5.x for testing
    - ImportExcel for Export-GlookoZipToXlsx tests
    - PSScriptAnalyzer for code quality checks

.EXAMPLE
    ./.github/scripts/Install-TestModules.ps1
    Installs all required modules
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Dot-source the Install-ModuleVerbose function
. "$PSScriptRoot/Install-ModuleVerbose.ps1"

# Install required modules
Install-ModuleVerbose -Name 'Pester' -MinimumVersion '5.0.0'
Install-ModuleVerbose -Name 'ImportExcel'
Install-ModuleVerbose -Name 'PSScriptAnalyzer'

# Import modules
Import-Module Pester -Force
Import-Module ImportExcel -Force
Import-Module PSScriptAnalyzer -Force

# Display module versions
Write-Host "`nInstalled module versions:"
Get-Module Pester, ImportExcel, PSScriptAnalyzer | Select-Object Name, Version | Format-Table -AutoSize
