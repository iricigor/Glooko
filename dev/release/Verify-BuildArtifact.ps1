#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verifies a build artifact can be loaded as a PowerShell module.

.DESCRIPTION
    This script verifies that a build artifact contains all required files and
    that the module can be successfully imported.

.PARAMETER OutputEnvFile
    Path to the GitHub Actions environment file where the MODULE_VERSION will be saved.

.EXAMPLE
    ./Verify-BuildArtifact.ps1 -OutputEnvFile $env:GITHUB_ENV
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$OutputEnvFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    Write-Host "Verifying build artifact..."
    
    if (-not (Test-Path "BuildOutput/Glooko/Glooko.psd1")) {
        Write-Error "Module manifest not found in BuildOutput/Glooko"
        exit 1
    }
    
    if (-not (Test-Path "BuildOutput/Glooko/BuildInfo.json")) {
        Write-Error "BuildInfo.json not found in BuildOutput/Glooko"
        exit 1
    }
    
    # Read version from BuildInfo
    $buildInfo = Get-Content "BuildOutput/Glooko/BuildInfo.json" | ConvertFrom-Json
    $version = $buildInfo.Version
    
    Write-Host "Module version: $version"
    
    # Test that the module can be imported
    Import-Module ./BuildOutput/Glooko/Glooko.psd1 -Force
    
    $module = Get-Module Glooko
    if (-not $module) {
        Write-Error "Failed to load module"
        exit 1
    }
    
    Write-Host "Module loaded successfully"
    Write-Host "Module version: $($module.Version)"
    Write-Host "Exported functions: $($module.ExportedFunctions.Keys -join ', ')"
    
    # Save version for next step
    "MODULE_VERSION=$version" | Out-File -FilePath $OutputEnvFile -Encoding utf8 -Append
    
    exit 0

} catch {
    Write-Error "Failed to verify build artifact: $($_.Exception.Message)"
    exit 1
}
