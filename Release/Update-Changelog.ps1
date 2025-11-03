#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Updates CHANGELOG.md with entries from builds since the last release.

.DESCRIPTION
    This script queries GitHub API to find all build workflow runs with SemVer changes
    after the latest GitHub release, maps them to their PRs, and updates CHANGELOG.md
    with new entries.

.PARAMETER Repository
    The GitHub repository in the format 'owner/repo'.

.PARAMETER GH_TOKEN
    GitHub token for API authentication.

.PARAMETER DryRun
    If specified, shows what changes would be made without modifying CHANGELOG.md.

.PARAMETER OutputFile
    Optional path to save the generated changelog entries.

.EXAMPLE
    ./Update-Changelog.ps1 -Repository "iricigor/Glooko" -GH_TOKEN $env:GITHUB_TOKEN
    Updates the changelog with entries since the last release

.EXAMPLE
    ./Update-Changelog.ps1 -Repository "iricigor/Glooko" -GH_TOKEN $env:GITHUB_TOKEN -DryRun
    Shows what would be added to the changelog without making changes
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)]
    [string]$Repository,

    [Parameter(Mandatory)]
    [string]$GH_TOKEN,  # Used as environment variable for gh CLI commands throughout the script

    [Parameter()]
    [switch]$DryRun,

    [Parameter()]
    [string]$OutputFile
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Set GH_TOKEN as environment variable for gh CLI
$env:GH_TOKEN = $GH_TOKEN

function Get-LatestRelease {
    param([string]$Repo)
    
    Write-Verbose "Fetching latest release from GitHub..."
    try {
        $response = gh api "/repos/$Repo/releases/latest" --jq '{tag_name, published_at, id}' | ConvertFrom-Json
        Write-Host "Latest release: $($response.tag_name) published on $($response.published_at)"
        return $response
    } catch {
        Write-Warning "No releases found. Will process all builds."
        return $null
    }
}

function Get-BuildsSinceRelease {
    param(
        [string]$Repo,
        [datetime]$SinceDate
    )
    
    Write-Verbose "Fetching successful build workflow runs since $SinceDate..."
    $builds = gh api "/repos/$Repo/actions/workflows/build.yml/runs?status=success&per_page=100" | ConvertFrom-Json
    
    $relevantBuilds = @($builds.workflow_runs | Where-Object {
        $runDate = [datetime]::Parse($_.created_at)
        $runDate -gt $SinceDate
    })
    
    Write-Host "Found $($relevantBuilds.Count) build runs since last release"
    
    # Use Write-Output -NoEnumerate to prevent PowerShell from unwrapping empty arrays to $null
    Write-Output -NoEnumerate $relevantBuilds
}

function Get-BuildVersion {
    param(
        [string]$Repo,
        [string]$RunId
    )
    
    Write-Verbose "Fetching artifacts for run $RunId..."
    $artifacts = gh api "/repos/$Repo/actions/runs/$RunId/artifacts" | ConvertFrom-Json
    
    $artifact = $artifacts.artifacts | Where-Object { $_.name -like 'Glooko-Module-*' } | Select-Object -First 1
    
    if ($artifact) {
        # Extract version from artifact name (e.g., "Glooko-Module-1.0.5" -> "1.0.5")
        if ($artifact.name -match 'Glooko-Module-(.+)$') {
            return $Matches[1]
        }
    }
    
    return $null
}

function Get-PRForCommit {
    param(
        [string]$Repo,
        [string]$CommitSha
    )
    
    Write-Verbose "Finding PR for commit $CommitSha..."
    try {
        $prs = gh api "/repos/$Repo/commits/$CommitSha/pulls" --jq '.[0] | {number, title, merged_at, html_url}' | ConvertFrom-Json
        return $prs
    } catch {
        Write-Verbose "No PR found for commit $CommitSha"
        return $null
    }
}

function Format-ChangelogEntry {
    param(
        [string]$Version,
        [string]$Date,
        [object]$PR
    )
    
    $formattedDate = ([datetime]::Parse($Date)).ToString('yyyy-MM-dd')
    $prLink = if ($PR) { " ([#$($PR.number)]($($PR.html_url)))" } else { "" }
    $prTitle = if ($PR) { $PR.title } else { "Build $Version" }
    
    return @{
        Version = $Version
        Date = $formattedDate
        Title = $prTitle
        PRLink = $prLink
    }
}

function Group-ByMajorMinor {
    param([array]$Entries)
    
    $grouped = @{}
    
    foreach ($entry in $Entries) {
        if ($entry.Version -match '^(\d+\.\d+)\.') {
            $majorMinor = $Matches[1]
            if (-not $grouped.ContainsKey($majorMinor)) {
                $grouped[$majorMinor] = @()
            }
            $grouped[$majorMinor] += $entry
        }
    }
    
    return $grouped
}

