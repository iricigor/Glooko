#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Downloads a build artifact from GitHub Actions workflow runs.

.DESCRIPTION
    This script downloads a build artifact from successful GitHub Actions build workflow runs.
    It can download the latest artifact or a specific version.

.PARAMETER Version
    The version of the artifact to download. If not specified, downloads the latest artifact.

.PARAMETER Repository
    The GitHub repository in the format 'owner/repo'.

.PARAMETER GH_TOKEN
    GitHub token for API authentication.

.EXAMPLE
    ./Download-BuildArtifact.ps1 -Repository "iricigor/Glooko"
    Downloads the latest build artifact

.EXAMPLE
    ./Download-BuildArtifact.ps1 -Version "1.0.0" -Repository "iricigor/Glooko"
    Downloads a specific version
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$Version,

    [Parameter(Mandatory)]
    [string]$Repository,

    [Parameter(Mandatory)]
    [string]$GH_TOKEN
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Import helper function to get latest version from changelog
. (Join-Path $PSScriptRoot 'Get-LatestChangelogVersion.ps1')

try {
    if ($Version) {
        Write-Host "Downloading specific version: $Version"
        $artifactName = "Glooko-Module-$Version"
    } else {
        Write-Host "Version not specified, attempting to determine from CHANGELOG.md..."
        $changelogVersion = Get-LatestChangelogVersion
        
        if ($changelogVersion) {
            Write-Host "Latest version in CHANGELOG.md: $changelogVersion"
            Write-Host "Will download build artifact for version $changelogVersion"
            $artifactName = "Glooko-Module-$changelogVersion"
            $Version = $changelogVersion
        } else {
            Write-Warning "Could not determine version from CHANGELOG.md"
            Write-Host "Falling back to latest build artifact from build workflow"
            $artifactName = $null
        }
    }
    
    # Get the latest successful build workflow run
    Write-Host "Finding latest successful build workflow run..."
    $buildWorkflow = gh api "/repos/$Repository/actions/workflows/build.yml/runs?status=success&per_page=10" | ConvertFrom-Json
    
    if ($buildWorkflow.workflow_runs.Count -eq 0) {
        Write-Error "No successful build workflow runs found"
        exit 1
    }
    
    # Find the run with the matching artifact (if version specified) or just use the latest
    $selectedRun = $null
    $selectedArtifact = $null
    
    foreach ($run in $buildWorkflow.workflow_runs) {
        Write-Host "Checking run $($run.id) from $($run.created_at)..."
        
        # Get artifacts from this run
        $artifacts = gh api "/repos/$Repository/actions/runs/$($run.id)/artifacts" | ConvertFrom-Json
        
        if ($artifactName) {
            # Looking for specific version
            $artifact = $artifacts.artifacts | Where-Object { $_.name -eq $artifactName } | Select-Object -First 1
        } else {
            # Looking for any Glooko-Module artifact
            $artifact = $artifacts.artifacts | Where-Object { $_.name -like 'Glooko-Module-*' } | Select-Object -First 1
        }
        
        if ($artifact) {
            $selectedRun = $run
            $selectedArtifact = $artifact
            break
        }
    }
    
    if (-not $selectedArtifact) {
        if ($artifactName) {
            Write-Error "No artifact found with name: $artifactName"
        } else {
            Write-Error "No Glooko-Module artifact found in recent build runs"
        }
        exit 1
    }
    
    Write-Host "Found artifact: $($selectedArtifact.name) from run $($selectedRun.id)"
    
    # Download the artifact
    Write-Host "Downloading artifact..."
    gh api "/repos/$Repository/actions/artifacts/$($selectedArtifact.id)/zip" > artifact.zip
    
    # Extract the artifact to a temporary location first
    Write-Host "Extracting artifact..."
    $tempDir = "./TempExtract"
    Expand-Archive -Path artifact.zip -DestinationPath $tempDir -Force
    Remove-Item artifact.zip
    
    # Move files to BuildOutput/Glooko structure for Publish-Module compatibility
    # Publish-Module requires the module to be in a folder with the same name as the module
    $glookoDir = "./BuildOutput/Glooko"
    New-Item -Path $glookoDir -ItemType Directory -Force | Out-Null
    Get-ChildItem -Path $tempDir | Move-Item -Destination $glookoDir -Force
    Remove-Item $tempDir -Recurse -Force
    
    Write-Host "Downloaded and extracted build artifact: $($selectedArtifact.name)"
    Write-Host "Module prepared in: $glookoDir"
    
    exit 0

} catch {
    Write-Error "Failed to download build artifact: $($_.Exception.Message)"
    exit 1
}
