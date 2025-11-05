function Get-GlookoCGMStatsExtended {
    <#
    .SYNOPSIS
        Analyzes CGM data with extended statistics including very low and very high categories.
    
    .DESCRIPTION
        This function provides detailed analysis of Continuous Glucose Monitoring (CGM) data
        with customizable ranges. By default, uses three categories (low, in range, high).
        When UseVeryLowHigh switch is enabled, adds very low and very high categories.
        Results are grouped by date and include both counts and percentages. Supports date range filtering.
        
        Default ranges without UseVeryLowHigh (mmol/L):
        - Low: < 4.0 mmol/L (< 70 mg/dL)
        - In Range: 4.0-10.0 mmol/L (70-180 mg/dL)
        - High: > 10.0 mmol/L (> 180 mg/dL)
        
        Default ranges with UseVeryLowHigh (mmol/L):
        - Very Low: < 3.0 mmol/L (< 54 mg/dL)
        - Low: 3.0-3.9 mmol/L (54-70 mg/dL)
        - In Range: 4.0-10.0 mmol/L (70-180 mg/dL)
        - High: 10.1-13.9 mmol/L (181-250 mg/dL)
        - Very High: >= 14.0 mmol/L (>= 250 mg/dL)
    
    .PARAMETER InputObject
        CGM data to analyze. Accepts output from Get-GlookoDataset or Import-GlookoCSV.
        Expected to have 'Timestamp' and a glucose value column.
    
    .PARAMETER UseVeryLowHigh
        Switch to enable very low and very high categories. When enabled, uses five categories
        instead of three. When disabled, uses same categories as Get-GlookoCGMStats.
    
    .PARAMETER VeryLowThreshold
        Threshold for very low readings in mmol/L. Default is 3.0. Only used when UseVeryLowHigh is enabled.
        Readings below this are considered very low.
    
    .PARAMETER LowThreshold
        Lower threshold for target range in mmol/L. Default is 4.0.
        When UseVeryLowHigh is disabled: readings below this are considered low.
        When UseVeryLowHigh is enabled: readings between VeryLowThreshold and LowThreshold are considered low.
    
    .PARAMETER HighThreshold
        Upper threshold for target range in mmol/L. Default is 10.0.
        Readings between LowThreshold and HighThreshold are considered in range.
    
    .PARAMETER VeryHighThreshold
        Threshold for very high readings in mmol/L. Default is 14.0. Only used when UseVeryLowHigh is enabled.
        Readings above this are considered very high.
    
    .PARAMETER GlucoseColumn
        Name of the column containing glucose values. 
        Default is 'CGM Glucose Value (mmol/l)'.
    
    .PARAMETER StartDate
        Start date for filtering data (inclusive). Format: yyyy-MM-dd
    
    .PARAMETER EndDate
        End date for filtering data (inclusive). Format: yyyy-MM-dd
    
    .PARAMETER Days
        Number of days to include in analysis (from most recent date backwards).
    
    .EXAMPLE
        Import-GlookoZip -Path "export.zip" | Get-GlookoDataset -Name "cgm" | Get-GlookoCGMStatsExtended
        Analyzes CGM data with three categories (low, in range, high) grouped by date.
    
    .EXAMPLE
        $cgmData | Get-GlookoCGMStatsExtended -UseVeryLowHigh
        Analyzes CGM data with five categories including very low and very high.
    
    .EXAMPLE
        $cgmData = Import-GlookoCSV -Path "cgm.csv"
        Get-GlookoCGMStatsExtended -InputObject $cgmData.Data -Days 7
        Analyzes the last 7 days of CGM data.
    
    .EXAMPLE
        Get-GlookoCGMStatsExtended -InputObject $cgmData -StartDate "2025-10-20" -EndDate "2025-10-27"
        Analyzes CGM data for a specific date range.
    
    .EXAMPLE
        Get-GlookoCGMStatsExtended -InputObject $cgmData -UseVeryLowHigh -VeryLowThreshold 2.8 -VeryHighThreshold 15.0
        Analyzes with custom thresholds for very low and very high categories.
    
    .OUTPUTS
        PSCustomObject
        Returns objects with Date and detailed statistics for each glucose category.
        
        Without UseVeryLowHigh: Low, InRange, High (same as Get-GlookoCGMStats)
        With UseVeryLowHigh: VeryLow, Low, InRange, High, VeryHigh
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [array]$InputObject,
        
        [Parameter(Mandatory = $false)]
        [switch]$UseVeryLowHigh,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 50)]
        [double]$VeryLowThreshold = 3.0,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 50)]
        [double]$LowThreshold = 4.0,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 50)]
        [double]$HighThreshold = 10.0,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(0, 50)]
        [double]$VeryHighThreshold = 14.0,
        
        [Parameter(Mandatory = $false)]
        [string]$GlucoseColumn = 'CGM Glucose Value (mmol/l)',
        
        [Parameter(Mandatory = $false)]
        [datetime]$StartDate,
        
        [Parameter(Mandatory = $false)]
        [datetime]$EndDate,
        
        [Parameter(Mandatory = $false)]
        [ValidateRange(1, 365)]
        [int]$Days
    )
    
    begin {
        Write-Verbose "Starting Get-GlookoCGMStatsExtended function"
        if ($UseVeryLowHigh) {
            Write-Verbose "Thresholds: VeryLow<$VeryLowThreshold, Low=$VeryLowThreshold-$LowThreshold, InRange=$LowThreshold-$HighThreshold, High=$HighThreshold-$VeryHighThreshold, VeryHigh>=$VeryHighThreshold mmol/L"
        } else {
            Write-Verbose "Thresholds: Low<$LowThreshold, InRange=$LowThreshold-$HighThreshold, High>$HighThreshold mmol/L"
        }
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
            
            # Filter by date if specified
            $filteredData = $allData
            
            if ($PSBoundParameters.ContainsKey('StartDate') -or $PSBoundParameters.ContainsKey('EndDate') -or $PSBoundParameters.ContainsKey('Days')) {
                Write-Verbose "Applying date filters..."
                
                # Convert timestamps to datetime for filtering
                $dataWithDates = $filteredData | Where-Object { $_.Timestamp } | ForEach-Object {
                    $_ | Add-Member -NotePropertyName 'ParsedDate' -NotePropertyValue ([datetime]$_.Timestamp) -PassThru -Force
                }
                
                if ($PSBoundParameters.ContainsKey('Days')) {
                    $maxDate = ($dataWithDates | Measure-Object -Property ParsedDate -Maximum).Maximum
                    $minDate = $maxDate.AddDays(-$Days + 1).Date
                    Write-Verbose "Filtering to last $Days days: $($minDate.ToString('yyyy-MM-dd')) to $($maxDate.ToString('yyyy-MM-dd'))"
                    $filteredData = $dataWithDates | Where-Object { $_.ParsedDate -ge $minDate }
                } else {
                    if ($PSBoundParameters.ContainsKey('StartDate')) {
                        Write-Verbose "Filtering from $($StartDate.ToString('yyyy-MM-dd'))"
                        $dataWithDates = $dataWithDates | Where-Object { $_.ParsedDate.Date -ge $StartDate.Date }
                    }
                    if ($PSBoundParameters.ContainsKey('EndDate')) {
                        Write-Verbose "Filtering to $($EndDate.ToString('yyyy-MM-dd'))"
                        $dataWithDates = $dataWithDates | Where-Object { $_.ParsedDate.Date -le $EndDate.Date }
                    }
                    $filteredData = $dataWithDates
                }
                
                Write-Verbose "After filtering: $($filteredData.Count) reading(s)"
            }
            
            if ($filteredData.Count -eq 0) {
                Write-Warning "No data remaining after date filtering"
                return @()
            }
            
            # Group data by date
            $groupedByDate = $filteredData | Group-Object -Property { 
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
                
                if ($UseVeryLowHigh) {
                    # Count readings in five categories
                    $veryLowCount = 0
                    $lowCount = 0
                    $inRangeCount = 0
                    $highCount = 0
                    $veryHighCount = 0
                    
                    foreach ($reading in $readings) {
                        $glucoseValue = [double]$reading.$GlucoseColumn
                        
                        if ($glucoseValue -lt $VeryLowThreshold) {
                            $veryLowCount++
                        } elseif ($glucoseValue -lt $LowThreshold) {
                            $lowCount++
                        } elseif ($glucoseValue -le $HighThreshold) {
                            $inRangeCount++
                        } elseif ($glucoseValue -lt $VeryHighThreshold) {
                            $highCount++
                        } else {
                            $veryHighCount++
                        }
                    }
                    
                    $totalCount = $readings.Count
                    
                    # Calculate percentages
                    $veryLowPercent = if ($totalCount -gt 0) { [math]::Round(($veryLowCount / $totalCount) * 100, 1) } else { 0 }
                    $lowPercent = if ($totalCount -gt 0) { [math]::Round(($lowCount / $totalCount) * 100, 1) } else { 0 }
                    $inRangePercent = if ($totalCount -gt 0) { [math]::Round(($inRangeCount / $totalCount) * 100, 1) } else { 0 }
                    $highPercent = if ($totalCount -gt 0) { [math]::Round(($highCount / $totalCount) * 100, 1) } else { 0 }
                    $veryHighPercent = if ($totalCount -gt 0) { [math]::Round(($veryHighCount / $totalCount) * 100, 1) } else { 0 }
                    
                    # Create result object with five categories
                    [PSCustomObject]@{
                        Date = $date
                        TotalReadings = $totalCount
                        VeryLow = $veryLowCount
                        VeryLowPercent = $veryLowPercent
                        Low = $lowCount
                        LowPercent = $lowPercent
                        InRange = $inRangeCount
                        InRangePercent = $inRangePercent
                        High = $highCount
                        HighPercent = $highPercent
                        VeryHigh = $veryHighCount
                        VeryHighPercent = $veryHighPercent
                        Ranges = "VeryLow<$VeryLowThreshold, Low=$VeryLowThreshold-$LowThreshold, InRange=$LowThreshold-$HighThreshold, High=$HighThreshold-$VeryHighThreshold, VeryHigh>=$VeryHighThreshold mmol/L"
                    }
                } else {
                    # Count readings in three categories (same as basic function)
                    $lowCount = 0
                    $inRangeCount = 0
                    $highCount = 0
                    
                    foreach ($reading in $readings) {
                        $glucoseValue = [double]$reading.$GlucoseColumn
                        
                        if ($glucoseValue -lt $LowThreshold) {
                            $lowCount++
                        } elseif ($glucoseValue -le $HighThreshold) {
                            $inRangeCount++
                        } else {
                            $highCount++
                        }
                    }
                    
                    $totalCount = $readings.Count
                    
                    # Calculate percentages
                    $lowPercent = if ($totalCount -gt 0) { [math]::Round(($lowCount / $totalCount) * 100, 1) } else { 0 }
                    $inRangePercent = if ($totalCount -gt 0) { [math]::Round(($inRangeCount / $totalCount) * 100, 1) } else { 0 }
                    $highPercent = if ($totalCount -gt 0) { [math]::Round(($highCount / $totalCount) * 100, 1) } else { 0 }
                    
                    # Create result object with three categories
                    [PSCustomObject]@{
                        Date = $date
                        TotalReadings = $totalCount
                        Low = $lowCount
                        LowPercent = $lowPercent
                        InRange = $inRangeCount
                        InRangePercent = $inRangePercent
                        High = $highCount
                        HighPercent = $highPercent
                        TargetRange = "$LowThreshold-$HighThreshold mmol/L"
                    }
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
            Write-Verbose "Get-GlookoCGMStatsExtended function completed"
        }
    }
}

# Export the function if this script is being dot-sourced
Export-ModuleMember -Function Get-GlookoCGMStatsExtended
