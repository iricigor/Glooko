#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Builds the Glooko PowerShell module artifact with version information.

.DESCRIPTION
    This script creates a module artifact containing only runtime files.
    It manages versioning with major.minor from the module manifest and
    auto-increments the build number.

.PARAMETER OutputPath
    The directory where the build artifact will be created.
    Default: ./BuildOutput

.PARAMETER VersionFile
    Path to the file that tracks the last built version.
    Default: ./.version

.EXAMPLE
    ./Build.ps1
    Builds the module to ./BuildOutput with auto-incremented build number

.EXAMPLE
    ./Build.ps1 -OutputPath ./dist
    Builds the module to ./dist directory
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$OutputPath = './BuildOutput',

    [Parameter()]
    [string]$VersionFile = './.version'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    # Get the script directory (repository root)
    $RepoRoot = $PSScriptRoot
    Write-Verbose "Repository root: $RepoRoot"

    # Read the module manifest to get major.minor version
    $ManifestPath = Join-Path $RepoRoot 'Glooko.psd1'
    if (-not (Test-Path $ManifestPath)) {
        throw "Module manifest not found at: $ManifestPath"
    }
    
    Write-Verbose "Reading module manifest from: $ManifestPath"
    $ManifestContent = Import-PowerShellDataFile -Path $ManifestPath
    $CurrentVersion = $ManifestContent.ModuleVersion
    
    if ($CurrentVersion -notmatch '^\d+\.\d+$') {
        throw "Module version must be in major.minor format (e.g., 1.0), found: $CurrentVersion"
    }
    
    Write-Host "Current module version (major.minor): $CurrentVersion"
    
    # Determine build number
    $BuildNumber = 0
    $VersionFilePath = Join-Path $RepoRoot $VersionFile
    
    if (Test-Path $VersionFilePath) {
        $LastVersion = Get-Content $VersionFilePath -Raw | ConvertFrom-Json
        Write-Verbose "Last built version: $($LastVersion.Version)"
        
        if ($LastVersion.Version -match '^(\d+\.\d+)\.(\d+)$') {
            $LastMajorMinor = $Matches[1]
            $LastBuildNumber = [int]$Matches[2]
            
            if ($LastMajorMinor -eq $CurrentVersion) {
                # Same major.minor, increment build number
                $BuildNumber = $LastBuildNumber + 1
                Write-Host "Incrementing build number from $LastBuildNumber to $BuildNumber"
            } else {
                # Different major.minor, reset build number to 0
                Write-Host "Major.minor version changed from $LastMajorMinor to $CurrentVersion, resetting build number to 0"
            }
        }
    } else {
        Write-Host "No previous version found, starting with build number 0"
    }
    
    $FullVersion = "$CurrentVersion.$BuildNumber"
    Write-Host "Building version: $FullVersion" -ForegroundColor Green
    
    # Create output directory
    $OutputDir = Join-Path $RepoRoot $OutputPath
    if (Test-Path $OutputDir) {
        Write-Verbose "Removing existing output directory: $OutputDir"
        Remove-Item $OutputDir -Recurse -Force
    }
    
    Write-Verbose "Creating output directory: $OutputDir"
    New-Item -Path $OutputDir -ItemType Directory -Force | Out-Null
    
    # Copy runtime files
    Write-Host "Copying runtime files to output directory..."
    
    # Copy Public functions
    $PublicDir = Join-Path $RepoRoot 'Public'
    $OutPublicDir = Join-Path $OutputDir 'Public'
    if (Test-Path $PublicDir) {
        Write-Verbose "Copying Public functions..."
        Copy-Item -Path $PublicDir -Destination $OutPublicDir -Recurse -Force
    }
    
    # Copy Private functions
    $PrivateDir = Join-Path $RepoRoot 'Private'
    $OutPrivateDir = Join-Path $OutputDir 'Private'
    if (Test-Path $PrivateDir) {
        Write-Verbose "Copying Private functions..."
        Copy-Item -Path $PrivateDir -Destination $OutPrivateDir -Recurse -Force
    }
    
    # Copy root module file
    $RootModulePath = Join-Path $RepoRoot 'Glooko.psm1'
    if (Test-Path $RootModulePath) {
        Write-Verbose "Copying root module file..."
        Copy-Item -Path $RootModulePath -Destination $OutputDir -Force
    }
    
    # Copy LICENSE file
    $LicensePath = Join-Path $RepoRoot 'LICENSE'
    if (Test-Path $LicensePath) {
        Write-Verbose "Copying LICENSE file..."
        Copy-Item -Path $LicensePath -Destination $OutputDir -Force
    }
    
    # Copy and update module manifest with full version
    Write-Verbose "Updating module manifest with version $FullVersion..."
    $ManifestOutput = Join-Path $OutputDir 'Glooko.psd1'
    Copy-Item -Path $ManifestPath -Destination $ManifestOutput -Force
    
    # Update the version in the manifest
    $ManifestText = Get-Content $ManifestOutput -Raw
    $ManifestText = $ManifestText -replace "(ModuleVersion\s*=\s*')\d+\.\d+(')", "`${1}$FullVersion`$2"
    Set-Content -Path $ManifestOutput -Value $ManifestText -NoNewline
    
    # Verify the manifest is valid
    try {
        Write-Verbose "Validating updated module manifest..."
        Test-ModuleManifest -Path $ManifestOutput | Out-Null
        Write-Host "Module manifest validation successful" -ForegroundColor Green
    } catch {
        throw "Module manifest validation failed: $($_.Exception.Message)"
    }
    
    # Save version information
    $VersionInfo = @{
        Version = $FullVersion
        BuildDate = (Get-Date).ToString('o')
        MajorMinor = $CurrentVersion
        BuildNumber = $BuildNumber
    }
    
    Write-Verbose "Saving version information to: $VersionFilePath"
    $VersionInfo | ConvertTo-Json | Set-Content -Path $VersionFilePath
    
    # Create a build info file in the output
    $BuildInfoPath = Join-Path $OutputDir 'BuildInfo.json'
    $VersionInfo | ConvertTo-Json | Set-Content -Path $BuildInfoPath
    
    Write-Host "`nBuild completed successfully!" -ForegroundColor Green
    Write-Host "Version: $FullVersion"
    Write-Host "Output: $OutputDir"
    Write-Host "`nArtifact contents:"
    Get-ChildItem -Path $OutputDir -Recurse | Select-Object -ExpandProperty FullName | ForEach-Object {
        Write-Host "  - $($_.Replace($OutputDir, '.'))"
}

# Explicitly exit with success code
exit 0

} catch {
    Write-Error "Build failed: $($_.Exception.Message)"
    exit 1
}
