BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
    
    # Import test helpers
    . (Join-Path $PSScriptRoot 'TestHelpers.ps1')
    
    # Import Private functions for direct testing
    . (Join-Path $PSScriptRoot '..' 'Private' 'Expand-GlookoMetadata.ps1')
}

AfterAll {
    # Remove the module (TestDrive is automatically cleaned up by Pester)
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Import-GlookoFolder' {
    
    BeforeEach {
        # Create a test folder structure in TestDrive
        $Script:TestFolder = 'TestDrive:\test_folder'
        New-Item -Path $Script:TestFolder -ItemType Directory -Force | Out-Null
        
        # Create multiple test CSV files in the folder
        $testCSV1 = Join-Path $Script:TestFolder 'file1.csv'
        @"
Metadata: Export from system on 2025-10-18
Name,Age,City
John,25,New York
Jane,30,Los Angeles
"@ | Out-File -FilePath $testCSV1 -Encoding UTF8

        $testCSV2 = Join-Path $Script:TestFolder 'file2.csv'
        @"
Skip this line
Name,Age,City
Bob,35,Chicago
"@ | Out-File -FilePath $testCSV2 -Encoding UTF8

        $testCSV3 = Join-Path $Script:TestFolder 'file3.csv'
        @"
Name:Igor Irić, Date Range:2025-05-31 - 2025-08-17
Timestamp,Alarm/Event,Serial Number
8/17/2025 0:15,tandem_control_low,1266847
8/16/2025 22:35,tandem_control_low,1266847
"@ | Out-File -FilePath $testCSV3 -Encoding UTF8
    }
    
    Context 'Basic functionality' {
        
        It 'Should import all CSV files from a folder' {
            $results = Import-GlookoFolder -Path $Script:TestFolder
            
            $results | Should -HaveCount 3
            $results | ForEach-Object {
                $_ | Should -BeOfType [PSCustomObject]
                $_.PSObject.Properties.Name | Should -Contain 'Metadata'
                $_.PSObject.Properties.Name | Should -Contain 'Data'
            }
        }
        
        It 'Should import files with correct data from each file' {
            $results = Import-GlookoFolder -Path $Script:TestFolder
            
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
            $emptyFolder = 'TestDrive:\empty_folder'
            New-Item -Path $emptyFolder -ItemType Directory -Force | Out-Null
            
            $warnings = @()
            $results = Import-GlookoFolder -Path $emptyFolder -WarningVariable warnings
            
            $results | Should -BeNullOrEmpty
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "No CSV files found"
        }
        
        It 'Should work with folder containing only one CSV file' {
            $singleFileFolder = 'TestDrive:\single_file_folder'
            New-Item -Path $singleFileFolder -ItemType Directory -Force | Out-Null
            
            $testCSV = Join-Path $singleFileFolder 'single.csv'
            @"
Skip this line
Name,Age,City
Alice,28,Boston
"@ | Out-File -FilePath $testCSV -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $singleFileFolder
            
            $results | Should -HaveCount 1
            $results[0].Metadata.FullName | Should -Be 'single.csv'
            $results[0].Data | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Alice'
        }
        
        It 'Should ignore non-CSV files in the folder' {
            # Add a non-CSV file to the test folder
            $txtFile = Join-Path $Script:TestFolder 'readme.txt'
            'This is not a CSV file' | Out-File -FilePath $txtFile -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $Script:TestFolder
            
            # Should still only import the 3 CSV files
            $results | Should -HaveCount 3
        }
    }
    
    Context 'Error handling' {
        
        It 'Should throw error for non-existent folder' {
            { Import-GlookoFolder -Path 'TestDrive:\nonexistent_folder' } | Should -Throw "*Folder not found*"
        }
        
        It 'Should throw error when path is a file instead of folder' {
            $testFile = 'TestDrive:\testfile.csv'
            'test' | Out-File -FilePath $testFile -Encoding UTF8
            
            { Import-GlookoFolder -Path $testFile } | Should -Throw "*Folder not found*"
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $results = $Script:TestFolder | Import-GlookoFolder
            
            $results | Should -HaveCount 3
        }
        
        It 'Should work with Get-Item pipeline' {
            $folderItem = Get-Item -Path $Script:TestFolder
            $results = $folderItem.FullName | Import-GlookoFolder
            
            $results | Should -HaveCount 3
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            # Test that the function runs with -Verbose without errors
            # and that it produces the expected result
            $results = Import-GlookoFolder -Path $Script:TestFolder -Verbose
            
            # Verify the function still works correctly with verbose output
            $results | Should -HaveCount 3
        }
    }
    
    Context 'Data integrity' {
        
        It 'Should preserve all metadata from individual files' {
            $results = Import-GlookoFolder -Path $Script:TestFolder
            
            # Each result should have complete metadata structure
            $results | ForEach-Object {
                $_.Metadata | Should -Not -BeNullOrEmpty
                $_.Metadata.PSObject.Properties.Name | Should -Contain 'FullName'
                $_.Metadata.PSObject.Properties.Name | Should -Contain 'OriginalFirstLine'
            }
        }
        
        It 'Should handle files with special characters correctly' {
            $specialFolder = 'TestDrive:\special_folder'
            New-Item -Path $specialFolder -ItemType Directory -Force | Out-Null
            
            $specialFile = Join-Path $specialFolder 'special.csv'
            @"
Skip this metadata line
Name,Description,Value
Test,"Data with, comma",123
Quote,"Data with ""quotes""",456
"@ | Out-File -FilePath $specialFile -Encoding UTF8
            
            $results = Import-GlookoFolder -Path $specialFolder
            
            $results | Should -HaveCount 1
            $results[0].Data | Should -HaveCount 2
            $results[0].Data[0].Description | Should -Be 'Data with, comma'
            $results[0].Data[1].Description | Should -Be 'Data with "quotes"'
        }
    }
}
