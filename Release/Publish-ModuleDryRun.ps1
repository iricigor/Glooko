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

# Import helper function
. (Join-Path $PSScriptRoot '..' 'Private' 'Test-ChangelogVersion.ps1')

try {
    Write-Host "DRY RUN: Would publish module version $ModuleVersion to PowerShell Gallery"
    Write-Host "Module path: ./BuildOutput/Glooko"
    
    # Check if changelog contains this version
    Write-Host "`nChecking if CHANGELOG.md contains version $ModuleVersion..."
    if (-not (Test-ChangelogVersion -Version $ModuleVersion)) {
        Write-Warning "CHANGELOG.md does not contain an entry for version $ModuleVersion!"
        Write-Warning "You must update the changelog before publishing."
        Write-Host "`nDRY RUN FAILED - Changelog not updated" -ForegroundColor Red
        exit 1
    }
    Write-Host "Changelog check passed - version $ModuleVersion found in CHANGELOG.md" -ForegroundColor Green
    
    # Verify the module manifest
    $manifest = Test-ModuleManifest -Path ./BuildOutput/Glooko/Glooko.psd1
    Write-Host "Module Name: $($manifest.Name)"
    Write-Host "Module Version: $($manifest.Version)"
    Write-Host "Module Description: $($manifest.Description)"
    Write-Host "Module Author: $($manifest.Author)"
    Write-Host "Module Functions: $($manifest.ExportedFunctions.Keys -join ', ')"
    
    # Check if this version already exists in PowerShell Gallery
    Write-Host "`nChecking if version $ModuleVersion already exists in PowerShell Gallery..."
    try {
        $existingModule = Find-Module -Name Glooko -RequiredVersion $ModuleVersion -ErrorAction SilentlyContinue
        if ($existingModule) {
            Write-Warning "Version $ModuleVersion already exists in PowerShell Gallery!"
            Write-Warning "You must increment the version number before publishing."
            Write-Host "`nDRY RUN FAILED - Version already exists" -ForegroundColor Red
            exit 1
        }
        Write-Host "Version check passed - version $ModuleVersion does not exist in PowerShell Gallery" -ForegroundColor Green
    } catch {
        Write-Verbose "Version check completed (module not found in gallery or check failed)"
    }
    
    Write-Host "`nDRY RUN COMPLETE - No actual publishing performed" -ForegroundColor Green
    Write-Host "Ready to publish version $ModuleVersion" -ForegroundColor Green
    
    exit 0

} catch {
    Write-Error "Dry run failed: $($_.Exception.Message)"
    exit 1
}
