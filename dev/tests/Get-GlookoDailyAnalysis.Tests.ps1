BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
}

AfterAll {
    # Remove the module
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Get-GlookoDailyAnalysis' {
    
    BeforeAll {
        # Create test CGM data for a week (Jan 1-7, 2025: Wed-Tue)
        # Jan 1 = Wednesday, Jan 6 = Monday
        $Script:TestCGMData = @(
            # Wednesday Jan 1 - mostly in range
            [PSCustomObject]@{ Timestamp = '2025-01-01 08:00'; 'CGM Glucose Value (mmol/l)' = 5.5 }
            [PSCustomObject]@{ Timestamp = '2025-01-01 12:00'; 'CGM Glucose Value (mmol/l)' = 6.2 }
            [PSCustomObject]@{ Timestamp = '2025-01-01 16:00'; 'CGM Glucose Value (mmol/l)' = 8.0 }
            [PSCustomObject]@{ Timestamp = '2025-01-01 20:00'; 'CGM Glucose Value (mmol/l)' = 7.5 }
            # Thursday Jan 2 - some high readings
            [PSCustomObject]@{ Timestamp = '2025-01-02 08:00'; 'CGM Glucose Value (mmol/l)' = 11.0 }
            [PSCustomObject]@{ Timestamp = '2025-01-02 12:00'; 'CGM Glucose Value (mmol/l)' = 9.0 }
            [PSCustomObject]@{ Timestamp = '2025-01-02 16:00'; 'CGM Glucose Value (mmol/l)' = 12.0 }
            # Friday Jan 3 - balanced
            [PSCustomObject]@{ Timestamp = '2025-01-03 08:00'; 'CGM Glucose Value (mmol/l)' = 3.5 }
            [PSCustomObject]@{ Timestamp = '2025-01-03 12:00'; 'CGM Glucose Value (mmol/l)' = 7.0 }
            [PSCustomObject]@{ Timestamp = '2025-01-03 16:00'; 'CGM Glucose Value (mmol/l)' = 6.5 }
            # Saturday Jan 4 - weekend, in range
            [PSCustomObject]@{ Timestamp = '2025-01-04 10:00'; 'CGM Glucose Value (mmol/l)' = 5.0 }
            [PSCustomObject]@{ Timestamp = '2025-01-04 14:00'; 'CGM Glucose Value (mmol/l)' = 6.0 }
            [PSCustomObject]@{ Timestamp = '2025-01-04 18:00'; 'CGM Glucose Value (mmol/l)' = 7.0 }
            # Sunday Jan 5 - weekend, in range
            [PSCustomObject]@{ Timestamp = '2025-01-05 10:00'; 'CGM Glucose Value (mmol/l)' = 6.5 }
            [PSCustomObject]@{ Timestamp = '2025-01-05 14:00'; 'CGM Glucose Value (mmol/l)' = 7.5 }
            # Monday Jan 6 - balanced
            [PSCustomObject]@{ Timestamp = '2025-01-06 08:00'; 'CGM Glucose Value (mmol/l)' = 5.5 }
            [PSCustomObject]@{ Timestamp = '2025-01-06 12:00'; 'CGM Glucose Value (mmol/l)' = 8.5 }
            [PSCustomObject]@{ Timestamp = '2025-01-06 16:00'; 'CGM Glucose Value (mmol/l)' = 6.0 }
            # Tuesday Jan 7 - balanced
            [PSCustomObject]@{ Timestamp = '2025-01-07 08:00'; 'CGM Glucose Value (mmol/l)' = 7.0 }
            [PSCustomObject]@{ Timestamp = '2025-01-07 12:00'; 'CGM Glucose Value (mmol/l)' = 8.0 }
        )
        
        # Create test insulin data
        $Script:TestInsulinData = @(
            # Wednesday Jan 1 - basal and bolus
            [PSCustomObject]@{ Timestamp = '2025-01-01 08:00'; 'Insulin Type' = 'Rapid'; 'Dose (units)' = 10.0; Method = 'Bolus' }
            [PSCustomObject]@{ Timestamp = '2025-01-01 12:00'; 'Insulin Type' = 'Basal'; 'Dose (units)' = 1.5; Method = 'Auto-Basal' }
            [PSCustomObject]@{ Timestamp = '2025-01-01 16:00'; 'Insulin Type' = 'Basal'; 'Dose (units)' = 1.5; Method = 'Auto-Basal' }
            [PSCustomObject]@{ Timestamp = '2025-01-01 20:00'; 'Insulin Type' = 'Rapid'; 'Dose (units)' = 8.0; Method = 'Bolus' }
            # Thursday Jan 2
            [PSCustomObject]@{ Timestamp = '2025-01-02 08:00'; 'Insulin Type' = 'Rapid'; 'Dose (units)' = 12.0; Method = 'Bolus' }
            [PSCustomObject]@{ Timestamp = '2025-01-02 12:00'; 'Insulin Type' = 'Basal'; 'Dose (units)' = 1.5; Method = 'Auto-Basal' }
            [PSCustomObject]@{ Timestamp = '2025-01-02 16:00'; 'Insulin Type' = 'Basal'; 'Dose (units)' = 1.5; Method = 'Auto-Basal' }
            # Friday Jan 3
            [PSCustomObject]@{ Timestamp = '2025-01-03 08:00'; 'Insulin Type' = 'Rapid'; 'Dose (units)' = 9.0; Method = 'Bolus' }
            [PSCustomObject]@{ Timestamp = '2025-01-03 12:00'; 'Insulin Type' = 'Basal'; 'Dose (units)' = 1.5; Method = 'Auto-Basal' }
            [PSCustomObject]@{ Timestamp = '2025-01-03 16:00'; 'Insulin Type' = 'Rapid'; 'Dose (units)' = 7.0; Method = 'Bolus' }
            # Saturday Jan 4
            [PSCustomObject]@{ Timestamp = '2025-01-04 10:00'; 'Insulin Type' = 'Rapid'; 'Dose (units)' = 8.0; Method = 'Bolus' }
            [PSCustomObject]@{ Timestamp = '2025-01-04 14:00'; 'Insulin Type' = 'Basal'; 'Dose (units)' = 1.5; Method = 'Auto-Basal' }
            # Sunday Jan 5
            [PSCustomObject]@{ Timestamp = '2025-01-05 10:00'; 'Insulin Type' = 'Rapid'; 'Dose (units)' = 8.0; Method = 'Bolus' }
            [PSCustomObject]@{ Timestamp = '2025-01-05 14:00'; 'Insulin Type' = 'Basal'; 'Dose (units)' = 1.5; Method = 'Auto-Basal' }
            # Monday Jan 6
            [PSCustomObject]@{ Timestamp = '2025-01-06 08:00'; 'Insulin Type' = 'Rapid'; 'Dose (units)' = 10.0; Method = 'Bolus' }
            [PSCustomObject]@{ Timestamp = '2025-01-06 12:00'; 'Insulin Type' = 'Basal'; 'Dose (units)' = 1.5; Method = 'Auto-Basal' }
            # Tuesday Jan 7
            [PSCustomObject]@{ Timestamp = '2025-01-07 08:00'; 'Insulin Type' = 'Rapid'; 'Dose (units)' = 9.0; Method = 'Bolus' }
            [PSCustomObject]@{ Timestamp = '2025-01-07 12:00'; 'Insulin Type' = 'Basal'; 'Dose (units)' = 1.5; Method = 'Auto-Basal' }
        )
    }
    
    Context 'Basic functionality with separate parameters' {
        
        It 'Should analyze data and return results for each day of week' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 7  # All days of week
        }
        
        It 'Should include correct day of week names' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $dayNames = $result | ForEach-Object { $_.DayOfWeek }
            $dayNames | Should -Contain 'Monday'
            $dayNames | Should -Contain 'Tuesday'
            $dayNames | Should -Contain 'Wednesday'
            $dayNames | Should -Contain 'Thursday'
            $dayNames | Should -Contain 'Friday'
            $dayNames | Should -Contain 'Saturday'
            $dayNames | Should -Contain 'Sunday'
        }
        
        It 'Should categorize weekdays and weekends correctly' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $saturday = $result | Where-Object { $_.DayOfWeek -eq 'Saturday' }
            $saturday.DayType | Should -Be 'Weekend'
            
            $sunday = $result | Where-Object { $_.DayOfWeek -eq 'Sunday' }
            $sunday.DayType | Should -Be 'Weekend'
            
            $monday = $result | Where-Object { $_.DayOfWeek -eq 'Monday' }
            $monday.DayType | Should -Be 'Workday'
        }
    }
    
    Context 'CGM statistics calculation' {
        
        It 'Should calculate correct CGM reading counts' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $wednesday = $result | Where-Object { $_.DayOfWeek -eq 'Wednesday' }
            $wednesday.CGMReadings | Should -Be 4  # 4 readings on Wednesday
            
            $thursday = $result | Where-Object { $_.DayOfWeek -eq 'Thursday' }
            $thursday.CGMReadings | Should -Be 3  # 3 readings on Thursday
        }
        
        It 'Should calculate in-range percentages correctly' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $wednesday = $result | Where-Object { $_.DayOfWeek -eq 'Wednesday' }
            $wednesday.InRange | Should -Be 4  # All 4 readings in range
            $wednesday.InRangePercent | Should -Be 100.0
        }
        
        It 'Should calculate below and above range correctly' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $thursday = $result | Where-Object { $_.DayOfWeek -eq 'Thursday' }
            $thursday.AboveRange | Should -Be 2  # 11.0 and 12.0
            $thursday.InRange | Should -Be 1     # 9.0
            
            $friday = $result | Where-Object { $_.DayOfWeek -eq 'Friday' }
            $friday.BelowRange | Should -Be 1    # 3.5
            $friday.InRange | Should -Be 2       # 7.0 and 6.5
        }
    }
    
    Context 'Insulin statistics calculation' {
        
        It 'Should calculate average daily insulin correctly' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $wednesday = $result | Where-Object { $_.DayOfWeek -eq 'Wednesday' }
            # Wednesday: 10.0 + 8.0 bolus = 18.0, 1.5 + 1.5 basal = 3.0, total = 21.0
            $wednesday.AvgDailyBolus | Should -Be 18.0
            $wednesday.AvgDailyBasal | Should -Be 3.0
            $wednesday.AvgDailyTotal | Should -Be 21.0
        }
        
        It 'Should calculate insulin percentages correctly' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $wednesday = $result | Where-Object { $_.DayOfWeek -eq 'Wednesday' }
            # 18.0 bolus / 21.0 total = 85.7%, 3.0 basal / 21.0 = 14.3%
            $wednesday.BolusPercent | Should -Be 85.7
            $wednesday.BasalPercent | Should -Be 14.3
        }
        
        It 'Should handle different insulin amounts per day' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $friday = $result | Where-Object { $_.DayOfWeek -eq 'Friday' }
            # Friday: 9.0 + 7.0 bolus = 16.0, 1.5 basal, total = 17.5
            $friday.AvgDailyBolus | Should -Be 16.0
            $friday.AvgDailyBasal | Should -Be 1.5
            $friday.AvgDailyTotal | Should -Be 17.5
        }
    }
    
    Context 'Correlation calculation' {
        
        It 'Should include correlation properties' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $firstDay = $result | Select-Object -First 1
            $firstDay.PSObject.Properties.Name | Should -Contain 'CorrelationWithBasal'
            $firstDay.PSObject.Properties.Name | Should -Contain 'CorrelationWithBolus'
            $firstDay.PSObject.Properties.Name | Should -Contain 'CorrelationWithTotal'
            $firstDay.PSObject.Properties.Name | Should -Contain 'CorrelationWithBasalPercent'
            $firstDay.PSObject.Properties.Name | Should -Contain 'CorrelationWithBolusPercent'
        }
        
        It 'Should calculate correlation values' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData
            
            $firstDay = $result | Select-Object -First 1
            # Correlations should be numeric values between -1 and 1
            $firstDay.CorrelationWithBasal | Should -Not -BeNullOrEmpty
            $firstDay.CorrelationWithBasal | Should -BeGreaterOrEqual -1
            $firstDay.CorrelationWithBasal | Should -BeLessOrEqual 1
            $firstDay.CorrelationWithBolus | Should -Not -BeNullOrEmpty
            $firstDay.CorrelationWithTotal | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Pipeline input support' {
        
        It 'Should accept pipeline input with dataset objects' {
            # Create dataset objects mimicking Import-GlookoZip output
            $datasets = @(
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{ Dataset = 'cgm'; FullName = 'cgm_data.csv' }
                    Data = $Script:TestCGMData
                }
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{ Dataset = 'insulin'; FullName = 'insulin_data.csv' }
                    Data = $Script:TestInsulinData
                }
            )
            
            $result = $datasets | Get-GlookoDailyAnalysis
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 7
        }
    }
    
    Context 'Custom thresholds' {
        
        It 'Should use custom low and high thresholds' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData -LowThreshold 3.9 -HighThreshold 9.0
            
            $result | Should -Not -BeNullOrEmpty
            $result[0].TargetRange | Should -Be '3.9-9 mmol/L'
        }
        
        It 'Should recalculate statistics with custom thresholds' {
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData -LowThreshold 3.9 -HighThreshold 9.0
            
            $thursday = $result | Where-Object { $_.DayOfWeek -eq 'Thursday' }
            # With threshold 9.0: 11.0 and 12.0 are above, 9.0 is in range
            $thursday.AboveRange | Should -Be 2
            $thursday.InRange | Should -Be 1
        }
    }
    
    Context 'Edge cases and error handling' {
        
        It 'Should handle empty CGM data' {
            $warnings = @()
            $result = Get-GlookoDailyAnalysis -CGMData @() -InsulinData $Script:TestInsulinData -WarningVariable warnings -WarningAction SilentlyContinue
            
            $result | Should -BeNullOrEmpty
            $warnings | Should -Not -BeNullOrEmpty
        }
        
        It 'Should handle empty insulin data' {
            $warnings = @()
            $result = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData @() -WarningVariable warnings -WarningAction SilentlyContinue
            
            $result | Should -BeNullOrEmpty
            $warnings | Should -Not -BeNullOrEmpty
        }
        
        It 'Should handle data with missing timestamps' {
            $badCGM = @(
                [PSCustomObject]@{ 'CGM Glucose Value (mmol/l)' = 5.5 }  # No timestamp
            )
            $badInsulin = @(
                [PSCustomObject]@{ 'Insulin Type' = 'Rapid'; 'Dose (units)' = 10.0; Method = 'Bolus' }  # No timestamp
            )
            
            $result = Get-GlookoDailyAnalysis -CGMData $badCGM -InsulinData $badInsulin -WarningAction SilentlyContinue
            
            # Should complete without error but returns empty results since no valid dates
            $result.Count | Should -Be 0
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output' {
            $verboseOutput = Get-GlookoDailyAnalysis -CGMData $Script:TestCGMData -InsulinData $Script:TestInsulinData -Verbose 4>&1
            
            $verboseOutput | Should -Not -BeNullOrEmpty
            $verboseStrings = $verboseOutput | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
            $verboseStrings | Should -Not -BeNullOrEmpty
        }
    }
}
