function Get-LatestChangelogVersion {
    <#
    .SYNOPSIS
        Gets the latest version number from CHANGELOG.md.
    
    .DESCRIPTION
        Parses CHANGELOG.md to find the most recent version entry (excluding Unreleased).
        Returns the version number without the 'v' prefix.
    
    .PARAMETER ChangelogPath
        Path to the CHANGELOG.md file. Defaults to ../CHANGELOG.md relative to the script.
    
    .EXAMPLE
        Get-LatestChangelogVersion
        Returns "1.0.25" if that's the latest version in the changelog
    
    .OUTPUTS
        System.String - The latest version number, or $null if no version found
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter()]
        [string]$ChangelogPath = (Join-Path $PSScriptRoot '..' 'CHANGELOG.md')
    )
    
    Write-Verbose "Reading changelog from: $ChangelogPath"
    
    if (-not (Test-Path $ChangelogPath)) {
        Write-Warning "CHANGELOG.md not found at: $ChangelogPath"
        return $null
    }
    
    try {
        $content = Get-Content $ChangelogPath -Raw
        
        # Look for version headers in format: ## [X.Y.Z] or ## [X.Y.Z] - Date
        # Skip the [Unreleased] section
        # Pattern: ## [version] where version is digits.digits or digits.digits.digits
        $pattern = '(?m)^##\s+\[(\d+\.\d+(?:\.\d+)?)\]'
        
        $matches = [regex]::Matches($content, $pattern)
        
        if ($matches.Count -eq 0) {
            Write-Warning "No version entries found in changelog"
            return $null
        }
        
        # Get all versions and sort them to find the latest
        $versions = @()
        foreach ($match in $matches) {
            $versionStr = $match.Groups[1].Value
            Write-Verbose "Found version: $versionStr"
            try {
                # Pad two-part versions to three parts for proper [version] casting
                # e.g., "1.0" becomes "1.0.0" so .NET Version class can parse it
                $paddedVersion = if ($versionStr -match '^\d+\.\d+$') {
                    "$versionStr.0"
                } else {
                    $versionStr
                }
                $versions += [version]$paddedVersion
            } catch {
                Write-Verbose "Skipping invalid version format: $versionStr"
            }
        }
        
        if ($versions.Count -eq 0) {
            Write-Warning "No valid version numbers found in changelog"
            return $null
        }
        
        # Sort versions and get the latest
        $latestVersion = ($versions | Sort-Object -Descending | Select-Object -First 1)
        
        # Convert back to string, removing the padding if it was a two-part version
        $latestVersionStr = $latestVersion.ToString()
        if ($latestVersionStr -match '^(\d+\.\d+)\.0$') {
            $latestVersionStr = $Matches[1]
        }
        
        Write-Verbose "Latest version in changelog: $latestVersionStr"
        return $latestVersionStr
        
    } catch {
        Write-Warning "Error reading changelog: $($_.Exception.Message)"
        return $null
    }
}
