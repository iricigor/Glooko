#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generates XML help files for the Glooko PowerShell module using platyPS.

.DESCRIPTION
    This script uses platyPS to generate external MAML help files for the Glooko module.
    It first generates platyPS-formatted markdown from the module's comment-based help,
    then converts that markdown to XML help files. The XML help files are placed in the
    en-US subdirectory for proper PowerShell help integration.

.PARAMETER ModulePath
    The path to the module manifest file.
    Default: ./Glooko.psd1

.PARAMETER MarkdownPath
    The path where platyPS markdown files will be generated/stored.
    Default: ./docs/help

.PARAMETER OutputPath
    The path where the XML help files will be created.
    Default: ./en-US

.EXAMPLE
    ./Build-Help.ps1
    Generates XML help files in the en-US directory

.EXAMPLE
    ./Build-Help.ps1 -Verbose
    Generates XML help files with verbose output
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ModulePath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'Glooko.psd1'),

    [Parameter()]
    [string]$MarkdownPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'docs' 'help'),

    [Parameter()]
    [string]$OutputPath = (Join-Path (Split-Path -Parent $PSScriptRoot) 'en-US')
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    Write-Host "Building XML Help Files for Glooko Module" -ForegroundColor Cyan
    Write-Host "=" * 60

    # Check if platyPS is installed
    Write-Verbose "Checking for platyPS module..."
    $platyPS = Get-Module -ListAvailable -Name platyPS | Select-Object -First 1
    
    if (-not $platyPS) {
        Write-Host "platyPS module not found. Installing..." -ForegroundColor Yellow
        Install-Module -Name platyPS -Scope CurrentUser -Force -AllowClobber
        Write-Host "platyPS installed successfully" -ForegroundColor Green
    } else {
        Write-Verbose "platyPS version $($platyPS.Version) is already installed"
    }

    # Import platyPS
    Write-Verbose "Importing platyPS module..."
    Import-Module platyPS -Force

    # Verify module manifest exists
    if (-not (Test-Path $ModulePath)) {
        throw "Module manifest not found: $ModulePath"
    }

    Write-Host "`nModule manifest: $ModulePath"
    
    # Import the module to get access to the functions
    Write-Verbose "Importing Glooko module..."
    Import-Module $ModulePath -Force

    # Get exported functions
    $module = Get-Module -Name Glooko
    if (-not $module) {
        throw "Failed to import Glooko module"
    }

    $exportedCommands = $module.ExportedCommands.Keys
    Write-Host "Found $($exportedCommands.Count) exported commands: $($exportedCommands -join ', ')"

    # Create markdown directory if it doesn't exist
    if (-not (Test-Path $MarkdownPath)) {
        Write-Verbose "Creating markdown directory: $MarkdownPath"
        New-Item -Path $MarkdownPath -ItemType Directory -Force | Out-Null
    }

    # Generate platyPS markdown from the module
    Write-Host "`nGenerating platyPS markdown files in: $MarkdownPath" -ForegroundColor Cyan
    
    foreach ($command in $exportedCommands) {
        Write-Verbose "Generating markdown for: $command"
        New-MarkdownHelp -Command $command -OutputFolder $MarkdownPath -Force | Out-Null
    }

    # Verify markdown files were created
    $markdownFiles = Get-ChildItem -Path $MarkdownPath -Filter "*.md"
    Write-Host "Generated $($markdownFiles.Count) markdown file(s)" -ForegroundColor Green
    
    # Create output directory if it doesn't exist
    if (-not (Test-Path $OutputPath)) {
        Write-Verbose "Creating output directory: $OutputPath"
        New-Item -Path $OutputPath -ItemType Directory -Force | Out-Null
    }

    Write-Host "`nOutput directory: $OutputPath"

    # Generate XML help from markdown
    Write-Host "Generating XML help files..." -ForegroundColor Cyan
    
    $xmlHelpPath = New-ExternalHelp -Path $MarkdownPath -OutputPath $OutputPath -Force
    
    if ($xmlHelpPath) {
        Write-Host "`nXML help files generated successfully:" -ForegroundColor Green
        Get-ChildItem -Path $OutputPath -Filter "*.xml" | ForEach-Object {
            Write-Host "  - $($_.Name)" -ForegroundColor Green
        }
    } else {
        throw "Failed to generate XML help files"
    }

    # Verify the XML files were created
    $xmlFiles = @(Get-ChildItem -Path $OutputPath -Filter "*.xml")
    if ($xmlFiles.Count -eq 0) {
        throw "No XML files were generated"
    }

    Write-Host "`n" + "=" * 60
    Write-Host "Help file generation completed successfully!" -ForegroundColor Green
    Write-Host "Generated $($xmlFiles.Count) XML help file(s) in: $OutputPath" -ForegroundColor Green

    exit 0

} catch {
    Write-Error "Failed to generate help files: $($_.Exception.Message)"
    exit 1
}
