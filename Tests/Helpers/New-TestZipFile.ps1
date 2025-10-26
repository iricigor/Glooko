function New-TestZipFile {
    <#
    .SYNOPSIS
        Creates test zip files with CSV files in TestDrive for Import-GlookoZip tests
    
    .DESCRIPTION
        This function creates various test zip file scenarios with CSV files
        for comprehensive testing of the Import-GlookoZip function.
    
    .OUTPUTS
        Hashtable with paths to created test zip files
    #>
    
    # Test zip with multiple CSV files
    $testFolder = 'TestDrive:\zip_test_folder'
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
    
    $multiFileZip = 'TestDrive:\multi_file.zip'
    Compress-Archive -Path "$testFolder\*" -DestinationPath $multiFileZip -Force
    Remove-Item $testFolder -Recurse -Force
    
    # Test zip with single CSV file
    $singleFolder = 'TestDrive:\zip_single_folder'
    New-Item -Path $singleFolder -ItemType Directory -Force | Out-Null
    
    $singleCSV = Join-Path $singleFolder 'single.csv'
    @"
Skip this line
Name,Age
Charlie,45
"@ | Out-File -FilePath $singleCSV -Encoding UTF8
    
    $singleFileZip = 'TestDrive:\single_file.zip'
    Compress-Archive -Path "$singleFolder\*" -DestinationPath $singleFileZip -Force
    Remove-Item $singleFolder -Recurse -Force
    
    # Test zip with mixed files (CSV and non-CSV)
    $mixedFolder = 'TestDrive:\zip_mixed_folder'
    New-Item -Path $mixedFolder -ItemType Directory -Force | Out-Null
    
    $mixedCSV = Join-Path $mixedFolder 'data.csv'
    @"
Metadata
Name,Age
David,50
"@ | Out-File -FilePath $mixedCSV -Encoding UTF8
    
    $txtFile = Join-Path $mixedFolder 'readme.txt'
    'This is not a CSV file' | Out-File -FilePath $txtFile -Encoding UTF8
    
    $mixedFileZip = 'TestDrive:\mixed_files.zip'
    Compress-Archive -Path "$mixedFolder\*" -DestinationPath $mixedFileZip -Force
    Remove-Item $mixedFolder -Recurse -Force
    
    # Test zip with no CSV files (only txt file)
    $noCsvFolder = 'TestDrive:\zip_no_csv_folder'
    New-Item -Path $noCsvFolder -ItemType Directory -Force | Out-Null
    
    $noCsvTxt = Join-Path $noCsvFolder 'readme.txt'
    'This is not a CSV file' | Out-File -FilePath $noCsvTxt -Encoding UTF8
    
    $noCsvZip = 'TestDrive:\no_csv.zip'
    Compress-Archive -Path "$noCsvFolder\*" -DestinationPath $noCsvZip -Force
    Remove-Item $noCsvFolder -Recurse -Force
    
    # Test zip with CGM data (for metadata testing)
    $metadataFolder = 'TestDrive:\zip_metadata_folder'
    New-Item -Path $metadataFolder -ItemType Directory -Force | Out-Null
    
    $metadataCSV = Join-Path $metadataFolder 'cgm_data_1.csv'
    @"
Name:Igor Irić, Date Range:2025-05-31 - 2025-08-17
Timestamp,Value,Unit
2025-05-31 10:00,100,mg/dL
"@ | Out-File -FilePath $metadataCSV -Encoding UTF8
    
    $metadataZip = 'TestDrive:\metadata.zip'
    Compress-Archive -Path "$metadataFolder\*" -DestinationPath $metadataZip -Force
    Remove-Item $metadataFolder -Recurse -Force
    
    # Test zip with special characters in data
    $specialFolder = 'TestDrive:\zip_special_folder'
    New-Item -Path $specialFolder -ItemType Directory -Force | Out-Null
    
    $specialCSV = Join-Path $specialFolder 'special.csv'
    @"
Skip this metadata line
Name,Description,Value
Test,"Data with, comma",123
Quote,"Data with ""quotes""",456
"@ | Out-File -FilePath $specialCSV -Encoding UTF8
    
    $specialZip = 'TestDrive:\special.zip'
    Compress-Archive -Path "$specialFolder\*" -DestinationPath $specialZip -Force
    Remove-Item $specialFolder -Recurse -Force
    
    # Test zip with consolidation (multiple files with same metadata)
    $consolidateFolder = 'TestDrive:\zip_consolidate_folder'
    New-Item -Path $consolidateFolder -ItemType Directory -Force | Out-Null
    
    $cgmFile1 = Join-Path $consolidateFolder 'cgm_data_1.csv'
    @"
Name:John Doe, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value,Unit
2025-01-01 10:00,100,mg/dL
2025-01-01 10:05,105,mg/dL
"@ | Out-File -FilePath $cgmFile1 -Encoding UTF8
    
    $cgmFile2 = Join-Path $consolidateFolder 'cgm_data_2.csv'
    @"
Name:John Doe, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value,Unit
2025-01-01 10:10,110,mg/dL
2025-01-01 10:15,108,mg/dL
"@ | Out-File -FilePath $cgmFile2 -Encoding UTF8
    
    $consolidateZip = 'TestDrive:\consolidate.zip'
    Compress-Archive -Path "$consolidateFolder\*" -DestinationPath $consolidateZip -Force
    Remove-Item $consolidateFolder -Recurse -Force
    
    # Test zip with long dataset name (for worksheet name testing)
    $longNameFolder = 'TestDrive:\long_name_test'
    New-Item -Path $longNameFolder -ItemType Directory -Force | Out-Null
    
    $longNameCSV = Join-Path $longNameFolder 'very_long_dataset_name_that_exceeds_limit_data_1.csv'
    @"
Name:Test User, Date Range:2025-01-01 - 2025-01-31
Value,Unit
100,mg/dL
"@ | Out-File -FilePath $longNameCSV -Encoding UTF8
    
    $longNameZip = 'TestDrive:\long_name.zip'
    Compress-Archive -Path "$longNameFolder\*" -DestinationPath $longNameZip -Force
    Remove-Item $longNameFolder -Recurse -Force
    
    # Test zip with simple CSV (for invalid character testing)
    $invalidCharsFolder = 'TestDrive:\invalid_chars_test'
    New-Item -Path $invalidCharsFolder -ItemType Directory -Force | Out-Null
    
    $invalidCharsCSV = Join-Path $invalidCharsFolder 'test.csv'
    @"
Name:Test User, Date Range:2025-01-01 - 2025-01-31
Value,Unit
100,mg/dL
"@ | Out-File -FilePath $invalidCharsCSV -Encoding UTF8
    
    $invalidCharsZip = 'TestDrive:\invalid_chars.zip'
    Compress-Archive -Path "$invalidCharsFolder\*" -DestinationPath $invalidCharsZip -Force
    Remove-Item $invalidCharsFolder -Recurse -Force
    
    # Return hashtable with all zip file paths
    return @{
        MultiFileZip = $multiFileZip
        SingleFileZip = $singleFileZip
        MixedFileZip = $mixedFileZip
        NoCsvZip = $noCsvZip
        MetadataZip = $metadataZip
        SpecialZip = $specialZip
        ConsolidateZip = $consolidateZip
        LongNameZip = $longNameZip
        InvalidCharsZip = $invalidCharsZip
        NonExistentZip = 'TestDrive:\nonexistent.zip'
        NotAZipFile = 'TestDrive:\notazip.txt'
        FolderNotFile = 'TestDrive:\afolder'
    }
}
