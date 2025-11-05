#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Verifies if the current module checksum matches any published version.

.DESCRIPTION
    This script calculates the checksum of the module in BuildOutput and compares
    it against checksums of all published versions in PowerShell Gallery.
    This helps prevent releasing the same code with just a version bump.

.PARAMETER Force
    Force the release even if the checksum matches a published version.

.PARAMETER ModulePath
    Path to the module directory to check.
    Default: ./BuildOutput

.EXAMPLE
    ./Verify-ModuleChecksum.ps1
    Verifies the module in BuildOutput

.EXAMPLE
    ./Verify-ModuleChecksum.ps1 -Force
    Bypasses checksum verification
#>

[CmdletBinding()]
param(
    [Parameter()]
    [switch]$Force,

    [Parameter()]
    [string]$ModulePath = './BuildOutput'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    Write-Host "Verifying module checksum..." -ForegroundColor Cyan
    
    # Calculate checksum for current module
    Write-Host "Calculating checksum for current module..."
    $currentChecksum = & "$PSScriptRoot/Get-ModuleChecksum.ps1" -ModulePath $ModulePath
    
    if (-not $currentChecksum -or -not $currentChecksum.Checksum) {
        Write-Error "Failed to calculate checksum for current module"
        exit 1
    }
    
    Write-Host "Current module checksum: $($currentChecksum.Checksum)" -ForegroundColor Green
    
    # If Force is specified, skip verification
    if ($Force) {
        Write-Host "Force flag specified - skipping checksum verification" -ForegroundColor Yellow
        Write-Host "✓ Checksum verification bypassed" -ForegroundColor Green
        exit 0
    }
    
    # Find all published versions
    Write-Host "`nChecking published versions in PowerShell Gallery..."
    $publishedVersions = Find-Module -Name Glooko -AllVersions -ErrorAction SilentlyContinue
    
    if (-not $publishedVersions) {
        Write-Host "No published versions found in PowerShell Gallery" -ForegroundColor Yellow
        Write-Host "✓ Checksum verification passed (no published versions to compare)" -ForegroundColor Green
        exit 0
    }
    
    Write-Host "Found $($publishedVersions.Count) published version(s)"
    
    # Download and check each published version
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "GlookoChecksumVerify-$(New-Guid)"
    New-Item -Path $tempDir -ItemType Directory -Force | Out-Null
    
    try {
        $matchFound = $false
        $matchedVersion = $null
        
        foreach ($version in $publishedVersions) {
            Write-Verbose "Checking version $($version.Version)..."
            
            # Save module to temp directory
            Save-Module -Name Glooko -RequiredVersion $version.Version -Path $tempDir -ErrorAction Stop
            
            # Calculate checksum for this version
            # Save-Module creates Glooko/<version>/ structure
            $versionModulePath = Join-Path -Path (Join-Path -Path $tempDir -ChildPath 'Glooko') -ChildPath $version.Version
            $versionChecksum = & "$PSScriptRoot/Get-ModuleChecksum.ps1" -ModulePath $versionModulePath -ErrorAction Stop
            
            Write-Verbose "Version $($version.Version) checksum: $($versionChecksum.Checksum)"
            
            # Compare checksums
            if ($versionChecksum.Checksum -eq $currentChecksum.Checksum) {
                $matchFound = $true
                $matchedVersion = $version.Version
                Write-Host "`n⚠️  CHECKSUM MATCH FOUND!" -ForegroundColor Yellow
                Write-Host "Current module matches published version: $matchedVersion" -ForegroundColor Yellow
                break
            }
            
            # Clean up this version before checking next one
            Remove-Item -Path $versionModulePath -Recurse -Force -ErrorAction SilentlyContinue
        }
        
        if ($matchFound) {
            Write-Host "`nThe module runtime code is identical to version $matchedVersion already published in PowerShell Gallery." -ForegroundColor Red
            Write-Host "Publishing this would create a duplicate with only a version number change." -ForegroundColor Red
            Write-Host "`nOptions:" -ForegroundColor Yellow
            Write-Host "  1. Make code changes to the module runtime files" -ForegroundColor Yellow
            Write-Host "  2. Use -Force flag to bypass this check and publish anyway" -ForegroundColor Yellow
            Write-Host "`nExample: ./Verify-ModuleChecksum.ps1 -Force" -ForegroundColor Cyan
            exit 1
        } else {
            Write-Host "`n✓ Checksum verification passed" -ForegroundColor Green
            Write-Host "Module runtime code differs from all published versions" -ForegroundColor Green
            exit 0
        }
        
    } finally {
        # Clean up temp directory
        if (Test-Path $tempDir) {
            Write-Verbose "Cleaning up temporary directory: $tempDir"
            Remove-Item -Path $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

} catch {
    Write-Error "Failed to verify checksum: $($_.Exception.Message)"
    exit 1
}
