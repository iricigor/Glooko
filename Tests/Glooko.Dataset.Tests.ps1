BeforeAll {
    # Import the module
    $ModulePath = Join-Path $PSScriptRoot '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
}

Describe 'Glooko.Dataset Type and Formatting' {
    
    Context 'Type Assignment' {
        
        It 'Should assign Glooko.Dataset type to Import-GlookoCSV result' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            $result.PSObject.TypeNames | Should -Contain 'Glooko.Dataset'
        }
        
        It 'Should assign Glooko.Dataset type to Import-GlookoCSV result with fewer than 2 lines' {
            $testFile = Join-Path ([System.IO.Path]::GetTempPath()) "test-$(New-Guid).csv"
            try {
                "# Header only" | Out-File -FilePath $testFile -Encoding UTF8
                
                $result = Import-GlookoCSV -Path $testFile -WarningAction SilentlyContinue
                
                $result.PSObject.TypeNames | Should -Contain 'Glooko.Dataset'
            } finally {
                if (Test-Path $testFile) {
                    Remove-Item $testFile -Force
                }
            }
        }
        
        It 'Should assign Glooko.Dataset type to Import-GlookoFolder results' {
            $testFolder = Join-Path $PSScriptRoot 'Fixtures'
            $results = Import-GlookoFolder -Path $testFolder
            
            $results | Should -Not -BeNullOrEmpty
            foreach ($result in $results) {
                $result.PSObject.TypeNames | Should -Contain 'Glooko.Dataset'
            }
        }
        
        It 'Should assign Glooko.Dataset type to merged datasets' {
            # Create test files that will be merged
            $tempFolder = Join-Path ([System.IO.Path]::GetTempPath()) "test-$(New-Guid)"
            New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null
            
            try {
                $file1 = Join-Path $tempFolder 'test_data_1.csv'
                $file2 = Join-Path $tempFolder 'test_data_2.csv'
                
                @"
Name:Test User, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value
2025-01-01 10:00,100
"@ | Out-File -FilePath $file1 -Encoding UTF8
                
                @"
Name:Test User, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value
2025-01-02 10:00,200
"@ | Out-File -FilePath $file2 -Encoding UTF8
                
                $results = Import-GlookoFolder -Path $tempFolder
                
                $results | Should -Not -BeNullOrEmpty
                $results.Count | Should -Be 1
                $results[0].PSObject.TypeNames | Should -Contain 'Glooko.Dataset'
            } finally {
                if (Test-Path $tempFolder) {
                    Remove-Item $tempFolder -Recurse -Force
                }
            }
        }
    }
    
    Context 'Script Properties' {
        
        It 'Should have RecordCount script property' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            $result.RecordCount | Should -Be 2
        }
        
        It 'Should have RecordCount of 0 for empty data' {
            $testFile = Join-Path ([System.IO.Path]::GetTempPath()) "test-$(New-Guid).csv"
            try {
                "# Header only" | Out-File -FilePath $testFile -Encoding UTF8
                
                $result = Import-GlookoCSV -Path $testFile -WarningAction SilentlyContinue
                
                $result.RecordCount | Should -Be 0
            } finally {
                if (Test-Path $testFile) {
                    Remove-Item $testFile -Force
                }
            }
        }
        
        It 'Should have DatasetName script property' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            $result.DatasetName | Should -Be 'test-data01.csv'
        }
        
        It 'Should use Dataset field if available for DatasetName' {
            $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) "mydata_data_1.csv"
            try {
                @"
Name:Test User, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value
2025-01-01 10:00,100
"@ | Out-File -FilePath $tempFile -Encoding UTF8
                
                $result = Import-GlookoCSV -Path $tempFile
                
                $result.DatasetName | Should -Be 'mydata'
            } finally {
                if (Test-Path $tempFile) {
                    Remove-Item $tempFile -Force
                }
            }
        }
    }
    
    Context 'Custom Formatting' {
        
        It 'Should format output with custom view' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            # Get the formatted output
            $formatted = $result | Out-String
            
            # Check that key labels appear in the formatted output
            $formatted | Should -Match 'Dataset\s*:'
            $formatted | Should -Match 'Records\s*:'
            $formatted | Should -Match 'Name\s*:'
            $formatted | Should -Match 'DateRange\s*:'
            $formatted | Should -Match 'FileName\s*:'
        }
        
        It 'Should display record count in formatted output' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            $formatted = $result | Out-String
            
            $formatted | Should -Match 'Records\s*:\s*2'
        }
        
        It 'Should display data summary in formatted output' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            $formatted = $result | Out-String
            
            $formatted | Should -Match 'Data\s*:\s*\[2 records\]'
        }
        
        It 'Should display metadata fields when available' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            $formatted = $result | Out-String
            
            # Should show Name from metadata
            $formatted | Should -Match 'Name\s*:\s*Igor Irić'
            # Should show DateRange from metadata
            $formatted | Should -Match 'DateRange\s*:\s*2025-05-31 - 2025-08-17'
        }
    }
    
    Context 'Backward Compatibility' {
        
        It 'Should still have Metadata property accessible' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            $result.Metadata | Should -Not -BeNullOrEmpty
            $result.Metadata.FullName | Should -Be 'test-data01.csv'
        }
        
        It 'Should still have Data property accessible' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            $result.Data | Should -Not -BeNullOrEmpty
            $result.Data.Count | Should -Be 2
        }
        
        It 'Should maintain compatibility with existing code that accesses properties' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile
            
            # Test that properties can be accessed as before
            $result.Metadata.Name | Should -Be 'Igor Irić'
            $result.Data[0].Timestamp | Should -Not -BeNullOrEmpty
        }
    }
}
