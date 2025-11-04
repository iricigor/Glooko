#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Calculates a checksum for the module runtime files.

.DESCRIPTION
    This script calculates a SHA256 checksum of all module runtime files,
    excluding version information from the module manifest. This allows
    detection of actual code changes versus version-only changes.

.PARAMETER ModulePath
    Path to the module directory (source or build output).
    Default: Current directory

.PARAMETER Verbose
    Enable verbose output.

.EXAMPLE
    ./Get-ModuleChecksum.ps1
    Calculates checksum for module in current directory

.EXAMPLE
    ./Get-ModuleChecksum.ps1 -ModulePath ./BuildOutput
    Calculates checksum for built module

.OUTPUTS
    Returns a hashtable with Checksum and FileList properties
#>

[CmdletBinding()]
param(
    [Parameter()]
    [string]$ModulePath = '.'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

try {
    Write-Verbose "Calculating module checksum for path: $ModulePath"
    
    # Resolve to absolute path
    $resolvedPath = Resolve-Path $ModulePath
    $ModulePath = $resolvedPath.Path
    Write-Verbose "Resolved path: $ModulePath"
    
    # Define files to include in checksum (runtime files only)
    $runtimePatterns = @(
        'Public/*.ps1'
        'Private/*.ps1'
        'Glooko.psm1'
        'Glooko.psd1'
        'Glooko.Types.ps1xml'
        'Glooko.Format.ps1xml'
    )
    
    # Collect all files
    $files = @()
    foreach ($pattern in $runtimePatterns) {
        $matchedFiles = Get-ChildItem -Path (Join-Path $ModulePath $pattern) -File -ErrorAction SilentlyContinue
        if ($matchedFiles) {
            $files += $matchedFiles
        }
    }
    
    if ($files.Count -eq 0) {
        Write-Error "No runtime files found in $ModulePath"
        exit 1
    }
    
    Write-Verbose "Found $($files.Count) runtime files"
    
    # Sort files by relative path for consistent ordering
    $files = $files | Sort-Object FullName
    
    # Create a combined hash of all file contents
    $sha256 = [System.Security.Cryptography.SHA256]::Create()
    $fileList = @()
    
    foreach ($file in $files) {
        $relativePath = $file.FullName.Substring($ModulePath.Length + 1)
        Write-Verbose "Processing: $relativePath"
        
        # Read file content
        $content = Get-Content -Path $file.FullName -Raw
        
        # Special handling for Glooko.psd1 - strip version before hashing
        if ($file.Name -eq 'Glooko.psd1') {
            Write-Verbose "Stripping version from module manifest"
            # Replace version with a constant placeholder to make checksum version-independent
            $content = $content -replace "(ModuleVersion\s*=\s*')[\d\.]+(')", "`${1}0.0.0`$2"
        }
        
        # Convert content to bytes
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
        
        # Add to hash
        $sha256.TransformBlock($bytes, 0, $bytes.Length, $null, 0) | Out-Null
        
        # Track file for reporting
        $fileList += @{
            Path = $relativePath
            Size = $file.Length
        }
    }
    
    # Finalize hash
    $sha256.TransformFinalBlock(@(), 0, 0) | Out-Null
    $checksum = [System.BitConverter]::ToString($sha256.Hash) -replace '-', ''
    
    Write-Verbose "Checksum calculated: $checksum"
    Write-Host "Module checksum: $checksum" -ForegroundColor Green
    
    # Return result as hashtable
    $result = @{
        Checksum = $checksum
        FileCount = $fileList.Count
        Files = $fileList
    }
    
    # Output as object
    [PSCustomObject]$result
    
    exit 0

} catch {
    Write-Error "Failed to calculate checksum: $($_.Exception.Message)"
    exit 1
}
