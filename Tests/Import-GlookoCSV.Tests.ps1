BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path (Join-Path $PSScriptRoot '..') -ChildPath 'Glooko.psd1'
    Import-Module $ModulePath -Force
    
    # Import test helpers
    . (Join-Path $PSScriptRoot -ChildPath 'TestHelpers.ps1')
    
    # Import Private functions for direct testing
    . (Join-Path (Join-Path $PSScriptRoot '..') -ChildPath 'Private' | Join-Path -ChildPath 'Expand-GlookoMetadata.ps1')
    
    # Fixtures path for static test data
    $FixturesPath = Join-Path $PSScriptRoot -ChildPath 'Fixtures'
    if (-not (Test-Path $FixturesPath)) {
        New-Item -Path $FixturesPath -ItemType Directory -Force | Out-Null
    }
    
    # Static test files (fixtures)
    $Script:TestData01 = Join-Path $FixturesPath 'test-data01.csv'
    $Script:SampleData = Join-Path $FixturesPath 'sample-data.csv'
}

AfterAll {
    # Remove the module (TestDrive is automatically cleaned up by Pester)
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Import-GlookoCSV' {
    
    BeforeEach {
        # Create test files in TestDrive for each test
        $Script:TestFiles = New-TestCSVFiles
    }
    
    Context 'Basic functionality' {
        
        It 'Should import CSV data and skip the first row' {
            $result = Import-GlookoCSV -Path $Script:TestFiles.TestCSV1
            
            $result.Metadata.OriginalFirstLine | Should -Be 'Metadata: Export from system on 2025-10-18'
            $result.Metadata.FullName | Should -Be 'test1.csv'
            $result.Metadata.Dataset | Should -BeNullOrEmpty  # Doesn't match pattern
            $result.Data | Should -HaveCount 3
            $result.Data[0].Name | Should -Be 'John'
            $result.Data[0].Age | Should -Be '25'
            $result.Data[0].City | Should -Be 'New York'
            $result.Data[2].Name | Should -Be 'Bob'
        }
        
        It 'Should use second row as headers when first row is skipped' {
            $result = Import-GlookoCSV -Path $Script:TestFiles.TestCSV2
            
            $result.Metadata.OriginalFirstLine | Should -Be 'OldName,OldAge,OldCity'
            $result.Metadata.FullName | Should -Be 'test2.csv'
            $result.Data | Should -HaveCount 2
            $result.Data[0] | Should -BeOfType [PSCustomObject]
            $result.Data[0].PSObject.Properties.Name | Should -Contain 'Name'
            $result.Data[0].PSObject.Properties.Name | Should -Contain 'Age'
            $result.Data[0].PSObject.Properties.Name | Should -Contain 'City'
        }
        
        It 'Should work with single data row' {
            $result = Import-GlookoCSV -Path $Script:TestFiles.TestCSV3
            
            $result.Metadata.OriginalFirstLine | Should -Be 'Skip this line'
            $result.Metadata.FullName | Should -Be 'test3.csv'
            $result.Data | Should -HaveCount 1
            $result.Data[0].Name | Should -Be 'David'
            $result.Data[0].Age | Should -Be '40'
            $result.Data[0].City | Should -Be 'Miami'
        }
        
        It 'Should import alarm/event data from test-data01.csv' {
            $result = Import-GlookoCSV -Path $Script:TestData01
            
            # Test extended metadata
            $result.Metadata.FullName | Should -Be 'test-data01.csv'
            $result.Metadata.Dataset | Should -BeNullOrEmpty  # Doesn't match pattern
            $result.Metadata.Order | Should -BeNullOrEmpty
            $result.Metadata.Name | Should -Be 'Igor Irić'
            $result.Metadata.DateRange | Should -Be '2025-05-31 - 2025-08-17'
            $result.Metadata.StartDate | Should -Be '2025-05-31'
            $result.Metadata.EndDate | Should -Be '2025-08-17'
            $result.Metadata.OriginalFirstLine | Should -Be 'Name:Igor Irić, Date Range:2025-05-31 - 2025-08-17'
            
            # Test data
            $result.Data | Should -HaveCount 2
            $result.Data[0] | Should -BeOfType [PSCustomObject]
            $result.Data[0].PSObject.Properties.Name | Should -Contain 'Timestamp'
            $result.Data[0].PSObject.Properties.Name | Should -Contain 'Alarm/Event'
            $result.Data[0].PSObject.Properties.Name | Should -Contain 'Serial Number'
            $result.Data[0].Timestamp | Should -Be '8/17/2025 0:15'
            $result.Data[0].'Alarm/Event' | Should -Be 'tandem_control_low'
            $result.Data[0].'Serial Number' | Should -Be '1266847'
            $result.Data[1].Timestamp | Should -Be '8/16/2025 22:35'
            $result.Data[1].'Alarm/Event' | Should -Be 'tandem_control_low'
            $result.Data[1].'Serial Number' | Should -Be '1266847'
        }
        
        It 'Should parse filename with dataset pattern (alarms_data_1.csv)' {
            $result = Import-GlookoCSV -Path $Script:TestFiles.AlarmsDataFile
            
            # Test filename parsing
            $result.Metadata.FullName | Should -Be 'alarms_data_1.csv'
            $result.Metadata.Dataset | Should -Be 'alarms'
            $result.Metadata.Order | Should -Be 1
            
            # Test first line parsing
            $result.Metadata.Name | Should -Be 'Igor Irić'
            $result.Metadata.DateRange | Should -Be '2025-05-31 - 2025-08-17'
            $result.Metadata.StartDate | Should -Be '2025-05-31'
            $result.Metadata.EndDate | Should -Be '2025-08-17'
            
            # Test data
            $result.Data | Should -HaveCount 2
        }
    }
    

    
    Context 'Error handling' {
        
        It 'Should throw error for non-existent file' {
            { Import-GlookoCSV -Path $Script:TestFiles.NonExistentFile } | Should -Throw "*File not found*"
        }
        
        It 'Should handle empty file gracefully' {
            # Create empty CSV in TestDrive
            $testCSVEmpty = 'TestDrive:\test_empty.csv'
            '' | Out-File -FilePath $testCSVEmpty            
            $result = Import-GlookoCSV -Path $testCSVEmpty -WarningAction SilentlyContinue
            
            # Test extended metadata structure for empty file
            $result.Metadata.FullName | Should -Be 'test_empty.csv'
            $result.Metadata.Dataset | Should -BeNullOrEmpty
            $result.Metadata.Order | Should -BeNullOrEmpty
            $result.Metadata.Name | Should -BeNullOrEmpty
            $result.Metadata.DateRange | Should -BeNullOrEmpty
            $result.Metadata.StartDate | Should -BeNullOrEmpty
            $result.Metadata.EndDate | Should -BeNullOrEmpty
            $result.Metadata.OriginalFirstLine | Should -Be ''
            $result.Data | Should -BeNullOrEmpty
        }
        
        It 'Should warn when file has fewer than 2 lines' {
            $warnings = @()
            $result = Import-GlookoCSV -Path $Script:TestFiles.SingleLineFile -WarningVariable warnings
            
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "fewer than 2 lines"
            $result.Metadata.OriginalFirstLine | Should -Be 'Only one line'
            $result.Metadata.FullName | Should -Be 'single_line.csv'
            $result.Data | Should -BeNullOrEmpty
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $result = $Script:TestFiles.TestCSV1 | Import-GlookoCSV
            
            $result.Data | Should -HaveCount 3
            $result.Data[0].Name | Should -Be 'John'
        }
        
        It 'Should work with Get-ChildItem pipeline' {
            $testFiles = @($Script:TestFiles.TestCSV1, $Script:TestFiles.TestCSV3)
            $results = $testFiles | Import-GlookoCSV
            
            # Should have results from both files (2 result objects)
            $results | Should -HaveCount 2
            $results[0].Data | Should -HaveCount 3  # 3 from test1
            $results[1].Data | Should -HaveCount 1  # 1 from test3
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            # Test that the function runs with -Verbose without errors
            # and that it produces the expected result
            $result = Import-GlookoCSV -Path $Script:TestFiles.TestCSV1 -Verbose
            
            # Verify the function still works correctly with verbose output
            $result.Data | Should -HaveCount 3
            $result.Data[0].Name | Should -Be 'John'
        }
    }
    
    Context 'Data integrity' {
        
        It 'Should preserve data types as strings (CSV behavior)' {
            $result = Import-GlookoCSV -Path $Script:TestFiles.TestCSV1
            
            $result.Data[0].Age | Should -BeOfType [string]
            $result.Data[0].Age | Should -Be '25'
        }
        
        It 'Should handle special characters in data' {
            $result = Import-GlookoCSV -Path $Script:TestFiles.SpecialCharFile
            
            $result.Data | Should -HaveCount 2
            $result.Data[0].Description | Should -Be 'Data with, comma'
            $result.Data[1].Description | Should -Be 'Data with "quotes"'
        }
    }
}
