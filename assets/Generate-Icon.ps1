#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Generates PNG icon from SVG source.

.DESCRIPTION
    This script converts the icon.svg file to icon.png using ImageMagick.
    The SVG is the source of truth and should be edited directly.
    This script regenerates the PNG from the SVG.

.PARAMETER Size
    The size of the output PNG icon. Default is 256x256.

.EXAMPLE
    ./Generate-Icon.ps1
    Generates a 256x256 PNG icon from the SVG source.

.EXAMPLE
    ./Generate-Icon.ps1 -Size 512
    Generates a 512x512 PNG icon from the SVG source.
#>

[CmdletBinding()]
param(
    [Parameter()]
    [int]$Size = 256
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    $ScriptDir = $PSScriptRoot
    $SvgPath = Join-Path $ScriptDir 'icon.svg'
    $PngPath = Join-Path $ScriptDir 'icon.png'

    # Verify SVG exists
    if (-not (Test-Path $SvgPath)) {
        throw "SVG icon not found at: $SvgPath"
    }

    Write-Host "Converting SVG to PNG..."
    Write-Verbose "Source SVG: $SvgPath"
    Write-Verbose "Target PNG: $PngPath"
    Write-Verbose "Size: ${Size}x${Size}"

    # Check if ImageMagick is available
    $convertCmd = Get-Command convert -ErrorAction SilentlyContinue
    if (-not $convertCmd) {
        throw "ImageMagick 'convert' command not found. Please install ImageMagick to generate the PNG icon."
    }

    # Convert SVG to PNG
    $sizeArg = "${Size}x${Size}"
    & convert -background none $SvgPath -resize $sizeArg $PngPath

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to convert SVG to PNG. Exit code: $LASTEXITCODE"
    }

    # Verify PNG was created
    if (-not (Test-Path $PngPath)) {
        throw "PNG icon was not created at: $PngPath"
    }

    $pngInfo = Get-Item $PngPath
    Write-Host "PNG icon generated successfully!" -ForegroundColor Green
    Write-Host "Output: $PngPath"
    Write-Host "Size: $($pngInfo.Length / 1KB) KB"

} catch {
    Write-Error "Failed to generate icon: $($_.Exception.Message)"
    exit 1
}
