BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
    
    # Create test data directory
    $TestDataPath = Join-Path $PSScriptRoot 'TestData'
    if (-not (Test-Path $TestDataPath)) {
        New-Item -Path $TestDataPath -ItemType Directory -Force | Out-Null
    }
    
    # Create test CSV files
    $Script:TestCSV1 = Join-Path $TestDataPath 'test1.csv'
    $Script:TestCSV2 = Join-Path $TestDataPath 'test2.csv'
    $Script:TestCSV3 = Join-Path $TestDataPath 'test3.csv'
    $Script:TestCSVEmpty = Join-Path $TestDataPath 'test_empty.csv'
    
    # Test CSV with metadata in first row
    @"
Metadata: Export from system on 2025-10-18
Name,Age,City
John,25,New York
Jane,30,Los Angeles
Bob,35,Chicago
"@ | Out-File -FilePath $Script:TestCSV1 -Encoding UTF8
    
    # Test CSV with different headers in first row
    @"
OldName,OldAge,OldCity
Name,Age,City
Alice,28,Boston
Charlie,32,Seattle
"@ | Out-File -FilePath $Script:TestCSV2 -Encoding UTF8
    
    # Test CSV with only one data row
    @"
Skip this line
Name,Age,City
David,40,Miami
"@ | Out-File -FilePath $Script:TestCSV3 -Encoding UTF8
    

    
    # Empty CSV file
    @"
"@ | Out-File -FilePath $Script:TestCSVEmpty -Encoding UTF8
}

AfterAll {
    # Clean up test data
    $TestDataPath = Join-Path $PSScriptRoot 'TestData'
    if (Test-Path $TestDataPath) {
        Remove-Item -Path $TestDataPath -Recurse -Force
    }
    
    # Remove the module
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Import-GlookoCSV' {
    
    Context 'Basic functionality' {
        
        It 'Should import CSV data and skip the first row' {
            $result = Import-GlookoCSV -Path $Script:TestCSV1
            
            $result | Should -HaveCount 3
            $result[0].Name | Should -Be 'John'
            $result[0].Age | Should -Be '25'
            $result[0].City | Should -Be 'New York'
            $result[2].Name | Should -Be 'Bob'
        }
        
        It 'Should use second row as headers when first row is skipped' {
            $result = Import-GlookoCSV -Path $Script:TestCSV2
            
            $result | Should -HaveCount 2
            $result[0] | Should -BeOfType [PSCustomObject]
            $result[0].PSObject.Properties.Name | Should -Contain 'Name'
            $result[0].PSObject.Properties.Name | Should -Contain 'Age'
            $result[0].PSObject.Properties.Name | Should -Contain 'City'
        }
        
        It 'Should work with single data row' {
            $result = Import-GlookoCSV -Path $Script:TestCSV3
            
            $result | Should -HaveCount 1
            $result[0].Name | Should -Be 'David'
            $result[0].Age | Should -Be '40'
            $result[0].City | Should -Be 'Miami'
        }
    }
    

    
    Context 'Error handling' {
        
        It 'Should throw error for non-existent file' {
            $nonExistentFile = Join-Path $PSScriptRoot 'nonexistent.csv'
            { Import-GlookoCSV -Path $nonExistentFile } | Should -Throw "*File not found*"
        }
        
        It 'Should handle empty file gracefully' {
            $result = Import-GlookoCSV -Path $Script:TestCSVEmpty -WarningAction SilentlyContinue
            
            $result | Should -BeNullOrEmpty
        }
        
        It 'Should warn when file has fewer than 2 lines' {
            $singleLineFile = Join-Path $PSScriptRoot 'TestData' 'single_line.csv'
            "Only one line" | Out-File -FilePath $singleLineFile -Encoding UTF8
            
            $warnings = @()
            $result = Import-GlookoCSV -Path $singleLineFile -WarningVariable warnings
            
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "fewer than 2 lines"
            $result | Should -BeNullOrEmpty
            
            Remove-Item $singleLineFile -Force
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $result = $Script:TestCSV1 | Import-GlookoCSV
            
            $result | Should -HaveCount 3
            $result[0].Name | Should -Be 'John'
        }
        
        It 'Should work with Get-ChildItem pipeline' {
            $testFiles = @($Script:TestCSV1, $Script:TestCSV3)
            $results = $testFiles | Import-GlookoCSV
            
            # Should have results from both files
            $results | Should -HaveCount 4  # 3 from test1 + 1 from test3
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            # Capture all output streams including verbose
            $allOutput = Import-GlookoCSV -Path $Script:TestCSV1 -Verbose *>&1
            
            # Filter for verbose records
            $verboseMessages = $allOutput | Where-Object { $_ -is [System.Management.Automation.VerboseRecord] }
            
            $verboseMessages | Should -HaveCount -GreaterThan 0
            $verboseMessages[0].Message | Should -Match "Starting Import-GlookoCSV"
        }
    }
    
    Context 'Data integrity' {
        
        It 'Should preserve data types as strings (CSV behavior)' {
            $result = Import-GlookoCSV -Path $Script:TestCSV1
            
            $result[0].Age | Should -BeOfType [string]
            $result[0].Age | Should -Be '25'
        }
        
        It 'Should handle special characters in data' {
            $specialCharFile = Join-Path $PSScriptRoot 'TestData' 'special_chars.csv'
            @"
Skip this metadata line
Name,Description,Value
Test,"Data with, comma",123
Quote,"Data with ""quotes""",456
"@ | Out-File -FilePath $specialCharFile -Encoding UTF8
            
            $result = Import-GlookoCSV -Path $specialCharFile
            
            $result | Should -HaveCount 2
            $result[0].Description | Should -Be 'Data with, comma'
            $result[1].Description | Should -Be 'Data with "quotes"'
            
            Remove-Item $specialCharFile -Force
        }
    }
}