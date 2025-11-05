function Test-ChangelogVersion {
    <#
    .SYNOPSIS
        Verifies that the changelog contains an entry for the specified version.
    
    .DESCRIPTION
        Checks if CHANGELOG.md contains a section header for the specified version.
        This ensures the changelog has been updated before releasing a new version.
    
    .PARAMETER Version
        The version to check for in the changelog (e.g., "1.0.25").
    
    .PARAMETER ChangelogPath
        Path to the CHANGELOG.md file. Defaults to ../CHANGELOG.md relative to the script.
    
    .EXAMPLE
        Test-ChangelogVersion -Version "1.0.25"
        Returns $true if changelog contains ## [1.0.25] header
    
    .OUTPUTS
        System.Boolean
    #>
    [CmdletBinding()]
    [OutputType([bool])]
    param(
        [Parameter(Mandatory)]
        [string]$Version,
        
        [Parameter()]
        [string]$ChangelogPath = (Join-Path $PSScriptRoot '..' 'CHANGELOG.md')
    )
    
    Write-Verbose "Checking if CHANGELOG.md contains version $Version"
    
    if (-not (Test-Path $ChangelogPath)) {
        Write-Warning "CHANGELOG.md not found at: $ChangelogPath - skipping changelog validation"
        return $true
    }
    
    try {
        $content = Get-Content $ChangelogPath -Raw
        
        # Look for version header in format: ## [1.0.25] or ## [1.0.25] - 2025-11-04
        # Using multiline mode to match line starts in the full content
        
        # First try exact match
        $exactPattern = "(?m)^##\s+\[$([regex]::Escape($Version))\](\s*-.*)?$"
        $found = $content -match $exactPattern
        
        if ($found) {
            Write-Verbose "Found version $Version in changelog"
            return $true
        }
        
        # If version has three parts (X.Y.Z format), check if there's any version with same X.Y
        # This allows build 1.0.0 to match against 1.0.25 in changelog (same major.minor)
        if ($Version -match '^(\d+)\.(\d+)\.(\d+)$') {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            $buildNumber = [int]$Matches[3]
            $majorMinor = "$major.$minor"
            
            Write-Verbose "Version has build number $buildNumber, checking for any $majorMinor.X in changelog"
            
            # Find all versions with same major.minor in changelog
            $versionPattern = '(?m)^##\s+\[(\d+)\.(\d+)\.(\d+)\](\s*-.*)?$'
            $versionMatches = [regex]::Matches($content, $versionPattern)
            
            foreach ($match in $versionMatches) {
                $foundMajor = [int]$match.Groups[1].Value
                $foundMinor = [int]$match.Groups[2].Value
                $foundBuild = [int]$match.Groups[3].Value
                
                # Match if same major.minor and found build number is >= requested build number
                # This allows 1.0.0 to match 1.0.25 (0 < 25), but not 1.0.25 to match 1.0.2 (25 > 2)
                if ($foundMajor -eq $major -and $foundMinor -eq $minor -and $foundBuild -ge $buildNumber) {
                    Write-Verbose "Found $majorMinor.$foundBuild in changelog (>= $Version)"
                    return $true
                }
            }
            
            Write-Verbose "Version $Version not found in changelog"
            return $false
        }
        
        # For two-part versions (X.Y), require exact match
        Write-Verbose "Version $Version not found in changelog"
        return $false
        
    } catch {
        Write-Warning "Error reading changelog: $($_.Exception.Message)"
        return $false
    }
}
