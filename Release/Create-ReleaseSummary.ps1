#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Creates a release summary for GitHub Actions.

.DESCRIPTION
    This script generates a markdown summary of the release that is displayed
    in the GitHub Actions workflow summary.

.PARAMETER ModuleVersion
    The version of the module that was published.

.PARAMETER DryRun
    Whether this was a dry run.

.PARAMETER PublishedBy
    The GitHub username of the person who triggered the release.

.PARAMETER OutputFile
    Path to the GitHub Actions step summary file.

.EXAMPLE
    ./Create-ReleaseSummary.ps1 -ModuleVersion "1.0.0" -DryRun $false -PublishedBy "iricigor" -OutputFile $env:GITHUB_STEP_SUMMARY
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$ModuleVersion,

    [Parameter(Mandatory)]
    [string]$DryRun,

    [Parameter(Mandatory)]
    [string]$PublishedBy,

    [Parameter(Mandatory)]
    [string]$OutputFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $summary = @"
# Release Summary

**Module Version:** $ModuleVersion
**Published to:** PowerShell Gallery
**Dry Run:** $DryRun
**Published by:** $PublishedBy
**Published at:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss UTC')

## Installation

Users can now install this module using:

``````powershell
Install-Module -Name Glooko -RequiredVersion $ModuleVersion
``````

Or update to the latest version:

``````powershell
Update-Module -Name Glooko
``````
"@
    
    Write-Host $summary
    
    # Save to step summary
    $summary | Out-File -FilePath $OutputFile -Encoding utf8
    
    exit 0

} catch {
    Write-Error "Failed to create release summary: $($_.Exception.Message)"
    exit 1
}
