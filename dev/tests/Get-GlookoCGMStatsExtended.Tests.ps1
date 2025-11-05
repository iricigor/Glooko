BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
}

AfterAll {
    # Remove the module
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Get-GlookoCGMStatsExtended' {
    
    BeforeAll {
        # Create test CGM data spanning multiple days
        $Script:TestCGMData = @(
            [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; 'CGM Glucose Value (mmol/l)' = 2.5 }  # Very low
            [PSCustomObject]@{ Timestamp = '2025-10-26 06:00'; 'CGM Glucose Value (mmol/l)' = 3.5 }  # Low
            [PSCustomObject]@{ Timestamp = '2025-10-26 12:00'; 'CGM Glucose Value (mmol/l)' = 7.0 }  # In range
            [PSCustomObject]@{ Timestamp = '2025-10-26 18:00'; 'CGM Glucose Value (mmol/l)' = 12.0 } # High
            [PSCustomObject]@{ Timestamp = '2025-10-26 22:00'; 'CGM Glucose Value (mmol/l)' = 15.0 } # Very high
            [PSCustomObject]@{ Timestamp = '2025-10-27 00:00'; 'CGM Glucose Value (mmol/l)' = 5.0 }  # In range
            [PSCustomObject]@{ Timestamp = '2025-10-27 12:00'; 'CGM Glucose Value (mmol/l)' = 8.5 }  # In range
            [PSCustomObject]@{ Timestamp = '2025-10-28 00:00'; 'CGM Glucose Value (mmol/l)' = 6.5 }  # In range
        )
    }
    
    Context 'Basic functionality - 3 categories (default)' {
        
        It 'Should analyze CGM data and return statistics with 3 categories by default' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 3  # Three dates
            
            # Should have 3-category properties
            $result[0].PSObject.Properties.Name | Should -Contain 'Low'
            $result[0].PSObject.Properties.Name | Should -Contain 'InRange'
            $result[0].PSObject.Properties.Name | Should -Contain 'High'
            $result[0].PSObject.Properties.Name | Should -Not -Contain 'VeryLow'
            $result[0].PSObject.Properties.Name | Should -Not -Contain 'VeryHigh'
        }
        
        It 'Should calculate correct counts for 3 categories' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.TotalReadings | Should -Be 5
            $day1.Low | Should -Be 2      # 2.5, 3.5 (both < 4.0)
            $day1.InRange | Should -Be 1  # 7.0
            $day1.High | Should -Be 2     # 12.0, 15.0 (both > 10.0)
        }
    }
    
    Context 'Basic functionality - 5 categories (with UseVeryLowHigh)' {
        
        It 'Should analyze CGM data and return extended statistics with 5 categories' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 3  # Three dates
            
            # Should have 5-category properties
            $result[0].PSObject.Properties.Name | Should -Contain 'VeryLow'
            $result[0].PSObject.Properties.Name | Should -Contain 'Low'
            $result[0].PSObject.Properties.Name | Should -Contain 'InRange'
            $result[0].PSObject.Properties.Name | Should -Contain 'High'
            $result[0].PSObject.Properties.Name | Should -Contain 'VeryHigh'
        }
        
        It 'Should calculate correct counts for all categories' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.TotalReadings | Should -Be 5
            $day1.VeryLow | Should -Be 1   # 2.5
            $day1.Low | Should -Be 1       # 3.5
            $day1.InRange | Should -Be 1   # 7.0
            $day1.High | Should -Be 1      # 12.0
            $day1.VeryHigh | Should -Be 1  # 15.0
        }
        
        It 'Should calculate correct percentages for 5 categories' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.VeryLowPercent | Should -Be 20.0
            $day1.LowPercent | Should -Be 20.0
            $day1.InRangePercent | Should -Be 20.0
            $day1.HighPercent | Should -Be 20.0
            $day1.VeryHighPercent | Should -Be 20.0
        }
        
        It 'Should include range definitions in output for 5 categories' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh
            
            $result[0].Ranges | Should -Match 'VeryLow<3'
            $result[0].Ranges | Should -Match 'Low=3-4'
            $result[0].Ranges | Should -Match 'InRange=4-10'
            $result[0].Ranges | Should -Match 'High=10-14'
            $result[0].Ranges | Should -Match 'VeryHigh>=14'
        }
    }
    
    Context 'Custom thresholds - 3 categories' {
        
        It 'Should support custom low threshold' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -LowThreshold 5.0
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            # With low=5.0: 2.5, 3.5 are < 5.0 (low)
            $day1.Low | Should -Be 2
        }
        
        It 'Should support custom high threshold' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -HighThreshold 8.0
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            # With high=8.0: 12.0, 15.0 are > 8.0 (high)
            $day1.High | Should -Be 2
        }
    }
    
    Context 'Custom thresholds - 5 categories' {
        
        It 'Should support custom very low threshold' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh -VeryLowThreshold 2.0
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.VeryLow | Should -Be 0   # 2.5 is now in Low category
            $day1.Low | Should -Be 2       # 2.5, 3.5
        }
        
        It 'Should support custom very high threshold' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh -VeryHighThreshold 16.0
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.VeryHigh | Should -Be 0  # 15.0 is now in High category
            $day1.High | Should -Be 2      # 12.0, 15.0
        }
        
        It 'Should support all custom thresholds' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh `
                -VeryLowThreshold 2.0 -LowThreshold 3.0 -HighThreshold 12.0 -VeryHighThreshold 16.0
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.VeryLow | Should -Be 0    # none below 2.0
            $day1.Low | Should -Be 1        # 2.5
            $day1.InRange | Should -Be 3    # 3.5, 7.0, 12.0 (12.0 is <= HighThreshold)
            $day1.High | Should -Be 1       # 15.0
            $day1.VeryHigh | Should -Be 0   # none above 16.0
        }
    }
    
    Context 'Date filtering with Days parameter' {
        
        It 'Should filter to last N days' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh -Days 2
            
            $result | Should -HaveCount 2
            $result.Date | Should -Contain '2025-10-27'
            $result.Date | Should -Contain '2025-10-28'
        }
        
        It 'Should filter to last 1 day' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh -Days 1
            
            $result | Should -HaveCount 1
            $result[0].Date | Should -Be '2025-10-28'
        }
    }
    
    Context 'Date filtering with StartDate and EndDate' {
        
        It 'Should filter by start date' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh -StartDate ([datetime]'2025-10-27')
            
            $result | Should -HaveCount 2
            $result.Date | Should -Contain '2025-10-27'
            $result.Date | Should -Contain '2025-10-28'
        }
        
        It 'Should filter by end date' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh -EndDate ([datetime]'2025-10-27')
            
            $result | Should -HaveCount 2
            $result.Date | Should -Contain '2025-10-26'
            $result.Date | Should -Contain '2025-10-27'
        }
        
        It 'Should filter by date range' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh `
                -StartDate ([datetime]'2025-10-26') -EndDate ([datetime]'2025-10-27')
            
            $result | Should -HaveCount 2
            $result.Date | Should -Contain '2025-10-26'
            $result.Date | Should -Contain '2025-10-27'
        }
        
        It 'Should filter to exact date' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh `
                -StartDate ([datetime]'2025-10-27') -EndDate ([datetime]'2025-10-27')
            
            $result | Should -HaveCount 1
            $result[0].Date | Should -Be '2025-10-27'
        }
    }
    
    Context 'Custom glucose column' {
        
        It 'Should support custom glucose column name' {
            $customData = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; GlucoseValue = 2.5 }
                [PSCustomObject]@{ Timestamp = '2025-10-26 06:00'; GlucoseValue = 15.0 }
            )
            
            $result = Get-GlookoCGMStatsExtended -InputObject $customData -UseVeryLowHigh -GlucoseColumn 'GlucoseValue'
            
            $result | Should -Not -BeNullOrEmpty
            $result[0].VeryLow | Should -Be 1
            $result[0].VeryHigh | Should -Be 1
        }
        
        It 'Should error when glucose column not found' {
            $invalidData = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; InvalidColumn = 5.5 }
            )
            
            $result = Get-GlookoCGMStatsExtended -InputObject $invalidData -ErrorAction SilentlyContinue
            
            $result | Should -BeNullOrEmpty
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $result = $Script:TestCGMData | Get-GlookoCGMStatsExtended -UseVeryLowHigh
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 3
        }
        
        It 'Should work with Import-GlookoCSV output' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'cgm-sample.csv'
            $result = Import-GlookoCSV -Path $testFile | ForEach-Object { $_.Data } | Get-GlookoCGMStatsExtended -UseVeryLowHigh
            
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Edge cases' {
        
        It 'Should handle empty input array' {
            $warnings = @()
            $result = Get-GlookoCGMStatsExtended -InputObject @() -WarningVariable warnings
            
            $result | Should -BeNullOrEmpty
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "No CGM data provided"
        }
        
        It 'Should handle single reading' {
            $singleReading = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; 'CGM Glucose Value (mmol/l)' = 7.0 }
            )
            
            $result = Get-GlookoCGMStatsExtended -InputObject $singleReading -UseVeryLowHigh
            
            $result | Should -Not -BeNullOrEmpty
            $result[0].TotalReadings | Should -Be 1
            $result[0].InRangePercent | Should -Be 100.0
        }
        
        It 'Should handle boundary values correctly' {
            $boundaryData = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; 'CGM Glucose Value (mmol/l)' = 2.9 }  # Very low
                [PSCustomObject]@{ Timestamp = '2025-10-26 01:00'; 'CGM Glucose Value (mmol/l)' = 3.0 }  # Low (inclusive)
                [PSCustomObject]@{ Timestamp = '2025-10-26 02:00'; 'CGM Glucose Value (mmol/l)' = 3.9 }  # Low
                [PSCustomObject]@{ Timestamp = '2025-10-26 03:00'; 'CGM Glucose Value (mmol/l)' = 4.0 }  # In range (inclusive)
                [PSCustomObject]@{ Timestamp = '2025-10-26 04:00'; 'CGM Glucose Value (mmol/l)' = 10.0 } # In range (inclusive)
                [PSCustomObject]@{ Timestamp = '2025-10-26 05:00'; 'CGM Glucose Value (mmol/l)' = 10.1 } # High
                [PSCustomObject]@{ Timestamp = '2025-10-26 06:00'; 'CGM Glucose Value (mmol/l)' = 13.9 } # High
                [PSCustomObject]@{ Timestamp = '2025-10-26 07:00'; 'CGM Glucose Value (mmol/l)' = 14.0 } # Very high (inclusive)
            )
            
            $result = Get-GlookoCGMStatsExtended -InputObject $boundaryData -UseVeryLowHigh
            
            $result[0].VeryLow | Should -Be 1
            $result[0].Low | Should -Be 2
            $result[0].InRange | Should -Be 2
            $result[0].High | Should -Be 2
            $result[0].VeryHigh | Should -Be 1
        }
        
        It 'Should handle no data after date filtering' {
            $warnings = @()
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh `
                -StartDate ([datetime]'2025-11-01') -WarningVariable warnings
            
            $result | Should -BeNullOrEmpty
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "No data remaining after date filtering"
        }
    }
    
    Context 'Data grouping by date' {
        
        It 'Should group readings by date correctly' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh
            
            $dates = $result | Select-Object -ExpandProperty Date
            $dates | Should -Contain '2025-10-26'
            $dates | Should -Contain '2025-10-27'
            $dates | Should -Contain '2025-10-28'
        }
        
        It 'Should count readings per date correctly' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day2 = $result | Where-Object { $_.Date -eq '2025-10-27' }
            $day3 = $result | Where-Object { $_.Date -eq '2025-10-28' }
            
            $day1.TotalReadings | Should -Be 5
            $day2.TotalReadings | Should -Be 2
            $day3.TotalReadings | Should -Be 1
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            $result = Get-GlookoCGMStatsExtended -InputObject $Script:TestCGMData -UseVeryLowHigh -Verbose
            
            # Verify the function still works correctly with verbose output
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Percentage rounding' {
        
        It 'Should round percentages to one decimal place' {
            $testData = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; 'CGM Glucose Value (mmol/l)' = 7.0 }
                [PSCustomObject]@{ Timestamp = '2025-10-26 01:00'; 'CGM Glucose Value (mmol/l)' = 7.0 }
                [PSCustomObject]@{ Timestamp = '2025-10-26 02:00'; 'CGM Glucose Value (mmol/l)' = 15.0 }
            )
            
            $result = Get-GlookoCGMStatsExtended -InputObject $testData -UseVeryLowHigh
            
            # 2 in range out of 3 = 66.666... should round to 66.7
            $result[0].InRangePercent | Should -Be 66.7
            $result[0].VeryHighPercent | Should -Be 33.3
        }
    }
}
