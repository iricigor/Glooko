#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Performs a dry run of publishing to PowerShell Gallery.

.DESCRIPTION
    This script verifies the module manifest and displays what would be published
    to PowerShell Gallery without actually publishing.

.PARAMETER ModuleVersion
    The version of the module being published.

.EXAMPLE
    ./Publish-ModuleDryRun.ps1 -ModuleVersion "1.0.0"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ModuleVersion
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    Write-Host "DRY RUN: Would publish module version $ModuleVersion to PowerShell Gallery"
    Write-Host "Module path: ./BuildOutput/Glooko"
    
    # Verify the module manifest
    $manifest = Test-ModuleManifest -Path ./BuildOutput/Glooko/Glooko.psd1
    Write-Host "Module Name: $($manifest.Name)"
    Write-Host "Module Version: $($manifest.Version)"
    Write-Host "Module Description: $($manifest.Description)"
    Write-Host "Module Author: $($manifest.Author)"
    Write-Host "Module Functions: $($manifest.ExportedFunctions.Keys -join ', ')"
    
    Write-Host "`nDRY RUN COMPLETE - No actual publishing performed"
    
    exit 0

} catch {
    Write-Error "Dry run failed: $($_.Exception.Message)"
    exit 1
}
