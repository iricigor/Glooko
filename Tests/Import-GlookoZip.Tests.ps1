BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
    
    # Import test helpers
    . (Join-Path $PSScriptRoot 'Helpers' 'TestHelpers.ps1')
}

AfterAll {
    # Remove the module (TestDrive is automatically cleaned up by Pester)
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Import-GlookoZip' {
    
    BeforeEach {
        # Create test zip files in TestDrive for each test
        $Script:TestZipFiles = New-TestZipFile
    }
    
    Context 'Basic functionality' {
        
        It 'Should import all CSV files from a zip file' {
            $results = Import-GlookoZip -Path $Script:TestZipFiles.MultiFileZip
            
            $results | Should -HaveCount 2
            $results | ForEach-Object {
                $_ | Should -BeOfType [PSCustomObject]
                $_.PSObject.Properties.Name | Should -Contain 'Metadata'
                $_.PSObject.Properties.Name | Should -Contain 'Data'
            }
        }
        
        It 'Should work with zip file containing single CSV file' {
            $results = Import-GlookoZip -Path $Script:TestZipFiles.SingleFileZip
            
            $results | Should -HaveCount 1
            $results[0].Data | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Charlie'
        }
        
        It 'Should ignore non-CSV files in the zip file' {
            $results = Import-GlookoZip -Path $Script:TestZipFiles.MixedFileZip
            
            # Should only import the CSV file
            $results | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'David'
        }
        
        It 'Should handle zip file without CSV files' {
            $warnings = @()
            $results = Import-GlookoZip -Path $Script:TestZipFiles.NoCsvZip -WarningVariable warnings
            
            $results | Should -BeNullOrEmpty
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "No CSV files found"
        }
    }
    
    Context 'Error handling' {
        
        It 'Should throw error for non-existent zip file' {
            { Import-GlookoZip -Path $Script:TestZipFiles.NonExistentZip } | Should -Throw "*File not found*"
        }
        
        It 'Should throw error when path is not a zip file' {
            'This is not a zip file' | Out-File -FilePath $Script:TestZipFiles.NotAZipFile -Encoding UTF8
            
            { Import-GlookoZip -Path $Script:TestZipFiles.NotAZipFile } | Should -Throw "*File must have .zip extension*"
        }
        
        It 'Should throw error when path is a folder instead of file' {
            New-Item -Path $Script:TestZipFiles.FolderNotFile -ItemType Directory -Force | Out-Null
            
            { Import-GlookoZip -Path $Script:TestZipFiles.FolderNotFile } | Should -Throw "*File not found*"
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $results = $Script:TestZipFiles.SingleFileZip | Import-GlookoZip
            
            $results | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Charlie'
        }
        
        It 'Should work with Get-ChildItem pipeline' {
            $results = Get-ChildItem -Path $Script:TestZipFiles.SingleFileZip | Select-Object -ExpandProperty FullName | Import-GlookoZip
            
            $results | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Charlie'
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            # Test that the function runs with -Verbose without errors
            $results = Import-GlookoZip -Path $Script:TestZipFiles.SingleFileZip -Verbose
            
            # Verify the function still works correctly with verbose output
            $results | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Charlie'
        }
    }
    
    Context 'Data integrity' {
        
        It 'Should preserve all metadata from individual files' {
            $results = Import-GlookoZip -Path $Script:TestZipFiles.MetadataZip
            
            $results | Should -HaveCount 1
            $results[0].Metadata | Should -Not -BeNullOrEmpty
            $results[0].Metadata.Name | Should -Be 'Igor Irić'
            $results[0].Metadata.DateRange | Should -Be '2025-05-31 - 2025-08-17'
            $results[0].Metadata.Dataset | Should -Be 'cgm'
            $results[0].Metadata.Order | Should -Be 1
        }
        
        It 'Should handle special characters in data correctly' {
            $results = Import-GlookoZip -Path $Script:TestZipFiles.SpecialZip
            
            $results | Should -HaveCount 1
            $results[0].Data | Should -HaveCount 2
            $results[0].Data[0].Description | Should -Be 'Data with, comma'
            $results[0].Data[1].Description | Should -Be 'Data with "quotes"'
        }
    }
    
    Context 'Dataset consolidation' {
        
        It 'Should consolidate files with same Dataset and OriginalFirstLine from zip' {
            $results = Import-GlookoZip -Path $Script:TestZipFiles.ConsolidateZip
            
            # Should consolidate into one dataset
            $results | Should -HaveCount 1
            $results[0].Metadata.Dataset | Should -Be 'cgm'
            $results[0].Data | Should -HaveCount 4
        }
    }
    
    Context 'Cleanup behavior' {
        
        It 'Should clean up temporary folder after successful import' {
            # Count temp folders before
            $tempPath = [System.IO.Path]::GetTempPath()
            $tempFoldersBefore = (Get-ChildItem -Path $tempPath -Directory).Count
            
            $results = Import-GlookoZip -Path $Script:TestZipFiles.SingleFileZip
            
            # Count temp folders after
            $tempFoldersAfter = (Get-ChildItem -Path $tempPath -Directory).Count
            
            # Should not have leftover temp folders (or at most the same count)
            $tempFoldersAfter | Should -BeLessOrEqual $tempFoldersBefore
        }
    }
}