function Update-ChangelogFile {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ChangelogPath,
        [array]$NewEntries,
        [switch]$DryRun
    )
    
    if (-not (Test-Path $ChangelogPath)) {
        throw "CHANGELOG.md not found at: $ChangelogPath"
    }
    
    # Read current changelog
    $content = Get-Content $ChangelogPath -Raw
    
    # Group entries by major.minor version
    $grouped = Group-ByMajorMinor -Entries $NewEntries
    
    # Generate new changelog sections
    $newSections = @()
    foreach ($majorMinor in ($grouped.Keys | Sort-Object -Descending)) {
        $versionEntries = $grouped[$majorMinor] | Sort-Object { [version]$_.Version } -Descending
        $latestEntry = $versionEntries[0]
        
        $section = @"
## [$majorMinor] - $($latestEntry.Date)

### Changed
"@
        
        foreach ($entry in $versionEntries) {
            $section += "`n- $($entry.Title)$($entry.PRLink)"
        }
        
        $newSections += $section
    }
    
    # Find the [Unreleased] section and insert new sections after it
    $unreleasedPattern = '(?s)(## \[Unreleased\].*?)((?=## \[\d+\.\d+\])|$)'
    
    if ($content -match $unreleasedPattern) {
        $newContent = $content -replace $unreleasedPattern, ($Matches[1] + "`n`n" + ($newSections -join "`n`n") + "`n")
        
        # Update comparison links at the bottom
        $firstVersion = ($grouped.Keys | Sort-Object -Descending | Select-Object -First 1)
        if ($firstVersion) {
            $linkPattern = "\[Unreleased\]: https://github\.com/.+?/compare/v(.+?)\.\.\.HEAD"
            $newContent = $newContent -replace $linkPattern, "[Unreleased]: https://github.com/$Repository/compare/v$firstVersion...HEAD"
            
            # Add version comparison links
            $versions = $grouped.Keys | Sort-Object -Descending
            for ($i = 0; $i -lt $versions.Count - 1; $i++) {
                $current = $versions[$i]
                $previous = $versions[$i + 1]
                $linkLine = "[$current]: https://github.com/$Repository/compare/v$previous...v$current"
                
                if ($newContent -notmatch [regex]::Escape($linkLine)) {
                    $newContent = $newContent -replace "(\[Unreleased\]: .+)", "`$1`n$linkLine"
                }
            }
            
            # Add link for the oldest new version
            $oldestVersion = $versions[-1]
            $linkLine = "[$oldestVersion]: https://github.com/$Repository/releases/tag/v$oldestVersion"
            if ($newContent -notmatch [regex]::Escape($linkLine)) {
                $newContent = $newContent -replace "(\[Unreleased\]: .+)", "`$1`n$linkLine"
            }
        }
        
        if ($DryRun) {
            Write-Host "`n=== DRY RUN: Would update CHANGELOG.md with: ===`n"
            Write-Host ($newSections -join "`n`n")
            Write-Host "`n=== End of changes ===`n"
        } else {
            Set-Content -Path $ChangelogPath -Value $newContent -NoNewline
            Write-Host "Updated CHANGELOG.md with $($NewEntries.Count) new entries" -ForegroundColor Green
        }
        
        return $newContent
    } else {
        throw "Could not find [Unreleased] section in CHANGELOG.md"
    }
}

try {
    # Get the latest release
    $latestRelease = Get-LatestRelease -Repo $Repository
    
    if ($latestRelease) {
        $sinceDate = [datetime]::Parse($latestRelease.published_at)
    } else {
        # If no release found, go back 90 days
        $sinceDate = (Get-Date).AddDays(-90)
    }
    
    # Get builds since the release
    $builds = Get-BuildsSinceRelease -Repo $Repository -SinceDate $sinceDate
    
    if ($builds.Count -eq 0) {
        Write-Host "No builds found since last release. Nothing to update." -ForegroundColor Yellow
        exit 0
    }
    
    # Process each build to extract version and PR information
    $entries = @()
    $seenVersions = @{}
    
    foreach ($build in $builds) {
        $version = Get-BuildVersion -Repo $Repository -RunId $build.id
        
        if (-not $version) {
            Write-Verbose "Skipping run $($build.id) - no version artifact found"
            continue
        }
        
        # Skip if we've already seen this version (take only the first occurrence)
        if ($seenVersions.ContainsKey($version)) {
            Write-Verbose "Skipping duplicate version $version"
            continue
        }
        
        $seenVersions[$version] = $true
        
        # Get the PR associated with this build
        $pr = Get-PRForCommit -Repo $Repository -CommitSha $build.head_sha
        
        $entry = Format-ChangelogEntry -Version $version -Date $build.created_at -PR $pr
        $entries += $entry
        
        Write-Host "  Version $version - $($entry.Title)"
    }
    
    if ($entries.Count -eq 0) {
        Write-Host "No new versions found to add to changelog." -ForegroundColor Yellow
        exit 0
    }
    
    # Update the changelog
    $changelogPath = Join-Path $PSScriptRoot ".." "CHANGELOG.md"
    $updatedContent = Update-ChangelogFile -ChangelogPath $changelogPath -NewEntries $entries -DryRun:$DryRun
    
    if ($OutputFile) {
        $updatedContent | Set-Content -Path $OutputFile -NoNewline
        Write-Host "Saved changelog to: $OutputFile"
    }
    
    Write-Host "`nChangelog update completed successfully!" -ForegroundColor Green
    exit 0

} catch {
    Write-Error "Failed to update changelog: $($_.Exception.Message)"
    Write-Verbose $_.ScriptStackTrace
    exit 1
}
