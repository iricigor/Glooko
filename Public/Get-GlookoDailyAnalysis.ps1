function Get-GlookoDailyAnalysis {
    <#
    .SYNOPSIS
        Analyzes CGM data and insulin data grouped by day of week with correlations.
    
    .DESCRIPTION
        This function provides comprehensive daily analysis of CGM and insulin data.
        It groups data by day of week (Monday-Sunday) and workday vs weekend,
        calculates daily insulin dosages (basal, bolus, total) with percentages,
        and correlates in-scope CGM readings with insulin values.
        
        The function accepts either separate CGM and insulin data parameters,
        or an array of datasets from Get-Glooko* functions where it will
        automatically select the appropriate datasets.
    
    .PARAMETER CGMData
        CGM data to analyze. Accepts output from Get-GlookoDataset or Import-GlookoCSV.
        Expected to have 'Timestamp' and a glucose value column.
    
    .PARAMETER InsulinData
        Insulin data to analyze. Expected to have 'Timestamp', 'Insulin Type',
        'Dose (units)', and optionally 'Method' columns.
    
    .PARAMETER InputObject
        Array of Glooko.Dataset objects from Import-GlookoFolder or Import-GlookoZip.
        The function will automatically extract 'cgm' and 'insulin' datasets.
    
    .PARAMETER LowThreshold
        Lower threshold for target range in mmol/L. Default is 4.0.
    
    .PARAMETER HighThreshold
        Upper threshold for target range in mmol/L. Default is 10.0.
    
    .PARAMETER GlucoseColumn
        Name of the column containing glucose values. 
        Default is 'CGM Glucose Value (mmol/l)'.
    
    .EXAMPLE
        Import-GlookoZip -Path "export.zip" | Get-GlookoDailyAnalysis
        Analyzes both CGM and insulin data from a zip file, grouped by day of week.
    
    .EXAMPLE
        $cgmData = Import-GlookoZip -Path "export.zip" | Get-GlookoDataset -Name "cgm"
        $insulinData = Import-GlookoZip -Path "export.zip" | Get-GlookoDataset -Name "insulin"
        Get-GlookoDailyAnalysis -CGMData $cgmData -InsulinData $insulinData
        Analyzes data with explicit dataset parameters.
    
    .EXAMPLE
        Get-GlookoDailyAnalysis -InputObject $datasets -LowThreshold 3.9 -HighThreshold 10.0
        Analyzes with custom target range (3.9-10.0 mmol/L).
    
    .OUTPUTS
        PSCustomObject
        Returns objects with DayOfWeek, DayType (Workday/Weekend), CGM statistics,
        insulin dosages with percentages, and correlation values.
    #>
    
    [CmdletBinding(DefaultParameterSetName = 'Separate')]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'Pipeline')]
        [AllowEmptyCollection()]
        [array]$InputObject,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Separate')]
        [AllowEmptyCollection()]
        [array]$CGMData,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Separate')]
        [AllowEmptyCollection()]
        [array]$InsulinData,
        
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
        Write-Verbose "Starting Get-GlookoDailyAnalysis function"
        Write-Verbose "Target range: $LowThreshold - $HighThreshold mmol/L"
        $allInputObjects = @()
    }
    
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
            foreach ($item in $InputObject) {
                $allInputObjects += $item
            }
        }
    }
    
    end {
        try {
            # Extract CGM and Insulin data based on parameter set
            if ($PSCmdlet.ParameterSetName -eq 'Pipeline') {
                Write-Verbose "Extracting datasets from pipeline input"
                
                # Check if input is array of datasets with Metadata property
                $cgmDataset = $allInputObjects | Where-Object {
                    $_.PSObject.Properties.Name -contains 'Metadata' -and
                    ($_.Metadata.Dataset -ieq 'cgm' -or $_.Metadata.FullName -like '*cgm*')
                }
                
                $insulinDataset = $allInputObjects | Where-Object {
                    $_.PSObject.Properties.Name -contains 'Metadata' -and
                    ($_.Metadata.Dataset -ieq 'insulin' -or $_.Metadata.FullName -like '*insulin*')
                }
                
                if ($cgmDataset) {
                    $CGMData = $cgmDataset | ForEach-Object { $_.Data }
                    Write-Verbose "Extracted CGM dataset with $($CGMData.Count) records"
                }
                
                if ($insulinDataset) {
                    $InsulinData = $insulinDataset | ForEach-Object { $_.Data }
                    Write-Verbose "Extracted insulin dataset with $($InsulinData.Count) records"
                }
            }
            
            # Validate we have data
            if (-not $CGMData -or $CGMData.Count -eq 0) {
                Write-Warning "No CGM data provided to analyze"
                return @()
            }
            
            if (-not $InsulinData -or $InsulinData.Count -eq 0) {
                Write-Warning "No insulin data provided to analyze"
                return @()
            }
            
            Write-Verbose "Processing $($CGMData.Count) CGM record(s) and $($InsulinData.Count) insulin record(s)"
            
            # Verify the glucose column exists
            $firstCGMRecord = $CGMData | Select-Object -First 1
            if (-not ($firstCGMRecord.PSObject.Properties.Name -contains $GlucoseColumn)) {
                Write-Error "Glucose column '$GlucoseColumn' not found in CGM data. Available columns: $($firstCGMRecord.PSObject.Properties.Name -join ', ')"
                return @()
            }
            
            # Group CGM data by date
            $cgmByDate = @{}
            foreach ($reading in $CGMData) {
                if ($reading.Timestamp) {
                    $date = ([datetime]$reading.Timestamp).Date.ToString('yyyy-MM-dd')
                    if (-not $cgmByDate.ContainsKey($date)) {
                        $cgmByDate[$date] = @()
                    }
                    $cgmByDate[$date] += $reading
                }
            }
            
            Write-Verbose "Found CGM data for $($cgmByDate.Count) date(s)"
            
            # Group insulin data by date and calculate daily totals
            $insulinByDate = @{}
            foreach ($dose in $InsulinData) {
                if ($dose.Timestamp) {
                    $date = ([datetime]$dose.Timestamp).Date.ToString('yyyy-MM-dd')
                    if (-not $insulinByDate.ContainsKey($date)) {
                        $insulinByDate[$date] = @{
                            Basal = 0.0
                            Bolus = 0.0
                            Total = 0.0
                        }
                    }
                    
                    $doseValue = [double]$dose.'Dose (units)'
                    $insulinByDate[$date].Total += $doseValue
                    
                    # Categorize by insulin type or method
                    if ($dose.'Insulin Type' -ieq 'Basal' -or $dose.Method -like '*Basal*') {
                        $insulinByDate[$date].Basal += $doseValue
                    } elseif ($dose.'Insulin Type' -ieq 'Rapid' -or $dose.Method -ieq 'Bolus') {
                        $insulinByDate[$date].Bolus += $doseValue
                    }
                }
            }
            
            Write-Verbose "Found insulin data for $($insulinByDate.Count) date(s)"
            
            # Analyze by day of week
            $dayOfWeekStats = @{}
            
            foreach ($dateStr in $cgmByDate.Keys) {
                $date = [datetime]::ParseExact($dateStr, 'yyyy-MM-dd', $null)
                $dayOfWeek = $date.DayOfWeek.ToString()
                
                if (-not $dayOfWeekStats.ContainsKey($dayOfWeek)) {
                    $dayOfWeekStats[$dayOfWeek] = @{
                        DayOfWeek = $dayOfWeek
                        DayType = if ($date.DayOfWeek -in @([DayOfWeek]::Saturday, [DayOfWeek]::Sunday)) { 'Weekend' } else { 'Workday' }
                        TotalDays = 0
                        CGMReadings = 0
                        BelowRange = 0
                        InRange = 0
                        AboveRange = 0
                        TotalBasal = 0.0
                        TotalBolus = 0.0
                        TotalInsulin = 0.0
                    }
                }
                
                $dayStats = $dayOfWeekStats[$dayOfWeek]
                $dayStats.TotalDays++
                
                # Analyze CGM readings for this day
                $readings = $cgmByDate[$dateStr]
                $dayStats.CGMReadings += $readings.Count
                
                foreach ($reading in $readings) {
                    $glucoseValue = [double]$reading.$GlucoseColumn
                    
                    if ($glucoseValue -lt $LowThreshold) {
                        $dayStats.BelowRange++
                    } elseif ($glucoseValue -le $HighThreshold) {
                        $dayStats.InRange++
                    } else {
                        $dayStats.AboveRange++
                    }
                }
                
                # Add insulin data if available for this day
                if ($insulinByDate.ContainsKey($dateStr)) {
                    $insulinDay = $insulinByDate[$dateStr]
                    $dayStats.TotalBasal += $insulinDay.Basal
                    $dayStats.TotalBolus += $insulinDay.Bolus
                    $dayStats.TotalInsulin += $insulinDay.Total
                }
            }
            
            # Calculate percentages and averages, prepare results
            $results = foreach ($dayOfWeek in @('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday')) {
                if ($dayOfWeekStats.ContainsKey($dayOfWeek)) {
                    $stats = $dayOfWeekStats[$dayOfWeek]
                    
                    # Calculate CGM percentages
                    $totalCGM = $stats.CGMReadings
                    $belowPercent = if ($totalCGM -gt 0) { [math]::Round(($stats.BelowRange / $totalCGM) * 100, 1) } else { 0 }
                    $inRangePercent = if ($totalCGM -gt 0) { [math]::Round(($stats.InRange / $totalCGM) * 100, 1) } else { 0 }
                    $abovePercent = if ($totalCGM -gt 0) { [math]::Round(($stats.AboveRange / $totalCGM) * 100, 1) } else { 0 }
                    
                    # Calculate average insulin per day
                    $avgBasal = if ($stats.TotalDays -gt 0) { [math]::Round($stats.TotalBasal / $stats.TotalDays, 1) } else { 0 }
                    $avgBolus = if ($stats.TotalDays -gt 0) { [math]::Round($stats.TotalBolus / $stats.TotalDays, 1) } else { 0 }
                    $avgTotal = if ($stats.TotalDays -gt 0) { [math]::Round($stats.TotalInsulin / $stats.TotalDays, 1) } else { 0 }
                    
                    # Calculate insulin percentages
                    $basalPercent = if ($avgTotal -gt 0) { [math]::Round(($avgBasal / $avgTotal) * 100, 1) } else { 0 }
                    $bolusPercent = if ($avgTotal -gt 0) { [math]::Round(($avgBolus / $avgTotal) * 100, 1) } else { 0 }
                    
                    [PSCustomObject]@{
                        DayOfWeek = $dayOfWeek
                        DayType = $stats.DayType
                        TotalDays = $stats.TotalDays
                        CGMReadings = $totalCGM
                        BelowRange = $stats.BelowRange
                        BelowRangePercent = $belowPercent
                        InRange = $stats.InRange
                        InRangePercent = $inRangePercent
                        AboveRange = $stats.AboveRange
                        AboveRangePercent = $abovePercent
                        AvgDailyBasal = $avgBasal
                        BasalPercent = $basalPercent
                        AvgDailyBolus = $avgBolus
                        BolusPercent = $bolusPercent
                        AvgDailyTotal = $avgTotal
                        TargetRange = "$LowThreshold-$HighThreshold mmol/L"
                    }
                }
            }
            
            # Calculate correlations between InRangePercent and insulin values
            Write-Verbose "Calculating correlations between in-range percentage and insulin values"
            
            $validResults = $results | Where-Object { $_.TotalDays -gt 0 }
            if ($validResults.Count -ge 2) {
                # Calculate correlation coefficients
                $inRangeValues = @($validResults | ForEach-Object { $_.InRangePercent })
                $basalValues = @($validResults | ForEach-Object { $_.AvgDailyBasal })
                $bolusValues = @($validResults | ForEach-Object { $_.AvgDailyBolus })
                $totalValues = @($validResults | ForEach-Object { $_.AvgDailyTotal })
                $basalPercentValues = @($validResults | ForEach-Object { $_.BasalPercent })
                $bolusPercentValues = @($validResults | ForEach-Object { $_.BolusPercent })
                
                $correlationBasal = Get-Correlation -X $inRangeValues -Y $basalValues
                $correlationBolus = Get-Correlation -X $inRangeValues -Y $bolusValues
                $correlationTotal = Get-Correlation -X $inRangeValues -Y $totalValues
                $correlationBasalPercent = Get-Correlation -X $inRangeValues -Y $basalPercentValues
                $correlationBolusPercent = Get-Correlation -X $inRangeValues -Y $bolusPercentValues
                
                # Add correlation information to each result
                foreach ($result in $results) {
                    $result | Add-Member -NotePropertyName 'CorrelationWithBasal' -NotePropertyValue $correlationBasal -Force
                    $result | Add-Member -NotePropertyName 'CorrelationWithBolus' -NotePropertyValue $correlationBolus -Force
                    $result | Add-Member -NotePropertyName 'CorrelationWithTotal' -NotePropertyValue $correlationTotal -Force
                    $result | Add-Member -NotePropertyName 'CorrelationWithBasalPercent' -NotePropertyValue $correlationBasalPercent -Force
                    $result | Add-Member -NotePropertyName 'CorrelationWithBolusPercent' -NotePropertyValue $correlationBolusPercent -Force
                }
                
                Write-Verbose "Correlation with Basal: $correlationBasal"
                Write-Verbose "Correlation with Bolus: $correlationBolus"
                Write-Verbose "Correlation with Total: $correlationTotal"
            }
            
            Write-Verbose "Completed analysis for $($results.Count) day(s) of week"
            return $results
        }
        catch {
            Write-Error "Error analyzing daily data: $($_.Exception.Message)"
            throw
        }
        finally {
            Write-Verbose "Get-GlookoDailyAnalysis function completed"
        }
    }
}

# Export the function if this script is being dot-sourced
Export-ModuleMember -Function Get-GlookoDailyAnalysis
