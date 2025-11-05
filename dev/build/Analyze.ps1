#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Runs PSScriptAnalyzer on the Glooko module.

.DESCRIPTION
    This script runs PSScriptAnalyzer on all PowerShell files in the module
    to ensure they follow best practices and don't have security vulnerabilities.
    It uses the settings defined in PSScriptAnalyzerSettings.psd1.

.PARAMETER Path
    The path to analyze. Default: current directory

.PARAMETER Recurse
    Whether to analyze files recursively. Default: $true

.PARAMETER Severity
    The severity levels to include. Default: Error, Warning, Information

.PARAMETER Fix
    Automatically fix issues where possible. Default: $false

.PARAMETER ExcludeRule
    Additional rules to exclude from the analysis.

.EXAMPLE
    ./Analyze.ps1
    Analyzes the current directory

.EXAMPLE
    ./Analyze.ps1 -Fix
    Analyzes and fixes issues where possible

.EXAMPLE
    ./Analyze.ps1 -Severity Error,Warning
    Only reports errors and warnings
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string[]]$Path = @('.'),

    [Parameter()]
    [bool]$Recurse = $true,

    [Parameter()]
    [ValidateSet('Error', 'Warning', 'Information', 'ParseError')]
    [string[]]$Severity = @('Error', 'Warning', 'Information'),

    [Parameter()]
    [switch]$Fix,

    [Parameter()]
    [string[]]$ExcludeRule
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    # Get the repository root (two levels up from dev/build folder)
    $RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    Write-Verbose "Repository root: $RepoRoot"

    # Check if PSScriptAnalyzer is available
    if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
        Write-Warning "PSScriptAnalyzer module not found. Installing..."
        Install-Module -Name PSScriptAnalyzer -Force -SkipPublisherCheck -Scope CurrentUser
    }

    Import-Module PSScriptAnalyzer -Force

    # Settings file in dev/config folder
    $SettingsFile = Join-Path $RepoRoot 'dev' 'config' 'PSScriptAnalyzerSettings.psd1'
    
    # Build parameters for Invoke-ScriptAnalyzer
    $analyzerParams = @{
        Recurse = $Recurse
        Severity = $Severity
    }

    if (Test-Path $SettingsFile) {
        Write-Host "Using settings from: $SettingsFile" -ForegroundColor Cyan
        $analyzerParams['Settings'] = $SettingsFile
    }

    if ($ExcludeRule) {
        $analyzerParams['ExcludeRule'] = $ExcludeRule
    }

    # Run PSScriptAnalyzer
    Write-Host "`nRunning PSScriptAnalyzer..." -ForegroundColor Cyan
    Write-Verbose "Parameters: $($analyzerParams | ConvertTo-Json -Depth 2)"

    $allResults = @()

    if ($Fix) {
        Write-Host "Auto-fixing issues where possible..." -ForegroundColor Yellow
        $analyzerParams['Fix'] = $true
    }

    # Process each path (resolve relative to repository root)
    foreach ($pathItem in $Path) {
        # If path is relative and doesn't start with ./ or \, make it relative to repo root
        if (-not [System.IO.Path]::IsPathRooted($pathItem) -and $pathItem -notmatch '^\.') {
            $resolvedPath = Join-Path $RepoRoot $pathItem
        } else {
            $resolvedPath = $pathItem
        }
        
        Write-Verbose "Analyzing path: $resolvedPath"
        $analyzerParams['Path'] = $resolvedPath
        $results = Invoke-ScriptAnalyzer @analyzerParams
        if ($results) {
            $allResults += $results
        }
    }

    # Display results
    if ($allResults -and $allResults.Count -gt 0) {
        Write-Host "`nFound $($allResults.Count) issue(s):" -ForegroundColor Yellow
        $allResults | Format-Table -Property Severity, RuleName, ScriptName, Line, Message -AutoSize

        # Group by severity
        $grouped = $allResults | Group-Object Severity
        Write-Host "`nSummary by severity:" -ForegroundColor Cyan
        foreach ($group in $grouped) {
            Write-Host "  $($group.Name): $($group.Count)" -ForegroundColor $(
                switch ($group.Name) {
                    'Error' { 'Red' }
                    'Warning' { 'Yellow' }
                    'Information' { 'Cyan' }
                    default { 'White' }
                }
            )
        }

        # Exit with error if there are errors or warnings
        $errorCount = 0
        $warningCount = 0
        
        if ($grouped) {
            $errorGroup = $grouped | Where-Object { $_.Name -eq 'Error' }
            $warningGroup = $grouped | Where-Object { $_.Name -eq 'Warning' }
            
            if ($errorGroup) {
                $errorCount = $errorGroup.Count
            }
            if ($warningGroup) {
                $warningCount = $warningGroup.Count
            }
        }
        
        if ($errorCount -gt 0) {
            Write-Host "`n❌ Analysis failed with $errorCount error(s) and $warningCount warning(s)" -ForegroundColor Red
            exit 1
        } elseif ($warningCount -gt 0) {
            Write-Host "`n⚠️  Analysis completed with $warningCount warning(s)" -ForegroundColor Yellow
            exit 0
        } else {
            Write-Host "`n✓ Analysis completed with information-only issues" -ForegroundColor Green
            exit 0
        }
    } else {
        Write-Host "`n✓ No issues found!" -ForegroundColor Green
        exit 0
    }

} catch {
    Write-Error "Analysis failed: $($_.Exception.Message)"
    exit 1
}
