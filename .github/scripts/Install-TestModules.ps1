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

# Install Pester if not available or update to latest version
if (Get-Module -ListAvailable -Name Pester | Where-Object {$_.Version -ge '5.0.0'}) {
    Write-Host "Pester 5.x is already installed"
} else {
    Write-Host "Installing Pester 5.x"
    Install-Module -Name Pester -Force -SkipPublisherCheck -MinimumVersion 5.0.0
}

# Install ImportExcel module for Export-GlookoZipToXlsx tests
if (Get-Module -ListAvailable -Name ImportExcel) {
    Write-Host "ImportExcel is already installed"
} else {
    Write-Host "Installing ImportExcel"
    Install-Module -Name ImportExcel -Force -SkipPublisherCheck -Scope CurrentUser
}

# Install PSScriptAnalyzer for code quality checks
if (Get-Module -ListAvailable -Name PSScriptAnalyzer) {
    Write-Host "PSScriptAnalyzer is already installed"
} else {
    Write-Host "Installing PSScriptAnalyzer"
    Install-Module -Name PSScriptAnalyzer -Force -SkipPublisherCheck -Scope CurrentUser
}

# Import modules
Import-Module Pester -Force
Import-Module ImportExcel -Force
Import-Module PSScriptAnalyzer -Force

# Display module versions
Write-Host "`nInstalled module versions:"
Get-Module Pester, ImportExcel, PSScriptAnalyzer | Select-Object Name, Version | Format-Table -AutoSize
