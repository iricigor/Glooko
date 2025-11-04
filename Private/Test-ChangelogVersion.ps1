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
        Write-Warning "CHANGELOG.md not found at: $ChangelogPath"
        return $false
    }
    
    try {
        $content = Get-Content $ChangelogPath -Raw
        
        # Look for version header in format: ## [1.0.25] - 2025-11-04
        # The pattern matches: ## [version] followed by optional whitespace and dash
        $pattern = "^##\s+\[$([regex]::Escape($Version))\]\s*-"
        
        # Check if pattern matches in the content
        if ($content -match $pattern) {
            $found = $true
        } else {
            # Check line by line
            $matchingLines = @($content -split "`n" | Where-Object { $_ -match $pattern })
            $found = $matchingLines.Count -gt 0
        }
        
        if ($found) {
            Write-Verbose "Found version $Version in changelog"
        } else {
            Write-Verbose "Version $Version not found in changelog"
        }
        
        return $found
        
    } catch {
        Write-Warning "Error reading changelog: $($_.Exception.Message)"
        return $false
    }
}
