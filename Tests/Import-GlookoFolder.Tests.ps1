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
        # Create test folder structures in TestDrive for each test
        $Script:TestFolders = New-TestFolders
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
}
