BeforeAll {
    # Directly dot-source the private function for testing
    $PrivateFunctionPath = Join-Path $PSScriptRoot '..' '..' 'Private' 'Get-Correlation.ps1'
    . $PrivateFunctionPath
}

Describe 'Get-Correlation' {
    
    Context 'Basic correlation calculations' {
        
        It 'Should calculate perfect positive correlation' {
            $x = @(1, 2, 3, 4, 5)
            $y = @(2, 4, 6, 8, 10)
            
            $result = Get-Correlation -X $x -Y $y
            
            $result | Should -Be 1.000
        }
        
        It 'Should calculate perfect negative correlation' {
            $x = @(1, 2, 3, 4, 5)
            $y = @(10, 8, 6, 4, 2)
            
            $result = Get-Correlation -X $x -Y $y
            
            $result | Should -Be -1
        }
        
        It 'Should calculate zero correlation for unrelated data' {
            $x = @(1, 2, 1, 2, 1)
            $y = @(5, 5, 5, 5, 5)
            
            $result = Get-Correlation -X $x -Y $y
            
            $result | Should -Be 0
        }
        
        It 'Should calculate partial positive correlation' {
            $x = @(1, 2, 3, 4, 5)
            $y = @(2, 3, 5, 4, 6)
            
            $result = Get-Correlation -X $x -Y $y
            
            # Should be positive but not perfect
            $result | Should -BeGreaterThan 0.5
            $result | Should -BeLessThan 1.0
        }
    }
    
    Context 'Edge cases and error handling' {
        
        It 'Should return 0 for arrays with fewer than 2 elements' {
            $x = @(1)
            $y = @(2)
            
            $result = Get-Correlation -X $x -Y $y
            
            $result | Should -Be 0
        }
        
        It 'Should return 0 for empty arrays' {
            # Skip this test as the function requires non-empty arrays by design
            Set-ItResult -Skipped -Because "Function requires non-empty arrays by parameter validation"
        }
        
        It 'Should handle arrays with same values (zero variance)' {
            $x = @(5, 5, 5, 5)
            $y = @(1, 2, 3, 4)
            
            $result = Get-Correlation -X $x -Y $y
            
            $result | Should -Be 0
        }
        
        It 'Should warn and return 0 for arrays of different lengths' {
            $x = @(1, 2, 3)
            $y = @(1, 2)
            
            $warnings = @()
            $result = Get-Correlation -X $x -Y $y -WarningVariable warnings -WarningAction SilentlyContinue
            
            $result | Should -Be 0
            $warnings | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Real-world data scenarios' {
        
        It 'Should calculate correlation for glucose and insulin data' {
            # Simulate glucose in-range percentages
            $glucoseInRange = @(75.0, 80.0, 70.0, 85.0, 78.0, 82.0, 76.0)
            # Simulate insulin totals
            $insulinTotal = @(45.0, 48.0, 42.0, 50.0, 46.0, 49.0, 44.0)
            
            $result = Get-Correlation -X $glucoseInRange -Y $insulinTotal
            
            # Should show positive correlation
            $result | Should -BeGreaterThan 0.5
        }
        
        It 'Should handle decimal values correctly' {
            $x = @(4.5, 6.2, 8.1, 9.3, 5.7)
            $y = @(12.3, 15.6, 18.9, 21.2, 14.1)
            
            $result = Get-Correlation -X $x -Y $y
            
            # Should be a valid correlation value
            $result | Should -BeGreaterOrEqual -1
            $result | Should -BeLessOrEqual 1
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output' {
            $x = @(1, 2, 3, 4, 5)
            $y = @(2, 4, 6, 8, 10)
            
            $verboseOutput = Get-Correlation -X $x -Y $y -Verbose 4>&1
            
            $verboseOutput | Should -Not -BeNullOrEmpty
            $verboseStrings = $verboseOutput | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
            $verboseStrings | Should -Not -BeNullOrEmpty
        }
    }
}
