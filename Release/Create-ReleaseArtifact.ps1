#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Creates a release artifact zip file containing the module files.

.DESCRIPTION
    This script creates a zip file containing all module files from the build output.
    The zip file is intended to be attached to GitHub releases.

.PARAMETER ModuleVersion
    The version of the module being released.

.PARAMETER OutputPath
    Optional output path for the zip file. Default: ./Glooko-{VERSION}.zip

.EXAMPLE
    ./Create-ReleaseArtifact.ps1 -ModuleVersion "1.0.4"
    Creates Glooko-1.0.4.zip in the current directory

.EXAMPLE
    ./Create-ReleaseArtifact.ps1 -ModuleVersion "1.0.4" -OutputPath "artifacts/release.zip"
    Creates release.zip in the artifacts directory
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ModuleVersion,

    [Parameter()]
    [string]$OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    Write-Host "Creating release artifact zip..."
    
    # Determine output path
    if (-not $OutputPath) {
        $OutputPath = "Glooko-$ModuleVersion.zip"
    }
    
    $modulePath = "BuildOutput/Glooko"
    
    # Verify module path exists
    if (-not (Test-Path $modulePath)) {
        Write-Error "Module path not found: $modulePath"
        exit 1
    }
    
    Write-Verbose "Module path: $modulePath"
    Write-Verbose "Output path: $OutputPath"
    
    # Compress the module files from BuildOutput/Glooko
    Compress-Archive -Path "$modulePath/*" -DestinationPath $OutputPath -Force
    
    Write-Host "Created release artifact: $OutputPath"
    $artifact = Get-Item $OutputPath
    Write-Host "File size: $($artifact.Length) bytes"
    
    # Display artifact info
    $artifact | Select-Object Name, Length, LastWriteTime | Format-List
    
    exit 0

} catch {
    Write-Error "Failed to create release artifact: $($_.Exception.Message)"
    exit 1
}
