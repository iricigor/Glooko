BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
    
    # Import test helpers
    . (Join-Path $PSScriptRoot 'Helpers' 'TestHelpers.ps1')
    
    # Import Private functions for direct testing
    . (Join-Path $PSScriptRoot '..' '..' 'Private' 'Expand-GlookoMetadata.ps1')
}

AfterAll {
    # Remove the module (TestDrive is automatically cleaned up by Pester)
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Import-GlookoFolder' {
    
    BeforeEach {
        # Create test folder structures in TestDrive for each test
        $Script:TestFolders = New-TestFolder
    }
    
    Context 'Basic functionality' {
        
        It 'Should import all CSV files from a folder' {
            $results = Import-GlookoFolder -Path $Script:TestFolders.TestFolder
            
            $results | Should -HaveCount 3
            $results | ForEach-Object {
                $_ | Should -BeOfType [PSCustomObject]
                $_.PSObject.Properties.Name | Should -Contain 'Metadata'
                $_.PSObject.Properties.Name | Should -Contain 'Data'
            }
        }
        
        It 'Should import files with correct data from each file' {
            $results = Import-GlookoFolder -Path $Script:TestFolders.TestFolder
            
            # Find file1.csv result
            $file1Result = $results | Where-Object { $_.Metadata.FullName -eq 'file1.csv' }
            $file1Result | Should -Not -BeNullOrEmpty
            $file1Result.Data | Should -HaveCount 2
            $file1Result.Data[0].Name | Should -Be 'John'
            $file1Result.Data[1].Name | Should -Be 'Jane'
            
            # Find file2.csv result
            $file2Result = $results | Where-Object { $_.Metadata.FullName -eq 'file2.csv' }
            $file2Result | Should -Not -BeNullOrEmpty
            $file2Result.Data | Should -HaveCount 1
            $file2Result.Data[0].Name | Should -Be 'Bob'
            
            # Find file3.csv result
            $file3Result = $results | Where-Object { $_.Metadata.FullName -eq 'file3.csv' }
            $file3Result | Should -Not -BeNullOrEmpty
            $file3Result.Data | Should -HaveCount 2
            $file3Result.Metadata.Name | Should -Be 'Igor Irić'
            $file3Result.Metadata.DateRange | Should -Be '2025-05-31 - 2025-08-17'
        }
        
        It 'Should work with empty folder' {
            $warnings = @()
            $results = Import-GlookoFolder -Path $Script:TestFolders.EmptyFolder -WarningVariable warnings
            
            $results | Should -BeNullOrEmpty
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "No CSV files found"
        }
        
        It 'Should work with folder containing only one CSV file' {
            $results = Import-GlookoFolder -Path $Script:TestFolders.SingleFileFolder
            
            $results | Should -HaveCount 1
            $results[0].Metadata.FullName | Should -Be 'single.csv'
            $results[0].Data | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Alice'
        }
        
        It 'Should ignore non-CSV files in the folder' {
            # Add a non-CSV file to the test folder
            $txtFile = Join-Path $Script:TestFolders.TestFolder 'readme.txt'
            'This is not a CSV file' | Out-File -FilePath $txtFile -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $Script:TestFolders.TestFolder
            
            # Should still only import the 3 CSV files
            $results | Should -HaveCount 3
        }
        
        It 'Should import CSV files recursively from subdirectories' {
            # Create a test folder with subdirectories
            $recursiveFolder = 'TestDrive:\recursive_folder'
            New-Item -Path $recursiveFolder -ItemType Directory -Force | Out-Null
            
            # Create CSV in root
            $rootFile = Join-Path $recursiveFolder 'root.csv'
            @"
Root metadata
Name,Value
RootData,100
"@ | Out-File -FilePath $rootFile -Encoding UTF8
            
            # Create subdirectory with CSV files
            $subdir1 = Join-Path $recursiveFolder 'subfolder1'
            New-Item -Path $subdir1 -ItemType Directory -Force | Out-Null
            $subFile1 = Join-Path $subdir1 'sub1.csv'
            @"
Sub1 metadata
Name,Value
Sub1Data,200
"@ | Out-File -FilePath $subFile1 -Encoding UTF8
            
            # Create nested subdirectory with CSV files
            $subdir2 = Join-Path $subdir1 'nested'
            New-Item -Path $subdir2 -ItemType Directory -Force | Out-Null
            $subFile2 = Join-Path $subdir2 'nested.csv'
            @"
Nested metadata
Name,Value
NestedData,300
"@ | Out-File -FilePath $subFile2 -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $recursiveFolder
            
            # Should import all 3 CSV files from root and subdirectories
            $results | Should -HaveCount 3
            
            # Verify each file was imported
            $rootResult = $results | Where-Object { $_.Metadata.FullName -eq 'root.csv' }
            $rootResult | Should -Not -BeNullOrEmpty
            $rootResult.Data[0].Name | Should -Be 'RootData'
            
            $sub1Result = $results | Where-Object { $_.Metadata.FullName -eq 'sub1.csv' }
            $sub1Result | Should -Not -BeNullOrEmpty
            $sub1Result.Data[0].Name | Should -Be 'Sub1Data'
            
            $nestedResult = $results | Where-Object { $_.Metadata.FullName -eq 'nested.csv' }
            $nestedResult | Should -Not -BeNullOrEmpty
            $nestedResult.Data[0].Name | Should -Be 'NestedData'
        }
    }
    
    Context 'Error handling' {
        
        It 'Should throw error for non-existent folder' {
            { Import-GlookoFolder -Path $Script:TestFolders.NonExistentFolder } | Should -Throw "*Folder not found*"
        }
        
        It 'Should throw error when path is a file instead of folder' {
            'test' | Out-File -FilePath $Script:TestFolders.TestFile -Encoding UTF8
            
            { Import-GlookoFolder -Path $Script:TestFolders.TestFile } | Should -Throw "*Folder not found*"
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $results = $Script:TestFolders.TestFolder | Import-GlookoFolder
            
            $results | Should -HaveCount 3
        }
        
        It 'Should work with Get-Item pipeline' {
            $folderItem = Get-Item -Path $Script:TestFolders.TestFolder
            $results = $folderItem.FullName | Import-GlookoFolder
            
            $results | Should -HaveCount 3
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            # Test that the function runs with -Verbose without errors
            # and that it produces the expected result
            $results = Import-GlookoFolder -Path $Script:TestFolders.TestFolder -Verbose
            
            # Verify the function still works correctly with verbose output
            $results | Should -HaveCount 3
        }
    }
    
    Context 'Data integrity' {
        
        It 'Should preserve all metadata from individual files' {
            $results = Import-GlookoFolder -Path $Script:TestFolders.TestFolder
            
            # Each result should have complete metadata structure
            $results | ForEach-Object {
                $_.Metadata | Should -Not -BeNullOrEmpty
                $_.Metadata.PSObject.Properties.Name | Should -Contain 'FullName'
                $_.Metadata.PSObject.Properties.Name | Should -Contain 'OriginalFirstLine'
            }
        }
        
        It 'Should handle files with special characters correctly' {
            $results = Import-GlookoFolder -Path $Script:TestFolders.SpecialFolder
            
            $results | Should -HaveCount 1
            $results[0].Data | Should -HaveCount 2
            $results[0].Data[0].Description | Should -Be 'Data with, comma'
            $results[0].Data[1].Description | Should -Be 'Data with "quotes"'
        }
    }
    
    Context 'Dataset consolidation' {
        
        It 'Should consolidate files with same Dataset and OriginalFirstLine' {
            # Create a test folder with split datasets
            $consolidateFolder = 'TestDrive:\consolidate_folder'
            New-Item -Path $consolidateFolder -ItemType Directory -Force | Out-Null
            
            $file1 = Join-Path $consolidateFolder 'cgm_data_1.csv'
            @"
Name:John Doe, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value,Unit
2025-01-01 10:00,100,mg/dL
2025-01-01 10:05,105,mg/dL
"@ | Out-File -FilePath $file1 -Encoding UTF8
            
            $file2 = Join-Path $consolidateFolder 'cgm_data_2.csv'
            @"
Name:John Doe, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value,Unit
2025-01-01 10:10,110,mg/dL
2025-01-01 10:15,108,mg/dL
"@ | Out-File -FilePath $file2 -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $consolidateFolder
            
            # Should consolidate into one dataset
            $results | Should -HaveCount 1
            $results[0].Metadata.Dataset | Should -Be 'cgm'
            $results[0].Metadata.FullName | Should -Be 'cgm_data_1.csv'
            $results[0].Metadata.Order | Should -Be 1
            $results[0].Data | Should -HaveCount 4
        }
        
        It 'Should merge data in ascending Order' {
            $consolidateFolder = 'TestDrive:\consolidate_order_folder'
            New-Item -Path $consolidateFolder -ItemType Directory -Force | Out-Null
            
            # Create files out of order (2, then 1, then 3)
            $file2 = Join-Path $consolidateFolder 'alarms_data_2.csv'
            @"
Name:Jane Doe, Date Range:2025-02-01 - 2025-02-28
Timestamp,Alarm
2025-02-15 12:00,Medium
"@ | Out-File -FilePath $file2 -Encoding UTF8
            
            $file1 = Join-Path $consolidateFolder 'alarms_data_1.csv'
            @"
Name:Jane Doe, Date Range:2025-02-01 - 2025-02-28
Timestamp,Alarm
2025-02-01 10:00,Low
"@ | Out-File -FilePath $file1 -Encoding UTF8
            
            $file3 = Join-Path $consolidateFolder 'alarms_data_3.csv'
            @"
Name:Jane Doe, Date Range:2025-02-01 - 2025-02-28
Timestamp,Alarm
2025-02-28 18:00,High
"@ | Out-File -FilePath $file3 -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $consolidateFolder
            
            $results | Should -HaveCount 1
            $results[0].Data | Should -HaveCount 3
            $results[0].Data[0].Alarm | Should -Be 'Low'
            $results[0].Data[1].Alarm | Should -Be 'Medium'
            $results[0].Data[2].Alarm | Should -Be 'High'
        }
        
        It 'Should not consolidate files with different Dataset values' {
            $consolidateFolder = 'TestDrive:\no_consolidate_dataset_folder'
            New-Item -Path $consolidateFolder -ItemType Directory -Force | Out-Null
            
            $cgmFile = Join-Path $consolidateFolder 'cgm_data_1.csv'
            @"
Name:Test User, Date Range:2025-03-01 - 2025-03-31
Timestamp,Value
2025-03-01 10:00,100
"@ | Out-File -FilePath $cgmFile -Encoding UTF8
            
            $alarmFile = Join-Path $consolidateFolder 'alarms_data_1.csv'
            @"
Name:Test User, Date Range:2025-03-01 - 2025-03-31
Timestamp,Alarm
2025-03-01 10:00,Low
"@ | Out-File -FilePath $alarmFile -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $consolidateFolder
            
            # Should NOT consolidate - different datasets
            $results | Should -HaveCount 2
        }
        
        It 'Should not consolidate files with different OriginalFirstLine' {
            $consolidateFolder = 'TestDrive:\no_consolidate_firstline_folder'
            New-Item -Path $consolidateFolder -ItemType Directory -Force | Out-Null
            
            $file1 = Join-Path $consolidateFolder 'cgm_data_1.csv'
            @"
Name:User A, Date Range:2025-04-01 - 2025-04-30
Timestamp,Value
2025-04-01 10:00,100
"@ | Out-File -FilePath $file1 -Encoding UTF8
            
            $file2 = Join-Path $consolidateFolder 'cgm_data_2.csv'
            @"
Name:User B, Date Range:2025-04-01 - 2025-04-30
Timestamp,Value
2025-04-01 10:00,105
"@ | Out-File -FilePath $file2 -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $consolidateFolder
            
            # Should NOT consolidate - different OriginalFirstLine (different names)
            $results | Should -HaveCount 2
        }
        
        It 'Should use metadata from file with lowest Order' {
            $consolidateFolder = 'TestDrive:\consolidate_metadata_folder'
            New-Item -Path $consolidateFolder -ItemType Directory -Force | Out-Null
            
            $file1 = Join-Path $consolidateFolder 'test_data_1.csv'
            @"
Name:Metadata User, Date Range:2025-05-01 - 2025-05-31
Timestamp,Value
2025-05-01 10:00,100
"@ | Out-File -FilePath $file1 -Encoding UTF8
            
            $file2 = Join-Path $consolidateFolder 'test_data_2.csv'
            @"
Name:Metadata User, Date Range:2025-05-01 - 2025-05-31
Timestamp,Value
2025-05-01 10:05,105
"@ | Out-File -FilePath $file2 -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $consolidateFolder
            
            $results | Should -HaveCount 1
            # Should use metadata from Order=1 file
            $results[0].Metadata.FullName | Should -Be 'test_data_1.csv'
            $results[0].Metadata.Order | Should -Be 1
        }
        
        It 'Should handle mixed scenarios with some files consolidating and others not' {
            $consolidateFolder = 'TestDrive:\mixed_consolidate_folder'
            New-Item -Path $consolidateFolder -ItemType Directory -Force | Out-Null
            
            # Group 1: cgm files that should consolidate
            $cgm1 = Join-Path $consolidateFolder 'cgm_data_1.csv'
            @"
Name:Patient X, Date Range:2025-06-01 - 2025-06-30
Timestamp,Value
2025-06-01 10:00,100
"@ | Out-File -FilePath $cgm1 -Encoding UTF8
            
            $cgm2 = Join-Path $consolidateFolder 'cgm_data_2.csv'
            @"
Name:Patient X, Date Range:2025-06-01 - 2025-06-30
Timestamp,Value
2025-06-01 10:05,105
"@ | Out-File -FilePath $cgm2 -Encoding UTF8
            
            # Standalone file that should not consolidate
            $standalone = Join-Path $consolidateFolder 'other.csv'
            @"
Different metadata line
Timestamp,Data
2025-06-01 10:00,abc
"@ | Out-File -FilePath $standalone -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $consolidateFolder
            
            # Should have 2 results: consolidated cgm data and standalone other
            $results | Should -HaveCount 2
            
            $cgmResult = $results | Where-Object { $_.Metadata.Dataset -eq 'cgm' }
            $cgmResult | Should -Not -BeNullOrEmpty
            $cgmResult.Data | Should -HaveCount 2
            
            $otherResult = $results | Where-Object { $_.Metadata.Dataset -eq $null }
            $otherResult | Should -Not -BeNullOrEmpty
            $otherResult.Data | Should -HaveCount 1
        }
    }
}
