function Get-GlookoCGMStats {
    <#
    .SYNOPSIS
        Analyzes CGM data and provides basic statistics grouped by date.
    
    .DESCRIPTION
        This function analyzes Continuous Glucose Monitoring (CGM) data and calculates
        statistics for readings that are in range, above range, and below range.
        Results are grouped by date and include both counts and percentages.
        
        Default ranges (mmol/L):
        - Below range: < 4.0 mmol/L (< 70 mg/dL)
        - In range: 4.0-10.0 mmol/L (70-180 mg/dL)
        - Above range: > 10.0 mmol/L (> 180 mg/dL)
    
    .PARAMETER InputObject
        CGM data to analyze. Accepts output from Get-GlookoDataset or Import-GlookoCSV.
        Expected to have 'Timestamp' and a glucose value column.
    
    .PARAMETER LowThreshold
        Lower threshold for target range in mmol/L. Default is 4.0.
    
    .PARAMETER HighThreshold
        Upper threshold for target range in mmol/L. Default is 10.0.
    
    .PARAMETER GlucoseColumn
        Name of the column containing glucose values. 
        Default is 'CGM Glucose Value (mmol/l)'.
    
    .EXAMPLE
        Import-GlookoZip -Path "export.zip" | Get-GlookoDataset -Name "cgm" | Get-GlookoCGMStats
        Analyzes CGM data from a zip file and shows in-range statistics by date.
    
    .EXAMPLE
        $cgmData = Import-GlookoCSV -Path "cgm.csv"
        Get-GlookoCGMStats -InputObject $cgmData.Data
        Analyzes CGM data from a single CSV file.
    
    .EXAMPLE
        $stats = Get-GlookoCGMStats -InputObject $cgmData -LowThreshold 3.9 -HighThreshold 10.0
        Analyzes with custom target range (3.9-10.0 mmol/L).
    
    .OUTPUTS
        PSCustomObject
        Returns objects with Date, BelowRange, InRange, AboveRange statistics including counts and percentages.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [array]$InputObject,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 50)]
        [double]$LowThreshold = 4.0,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 50)]
        [double]$HighThreshold = 10.0,
        
        [Parameter(Mandatory = $false)]
        [string]$GlucoseColumn = 'CGM Glucose Value (mmol/l)'
    )
    
    begin {
        Write-Verbose "Starting Get-GlookoCGMStats function"
        Write-Verbose "Target range: $LowThreshold - $HighThreshold mmol/L"
        $allData = @()
    }
    
    process {
        foreach ($item in $InputObject) {
            $allData += $item
        }
    }
    
    end {
        try {
            if ($allData.Count -eq 0) {
                Write-Warning "No CGM data provided to analyze"
                return @()
            }
            
            Write-Verbose "Processing $($allData.Count) CGM reading(s)"
            
            # Verify the glucose column exists
            $firstRecord = $allData | Select-Object -First 1
            if (-not ($firstRecord.PSObject.Properties.Name -contains $GlucoseColumn)) {
                Write-Error "Glucose column '$GlucoseColumn' not found in data. Available columns: $($firstRecord.PSObject.Properties.Name -join ', ')"
                return @()
            }
            
            # Group data by date
            $groupedByDate = $allData | Group-Object -Property { 
                if ($_.Timestamp) {
                    ([datetime]$_.Timestamp).ToString('yyyy-MM-dd')
                } else {
                    'Unknown'
                }
            }
            
            Write-Verbose "Found data for $($groupedByDate.Count) date(s)"
            
            $results = foreach ($dateGroup in $groupedByDate) {
                $date = $dateGroup.Name
                $readings = $dateGroup.Group
                
                Write-Verbose "Analyzing $($readings.Count) reading(s) for $date"
                
                # Count readings in each category
                $belowCount = 0
                $inRangeCount = 0
                $aboveCount = 0
                
                foreach ($reading in $readings) {
                    $glucoseValue = [double]$reading.$GlucoseColumn
                    
                    if ($glucoseValue -lt $LowThreshold) {
                        $belowCount++
                    } elseif ($glucoseValue -le $HighThreshold) {
                        $inRangeCount++
                    } else {
                        $aboveCount++
                    }
                }
                
                $totalCount = $readings.Count
                
                # Calculate percentages
                $belowPercent = if ($totalCount -gt 0) { [math]::Round(($belowCount / $totalCount) * 100, 1) } else { 0 }
                $inRangePercent = if ($totalCount -gt 0) { [math]::Round(($inRangeCount / $totalCount) * 100, 1) } else { 0 }
                $abovePercent = if ($totalCount -gt 0) { [math]::Round(($aboveCount / $totalCount) * 100, 1) } else { 0 }
                
                # Create result object
                [PSCustomObject]@{
                    Date = $date
                    TotalReadings = $totalCount
                    BelowRange = $belowCount
                    BelowRangePercent = $belowPercent
                    InRange = $inRangeCount
                    InRangePercent = $inRangePercent
                    AboveRange = $aboveCount
                    AboveRangePercent = $abovePercent
                    TargetRange = "$LowThreshold-$HighThreshold mmol/L"
                }
            }
            
            Write-Verbose "Completed analysis for $($results.Count) date(s)"
            return $results
        }
        catch {
            Write-Error "Error analyzing CGM data: $($_.Exception.Message)"
            throw
        }
        finally {
            Write-Verbose "Get-GlookoCGMStats function completed"
        }
    }
}

# Export the function if this script is being dot-sourced
Export-ModuleMember -Function Get-GlookoCGMStats
