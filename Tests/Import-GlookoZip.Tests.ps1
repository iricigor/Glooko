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
    
    Context 'Basic functionality' {
        
        It 'Should import all CSV files from a zip file' {
            # Create test CSV files in TestDrive
            $testFolder = 'TestDrive:\test_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV1 = Join-Path $testFolder 'file1.csv'
            @"
Metadata: Export from system on 2025-10-18
Name,Age,City
John,25,New York
Jane,30,Los Angeles
"@ | Out-File -FilePath $testCSV1 -Encoding UTF8
            
            $testCSV2 = Join-Path $testFolder 'file2.csv'
            @"
Skip this line
Name,Age,City
Bob,35,Chicago
"@ | Out-File -FilePath $testCSV2 -Encoding UTF8
            
            # Create a zip file
            $zipFile = 'TestDrive:\test.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            # Import the zip file
            $results = Import-GlookoZip -Path $zipFile
            
            $results | Should -HaveCount 2
            $results | ForEach-Object {
                $_ | Should -BeOfType [PSCustomObject]
                $_.PSObject.Properties.Name | Should -Contain 'Metadata'
                $_.PSObject.Properties.Name | Should -Contain 'Data'
            }
        }
        
        It 'Should import files with correct data from zip file' {
            $testFolder = 'TestDrive:\test_folder2'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV1 = Join-Path $testFolder 'data1.csv'
            @"
Metadata line
Name,Value
Alice,100
Bob,200
"@ | Out-File -FilePath $testCSV1 -Encoding UTF8
            
            $zipFile = 'TestDrive:\test2.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            $results = Import-GlookoZip -Path $zipFile
            
            $results | Should -HaveCount 1
            $results[0].Data | Should -HaveCount 2
            $results[0].Data[0].Name | Should -Be 'Alice'
            $results[0].Data[0].Value | Should -Be '100'
            $results[0].Data[1].Name | Should -Be 'Bob'
            $results[0].Data[1].Value | Should -Be '200'
        }
        
        It 'Should work with zip file containing single CSV file' {
            $testFolder = 'TestDrive:\single_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV = Join-Path $testFolder 'single.csv'
            @"
Skip this line
Name,Age
Charlie,45
"@ | Out-File -FilePath $testCSV -Encoding UTF8
            
            $zipFile = 'TestDrive:\single.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            $results = Import-GlookoZip -Path $zipFile
            
            $results | Should -HaveCount 1
            $results[0].Data | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Charlie'
        }
        
        It 'Should ignore non-CSV files in the zip file' {
            $testFolder = 'TestDrive:\mixed_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV = Join-Path $testFolder 'data.csv'
            @"
Metadata
Name,Age
David,50
"@ | Out-File -FilePath $testCSV -Encoding UTF8
            
            $txtFile = Join-Path $testFolder 'readme.txt'
            'This is not a CSV file' | Out-File -FilePath $txtFile -Encoding UTF8
            
            $zipFile = 'TestDrive:\mixed.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            $results = Import-GlookoZip -Path $zipFile
            
            # Should only import the CSV file
            $results | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'David'
        }
        
        It 'Should handle zip file without CSV files' {
            $testFolder = 'TestDrive:\no_csv_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            # Create a non-CSV file
            $txtFile = Join-Path $testFolder 'readme.txt'
            'This is not a CSV file' | Out-File -FilePath $txtFile -Encoding UTF8
            
            $zipFile = 'TestDrive:\no_csv.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            $warnings = @()
            $results = Import-GlookoZip -Path $zipFile -WarningVariable warnings
            
            $results | Should -BeNullOrEmpty
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "No CSV files found"
        }
    }
    
    Context 'Error handling' {
        
        It 'Should throw error for non-existent zip file' {
            { Import-GlookoZip -Path 'TestDrive:\nonexistent.zip' } | Should -Throw "*File not found*"
        }
        
        It 'Should throw error when path is not a zip file' {
            $txtFile = 'TestDrive:\notazip.txt'
            'This is not a zip file' | Out-File -FilePath $txtFile -Encoding UTF8
            
            { Import-GlookoZip -Path $txtFile } | Should -Throw "*File must have .zip extension*"
        }
        
        It 'Should throw error when path is a folder instead of file' {
            $folder = 'TestDrive:\afolder'
            New-Item -Path $folder -ItemType Directory -Force | Out-Null
            
            { Import-GlookoZip -Path $folder } | Should -Throw "*File not found*"
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $testFolder = 'TestDrive:\pipeline_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV = Join-Path $testFolder 'pipeline.csv'
            @"
Skip line
Name,Age
Frank,55
"@ | Out-File -FilePath $testCSV -Encoding UTF8
            
            $zipFile = 'TestDrive:\pipeline.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            $results = $zipFile | Import-GlookoZip
            
            $results | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Frank'
        }
        
        It 'Should work with Get-ChildItem pipeline' {
            $testFolder = 'TestDrive:\getitem_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV = Join-Path $testFolder 'getitem.csv'
            @"
Metadata
Name,Age
Grace,60
"@ | Out-File -FilePath $testCSV -Encoding UTF8
            
            $zipFile = 'TestDrive:\getitem.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            $results = Get-ChildItem -Path $zipFile | Select-Object -ExpandProperty FullName | Import-GlookoZip
            
            $results | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Grace'
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            $testFolder = 'TestDrive:\verbose_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV = Join-Path $testFolder 'verbose.csv'
            @"
Skip
Name,Age
Henry,65
"@ | Out-File -FilePath $testCSV -Encoding UTF8
            
            $zipFile = 'TestDrive:\verbose.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            # Test that the function runs with -Verbose without errors
            $results = Import-GlookoZip -Path $zipFile -Verbose
            
            # Verify the function still works correctly with verbose output
            $results | Should -HaveCount 1
            $results[0].Data[0].Name | Should -Be 'Henry'
        }
    }
    
    Context 'Data integrity' {
        
        It 'Should preserve all metadata from individual files' {
            $testFolder = 'TestDrive:\metadata_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV = Join-Path $testFolder 'cgm_data_1.csv'
            @"
Name:Igor Irić, Date Range:2025-05-31 - 2025-08-17
Timestamp,Value,Unit
2025-05-31 10:00,100,mg/dL
"@ | Out-File -FilePath $testCSV -Encoding UTF8
            
            $zipFile = 'TestDrive:\metadata.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            $results = Import-GlookoZip -Path $zipFile
            
            $results | Should -HaveCount 1
            $results[0].Metadata | Should -Not -BeNullOrEmpty
            $results[0].Metadata.Name | Should -Be 'Igor Irić'
            $results[0].Metadata.DateRange | Should -Be '2025-05-31 - 2025-08-17'
            $results[0].Metadata.Dataset | Should -Be 'cgm'
            $results[0].Metadata.Order | Should -Be 1
        }
        
        It 'Should handle special characters in data correctly' {
            $testFolder = 'TestDrive:\special_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV = Join-Path $testFolder 'special.csv'
            @"
Skip this metadata line
Name,Description,Value
Test,"Data with, comma",123
Quote,"Data with ""quotes""",456
"@ | Out-File -FilePath $testCSV -Encoding UTF8
            
            $zipFile = 'TestDrive:\special.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            $results = Import-GlookoZip -Path $zipFile
            
            $results | Should -HaveCount 1
            $results[0].Data | Should -HaveCount 2
            $results[0].Data[0].Description | Should -Be 'Data with, comma'
            $results[0].Data[1].Description | Should -Be 'Data with "quotes"'
        }
    }
    
    Context 'Dataset consolidation' {
        
        It 'Should consolidate files with same Dataset and OriginalFirstLine from zip' {
            $testFolder = 'TestDrive:\consolidate_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $file1 = Join-Path $testFolder 'cgm_data_1.csv'
            @"
Name:John Doe, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value,Unit
2025-01-01 10:00,100,mg/dL
2025-01-01 10:05,105,mg/dL
"@ | Out-File -FilePath $file1 -Encoding UTF8
            
            $file2 = Join-Path $testFolder 'cgm_data_2.csv'
            @"
Name:John Doe, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value,Unit
2025-01-01 10:10,110,mg/dL
2025-01-01 10:15,108,mg/dL
"@ | Out-File -FilePath $file2 -Encoding UTF8
            
            $zipFile = 'TestDrive:\consolidate.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            $results = Import-GlookoZip -Path $zipFile
            
            # Should consolidate into one dataset
            $results | Should -HaveCount 1
            $results[0].Metadata.Dataset | Should -Be 'cgm'
            $results[0].Data | Should -HaveCount 4
        }
    }
    
    Context 'Cleanup behavior' {
        
        It 'Should clean up temporary folder after successful import' {
            $testFolder = 'TestDrive:\cleanup_folder'
            New-Item -Path $testFolder -ItemType Directory -Force | Out-Null
            
            $testCSV = Join-Path $testFolder 'cleanup.csv'
            @"
Skip
Name,Age
Isabel,70
"@ | Out-File -FilePath $testCSV -Encoding UTF8
            
            $zipFile = 'TestDrive:\cleanup.zip'
            Compress-Archive -Path "$testFolder\*" -DestinationPath $zipFile -Force
            
            # Count temp folders before
            $tempPath = [System.IO.Path]::GetTempPath()
            $tempFoldersBefore = (Get-ChildItem -Path $tempPath -Directory).Count
            
            $results = Import-GlookoZip -Path $zipFile
            
            # Count temp folders after
            $tempFoldersAfter = (Get-ChildItem -Path $tempPath -Directory).Count
            
            # Should not have leftover temp folders (or at most the same count)
            $tempFoldersAfter | Should -BeLessOrEqual $tempFoldersBefore
        }
    }
}
