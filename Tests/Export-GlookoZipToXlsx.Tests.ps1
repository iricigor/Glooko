BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
    
    # Import ImportExcel module for testing
    # Try system-installed module first, then fallback to local paths
    if (Get-Module -ListAvailable -Name ImportExcel) {
        Import-Module ImportExcel -Force -ErrorAction SilentlyContinue
    } else {
        # Try Linux/Mac path
        $ImportExcelPath = '/tmp/ImportExcel/ImportExcel.psd1'
        if (Test-Path $ImportExcelPath) {
            Import-Module $ImportExcelPath -Force -ErrorAction SilentlyContinue
        } else {
            # Try Windows path
            $ImportExcelPath = 'C:\Temp\ImportExcel\ImportExcel.psd1'
            if (Test-Path $ImportExcelPath) {
                Import-Module $ImportExcelPath -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
    # Import test helpers
    . (Join-Path $PSScriptRoot 'Helpers' 'TestHelpers.ps1')
}

AfterAll {
    # Remove the modules (TestDrive is automatically cleaned up by Pester)
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
    Remove-Module ImportExcel -Force -ErrorAction SilentlyContinue
}

Describe 'Export-GlookoZipToXlsx' {
    
    BeforeAll {
        # Check if ImportExcel is available (either loaded or can be loaded)
        $importExcelLoaded = $null -ne (Get-Module -Name ImportExcel)
        $importExcelAvailable = $null -ne (Get-Module -ListAvailable -Name ImportExcel)
        $Script:ImportExcelAvailable = $importExcelLoaded -or $importExcelAvailable
    }
    
    BeforeEach {
        # Create test zip files in TestDrive for each test
        $Script:TestZipFiles = New-TestZipFile
    }
    
    Context 'Module dependency checks' {
        
        # Note: This test context is for checking ImportExcel dependency
        # In test environment, we always load ImportExcel, so we test that the function works
        # In production, users without ImportExcel will get an error message
        
        It 'Should work when ImportExcel module is available' {
            # This test verifies the function works when ImportExcel is present
            { Export-GlookoZipToXlsx -Path $Script:TestZipFiles.SingleFileZip } | Should -Not -Throw
        }
    }
    
    Context 'Basic functionality' {
        
        It 'Should create XLSX file from zip file' {
            $zipPath = $Script:TestZipFiles.SingleFileZip
            
            $result = Export-GlookoZipToXlsx -Path $zipPath
            
            $result | Should -Not -BeNullOrEmpty
            $result.Extension | Should -Be '.xlsx'
            $result.Exists | Should -Be $true
            # The file should have the same base name as the zip
            $result.BaseName | Should -Be 'single_file'
        }
        
        It 'Should create XLSX file in same location as ZIP file by default' {
            $zipPath = $Script:TestZipFiles.SingleFileZip
            
            $result = Export-GlookoZipToXlsx -Path $zipPath
            
            # Both files should be in the same directory (when resolved)
            $zipFileInfo = Get-Item -Path $zipPath
            $xlsxFileInfo = Get-Item -Path $result.FullName
            
            $zipFileInfo.DirectoryName | Should -Be $xlsxFileInfo.DirectoryName
        }
        
        It 'Should use ZIP filename for XLSX filename by default' {
            $zipPath = $Script:TestZipFiles.SingleFileZip
            
            $result = Export-GlookoZipToXlsx -Path $zipPath
            
            $resultBaseName = [System.IO.Path]::GetFileNameWithoutExtension($result.FullName)
            # Should match the ZIP basename
            $resultBaseName | Should -Be 'single_file'
        }
        
        It 'Should accept custom OutputPath parameter' {
            $customOutput = Join-Path (Get-PSDrive TestDrive).Root 'custom_output.xlsx'
            
            $result = Export-GlookoZipToXlsx -Path $Script:TestZipFiles.SingleFileZip -OutputPath $customOutput
            
            $result.FullName | Should -Be $customOutput
            Test-Path $customOutput | Should -Be $true
        }
        
        It 'Should create worksheets for each dataset' {
            $zipPath = $Script:TestZipFiles.MetadataZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            Export-GlookoZipToXlsx -Path $zipPath
            
            # Import the created Excel file to verify worksheets
            $excelData = Import-Excel -Path $outputPath -WorksheetName 'cgm'
            
            $excelData | Should -Not -BeNullOrEmpty
            $excelData.Count | Should -Be 1
            $excelData[0].Timestamp | Should -Be '2025-05-31 10:00'
        }
        
        It 'Should handle multiple datasets in separate worksheets' {
            $zipPath = $Script:TestZipFiles.MultiFileZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            Export-GlookoZipToXlsx -Path $zipPath
            
            Test-Path $outputPath | Should -Be $true
            
            # The multi-file zip has files without dataset names in metadata
            # Should create worksheets with data
            $worksheets = Get-ExcelSheetInfo -Path $outputPath
            $worksheets | Should -Not -BeNullOrEmpty
        }
        
        It 'Should handle zip file with consolidated datasets' {
            $zipPath = $Script:TestZipFiles.ConsolidateZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            Export-GlookoZipToXlsx -Path $zipPath
            
            # Import the cgm worksheet
            $excelData = Import-Excel -Path $outputPath -WorksheetName 'cgm'
            
            # Should have all 4 rows consolidated
            $excelData | Should -Not -BeNullOrEmpty
            $excelData.Count | Should -Be 4
        }
        
        It 'Should preserve data integrity in Excel export' {
            $zipPath = $Script:TestZipFiles.SpecialZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            Export-GlookoZipToXlsx -Path $zipPath
            
            $worksheets = Get-ExcelSheetInfo -Path $outputPath
            $worksheetName = $worksheets[0].Name
            $excelData = Import-Excel -Path $outputPath -WorksheetName $worksheetName
            
            $excelData | Should -Not -BeNullOrEmpty
            $excelData[0].Description | Should -Be 'Data with, comma'
            $excelData[1].Description | Should -Be 'Data with "quotes"'
        }
        
        It 'Should overwrite existing XLSX file when Force is specified' {
            $zipPath = $Script:TestZipFiles.SingleFileZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            # Create file first time
            Export-GlookoZipToXlsx -Path $zipPath -Force
            $firstWrite = Get-Item $outputPath
            
            Start-Sleep -Milliseconds 100
            
            # Create file second time with -Force
            Export-GlookoZipToXlsx -Path $zipPath -Force
            $secondWrite = Get-Item $outputPath
            
            # Should have been overwritten (different write time)
            $secondWrite.LastWriteTime | Should -BeGreaterThan $firstWrite.LastWriteTime
        }
        
        It 'Should create new file with timestamp when file exists and Force is not specified' {
            $zipPath = $Script:TestZipFiles.SingleFileZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            # Create file first time
            Export-GlookoZipToXlsx -Path $zipPath -Force
            $firstFile = Get-Item $outputPath
            $firstFile | Should -Not -BeNullOrEmpty
            
            Start-Sleep -Milliseconds 1100
            
            # Create file second time without -Force
            $result = Export-GlookoZipToXlsx -Path $zipPath
            
            # Should have created a new file with timestamp
            $result.Name | Should -Not -Be $firstFile.Name
            $result.Name | Should -Match 'single_file_\d{6}_\d{6}\.xlsx'
            
            # Both files should exist
            Test-Path $outputPath | Should -Be $true
            Test-Path $result.FullName | Should -Be $true
        }
        
        It 'Should create file without timestamp when file does not exist' {
            $zipPath = $Script:TestZipFiles.SingleFileZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            # Ensure file doesn't exist
            if (Test-Path $outputPath) {
                Remove-Item $outputPath -Force
            }
            
            # Create file without -Force
            $result = Export-GlookoZipToXlsx -Path $zipPath
            
            # Should have created file without timestamp
            $result.Name | Should -Be 'single_file.xlsx'
            Test-Path $outputPath | Should -Be $true
        }
    }
    
    Context 'Error handling' {
        
        It 'Should throw error for non-existent zip file' {
            { Export-GlookoZipToXlsx -Path $Script:TestZipFiles.NonExistentZip } | Should -Throw "*File not found*"
        }
        
        It 'Should throw error when path is not a zip file' {
            'This is not a zip file' | Out-File -FilePath $Script:TestZipFiles.NotAZipFile -Encoding UTF8
            
            { Export-GlookoZipToXlsx -Path $Script:TestZipFiles.NotAZipFile } | Should -Throw "*File must have .zip extension*"
        }
        
        It 'Should throw error when path is a folder instead of file' {
            New-Item -Path $Script:TestZipFiles.FolderNotFile -ItemType Directory -Force | Out-Null
            
            { Export-GlookoZipToXlsx -Path $Script:TestZipFiles.FolderNotFile } | Should -Throw "*File not found*"
        }
        
        It 'Should warn when zip file has no CSV files' {
            $warnings = @()
            $result = Export-GlookoZipToXlsx -Path $Script:TestZipFiles.NoCsvZip -WarningVariable warnings
            
            # Should have warnings (from Import-GlookoZip and/or Export-GlookoZipToXlsx)
            $warnings.Count | Should -BeGreaterThan 0
            ($warnings -join ' ') | Should -Match "No (CSV files found|data found)"
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $outputPath = [System.IO.Path]::ChangeExtension($Script:TestZipFiles.SingleFileZip, '.xlsx')
            
            $result = $Script:TestZipFiles.SingleFileZip | Export-GlookoZipToXlsx
            
            $result | Should -Not -BeNullOrEmpty
            Test-Path $outputPath | Should -Be $true
        }
        
        It 'Should work with Get-ChildItem pipeline' {
            $outputPath = [System.IO.Path]::ChangeExtension($Script:TestZipFiles.SingleFileZip, '.xlsx')
            
            $result = Get-ChildItem -Path $Script:TestZipFiles.SingleFileZip | Select-Object -ExpandProperty FullName | Export-GlookoZipToXlsx
            
            $result | Should -Not -BeNullOrEmpty
            Test-Path $outputPath | Should -Be $true
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            # Test that the function runs with -Verbose without errors
            $result = Export-GlookoZipToXlsx -Path $Script:TestZipFiles.SingleFileZip -Verbose
            
            # Verify the function still works correctly with verbose output
            $result | Should -Not -BeNullOrEmpty
            Test-Path $result.FullName | Should -Be $true
        }
    }
    
    Context 'Worksheet naming' {
        
        It 'Should use dataset name as worksheet name when available' {
            $zipPath = $Script:TestZipFiles.MetadataZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            Export-GlookoZipToXlsx -Path $zipPath
            
            $worksheets = Get-ExcelSheetInfo -Path $outputPath
            $worksheets[0].Name | Should -Be 'cgm'
        }
        
        It 'Should handle worksheet names longer than 31 characters' {
            $zipPath = $Script:TestZipFiles.LongNameZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            Export-GlookoZipToXlsx -Path $zipPath
            
            $worksheets = Get-ExcelSheetInfo -Path $outputPath
            $worksheets[0].Name.Length | Should -BeLessOrEqual 31
        }
        
        It 'Should sanitize invalid worksheet name characters' {
            $zipPath = $Script:TestZipFiles.InvalidCharsZip
            $outputPath = [System.IO.Path]::ChangeExtension($zipPath, '.xlsx')
            
            # Should not throw even if dataset name has invalid characters
            { Export-GlookoZipToXlsx -Path $zipPath } | Should -Not -Throw
        }
    }
}
