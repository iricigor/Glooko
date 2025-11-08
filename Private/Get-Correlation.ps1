function Get-Correlation {
    <#
    .SYNOPSIS
        Calculates the Pearson correlation coefficient between two arrays.
    
    .DESCRIPTION
        This function calculates the Pearson correlation coefficient (r) between
        two arrays of numeric values. The correlation coefficient ranges from -1
        (perfect negative correlation) to +1 (perfect positive correlation), with
        0 indicating no linear relationship.
    
    .PARAMETER X
        First array of numeric values.
    
    .PARAMETER Y
        Second array of numeric values. Must have the same count as X.
    
    .EXAMPLE
        Get-Correlation -X @(1, 2, 3, 4, 5) -Y @(2, 4, 6, 8, 10)
        Returns 1.000 (perfect positive correlation)
    
    .EXAMPLE
        Get-Correlation -X @(1, 2, 3) -Y @(3, 2, 1)
        Returns -1.000 (perfect negative correlation)
    
    .OUTPUTS
        Double
        Returns the correlation coefficient rounded to 3 decimal places.
        Returns 0 if arrays have fewer than 2 elements or if calculation fails.
    
    .NOTES
        This is a private helper function used by Get-GlookoDailyAnalysis and
        potentially other analysis functions.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [array]$X,
        
        [Parameter(Mandatory = $true)]
        [array]$Y
    )
    
    Write-Verbose "Calculating correlation between two arrays of length $($X.Count) and $($Y.Count)"
    
    if ($X.Count -lt 2 -or $Y.Count -lt 2) {
        Write-Verbose "Arrays too small for correlation calculation (need at least 2 values)"
        return 0
    }
    
    if ($X.Count -ne $Y.Count) {
        Write-Warning "Arrays have different lengths: X=$($X.Count), Y=$($Y.Count)"
        return 0
    }
    
    try {
        $n = $X.Count
        $sumX = ($X | Measure-Object -Sum).Sum
        $sumY = ($Y | Measure-Object -Sum).Sum
        $sumXY = 0
        $sumX2 = 0
        $sumY2 = 0
        
        for ($i = 0; $i -lt $n; $i++) {
            $sumXY += $X[$i] * $Y[$i]
            $sumX2 += $X[$i] * $X[$i]
            $sumY2 += $Y[$i] * $Y[$i]
        }
        
        $numerator = ($n * $sumXY) - ($sumX * $sumY)
        $denominator = [math]::Sqrt((($n * $sumX2) - ($sumX * $sumX)) * (($n * $sumY2) - ($sumY * $sumY)))
        
        if ($denominator -eq 0) {
            Write-Verbose "Denominator is zero, returning 0 (no variance in one or both arrays)"
            return 0
        }
        
        $correlation = [math]::Round($numerator / $denominator, 3)
        Write-Verbose "Correlation coefficient: $correlation"
        return $correlation
    }
    catch {
        Write-Warning "Error calculating correlation: $($_.Exception.Message)"
        return 0
    }
}

# Do not export this function - it's a private helper
