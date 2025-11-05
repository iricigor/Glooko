#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Publishes the module to PowerShell Gallery.

.DESCRIPTION
    This script publishes the Glooko module to the PowerShell Gallery
    using the provided NuGet API key.

.PARAMETER ModuleVersion
    The version of the module being published.

.PARAMETER NuGetApiKey
    The API key for authenticating with PowerShell Gallery.

.EXAMPLE
    ./Publish-ModuleToGallery.ps1 -ModuleVersion "1.0.0" -NuGetApiKey $env:PSGALLERY_KEY
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ModuleVersion,

    [Parameter(Mandatory)]
    [string]$NuGetApiKey
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Import helper function
. (Join-Path $PSScriptRoot 'Test-ChangelogVersion.ps1')

try {
    Write-Host "Publishing module version $ModuleVersion to PowerShell Gallery..."
    
    # Check if changelog contains this version
    Write-Host "Checking if CHANGELOG.md contains version $ModuleVersion..."
    if (-not (Test-ChangelogVersion -Version $ModuleVersion)) {
        Write-Error "CHANGELOG.md does not contain an entry for version $ModuleVersion. Please update the changelog before publishing."
        exit 1
    }
    Write-Host "Changelog check passed - version $ModuleVersion found in CHANGELOG.md" -ForegroundColor Green
    
    # Check if this version already exists in PowerShell Gallery
    Write-Host "Checking if version $ModuleVersion already exists in PowerShell Gallery..."
    try {
        $existingModule = Find-Module -Name Glooko -RequiredVersion $ModuleVersion -ErrorAction SilentlyContinue
        if ($existingModule) {
            Write-Error "Module version $ModuleVersion already exists in PowerShell Gallery. Please increment the version number before publishing."
            exit 1
        }
        Write-Host "Version check passed - version $ModuleVersion does not exist in PowerShell Gallery"
    } catch {
        # If Find-Module fails for any reason other than "not found", we should still continue
        Write-Verbose "Version check completed (module not found in gallery or check failed)"
    }
    
    # Publish the module from the Glooko subfolder
    Publish-Module -Path ./BuildOutput/Glooko -NuGetApiKey $NuGetApiKey -Verbose -ErrorAction Stop
    Write-Host "Successfully published module version $ModuleVersion to PowerShell Gallery!" -ForegroundColor Green
    
    exit 0

} catch {
    Write-Error "Failed to publish module: $($_.Exception.Message)"
    exit 1
}
