BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
}

AfterAll {
    # Remove the module
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Get-GlookoCGMStats' {
    
    BeforeAll {
        # Create test CGM data
        $Script:TestCGMData = @(
            [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; 'CGM Glucose Value (mmol/l)' = 5.5 }
            [PSCustomObject]@{ Timestamp = '2025-10-26 06:00'; 'CGM Glucose Value (mmol/l)' = 6.2 }
            [PSCustomObject]@{ Timestamp = '2025-10-26 12:00'; 'CGM Glucose Value (mmol/l)' = 9.6 }
            [PSCustomObject]@{ Timestamp = '2025-10-26 18:00'; 'CGM Glucose Value (mmol/l)' = 3.1 }
            [PSCustomObject]@{ Timestamp = '2025-10-26 22:00'; 'CGM Glucose Value (mmol/l)' = 11.0 }
            [PSCustomObject]@{ Timestamp = '2025-10-27 00:00'; 'CGM Glucose Value (mmol/l)' = 4.5 }
            [PSCustomObject]@{ Timestamp = '2025-10-27 12:00'; 'CGM Glucose Value (mmol/l)' = 8.5 }
            [PSCustomObject]@{ Timestamp = '2025-10-27 18:00'; 'CGM Glucose Value (mmol/l)' = 14.5 }
        )
    }
    
    Context 'Basic functionality' {
        
        It 'Should analyze CGM data and return statistics' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2  # Two dates: 2025-10-26 and 2025-10-27
        }
        
        It 'Should calculate correct counts for each category' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.TotalReadings | Should -Be 5
            $day1.BelowRange | Should -Be 1  # 3.1
            $day1.InRange | Should -Be 3     # 5.5, 6.2, 9.6
            $day1.AboveRange | Should -Be 1  # 11.0
        }
        
        It 'Should calculate correct percentages' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.BelowRangePercent | Should -Be 20.0
            $day1.InRangePercent | Should -Be 60.0
            $day1.AboveRangePercent | Should -Be 20.0
        }
        
        It 'Should include target range in output' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData
            
            $result[0].TargetRange | Should -Be '4-10 mmol/L'
        }
    }
    
    Context 'Custom thresholds' {
        
        It 'Should support custom low threshold' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData -LowThreshold 5.0
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            # Day 1 has only 3.1 below 5.0
            $day1.BelowRange | Should -Be 1
        }
        
        It 'Should support custom high threshold' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData -HighThreshold 8.0
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.AboveRange | Should -Be 2  # 9.6, 11.0
        }
        
        It 'Should support both custom thresholds' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData -LowThreshold 5.0 -HighThreshold 9.0
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day1.BelowRange | Should -Be 1   # 3.1
            $day1.InRange | Should -Be 2      # 5.5, 6.2
            $day1.AboveRange | Should -Be 2   # 9.6, 11.0
        }
    }
    
    Context 'Custom glucose column' {
        
        It 'Should support custom glucose column name' {
            $customData = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; GlucoseValue = 5.5 }
                [PSCustomObject]@{ Timestamp = '2025-10-26 06:00'; GlucoseValue = 11.0 }
            )
            
            $result = Get-GlookoCGMStats -InputObject $customData -GlucoseColumn 'GlucoseValue'
            
            $result | Should -Not -BeNullOrEmpty
            $result[0].InRange | Should -Be 1
            $result[0].AboveRange | Should -Be 1
        }
        
        It 'Should error when glucose column not found' {
            $invalidData = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; InvalidColumn = 5.5 }
            )
            
            $result = Get-GlookoCGMStats -InputObject $invalidData -ErrorAction SilentlyContinue
            
            $result | Should -BeNullOrEmpty
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $result = $Script:TestCGMData | Get-GlookoCGMStats
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
        }
        
        It 'Should work with Import-GlookoCSV output' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'cgm-sample.csv'
            $result = Import-GlookoCSV -Path $testFile | ForEach-Object { $_.Data } | Get-GlookoCGMStats
            
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Edge cases' {
        
        It 'Should handle empty input array' {
            $warnings = @()
            $result = Get-GlookoCGMStats -InputObject @() -WarningVariable warnings
            
            $result | Should -BeNullOrEmpty
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "No CGM data provided"
        }
        
        It 'Should handle single reading' {
            $singleReading = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; 'CGM Glucose Value (mmol/l)' = 5.5 }
            )
            
            $result = Get-GlookoCGMStats -InputObject $singleReading
            
            $result | Should -Not -BeNullOrEmpty
            $result[0].TotalReadings | Should -Be 1
            $result[0].InRangePercent | Should -Be 100.0
        }
        
        It 'Should handle all readings below range' {
            $allBelow = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; 'CGM Glucose Value (mmol/l)' = 2.5 }
                [PSCustomObject]@{ Timestamp = '2025-10-26 06:00'; 'CGM Glucose Value (mmol/l)' = 3.0 }
            )
            
            $result = Get-GlookoCGMStats -InputObject $allBelow
            
            $result[0].BelowRange | Should -Be 2
            $result[0].BelowRangePercent | Should -Be 100.0
        }
        
        It 'Should handle all readings above range' {
            $allAbove = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; 'CGM Glucose Value (mmol/l)' = 15.0 }
                [PSCustomObject]@{ Timestamp = '2025-10-26 06:00'; 'CGM Glucose Value (mmol/l)' = 12.0 }
            )
            
            $result = Get-GlookoCGMStats -InputObject $allAbove
            
            $result[0].AboveRange | Should -Be 2
            $result[0].AboveRangePercent | Should -Be 100.0
        }
        
        It 'Should handle boundary values correctly' {
            $boundaryData = @(
                [PSCustomObject]@{ Timestamp = '2025-10-26 00:00'; 'CGM Glucose Value (mmol/l)' = 3.9 }  # Below
                [PSCustomObject]@{ Timestamp = '2025-10-26 01:00'; 'CGM Glucose Value (mmol/l)' = 4.0 }  # In range (inclusive)
                [PSCustomObject]@{ Timestamp = '2025-10-26 02:00'; 'CGM Glucose Value (mmol/l)' = 10.0 } # In range (inclusive)
                [PSCustomObject]@{ Timestamp = '2025-10-26 03:00'; 'CGM Glucose Value (mmol/l)' = 10.1 } # Above
            )
            
            $result = Get-GlookoCGMStats -InputObject $boundaryData
            
            $result[0].BelowRange | Should -Be 1
            $result[0].InRange | Should -Be 2
            $result[0].AboveRange | Should -Be 1
        }
    }
    
    Context 'Data grouping by date' {
        
        It 'Should group readings by date correctly' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData
            
            $dates = $result | Select-Object -ExpandProperty Date
            $dates | Should -Contain '2025-10-26'
            $dates | Should -Contain '2025-10-27'
        }
        
        It 'Should count readings per date correctly' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData
            
            $day1 = $result | Where-Object { $_.Date -eq '2025-10-26' }
            $day2 = $result | Where-Object { $_.Date -eq '2025-10-27' }
            
            $day1.TotalReadings | Should -Be 5
            $day2.TotalReadings | Should -Be 3
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            $result = Get-GlookoCGMStats -InputObject $Script:TestCGMData -Verbose
            
            # Verify the function still works correctly with verbose output
            $result | Should -Not -BeNullOrEmpty
        }
    }
}
