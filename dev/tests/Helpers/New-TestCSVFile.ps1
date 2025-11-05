function New-TestCSVFile {
    <#
    .SYNOPSIS
        Creates test CSV files in TestDrive for Import-GlookoCSV tests
    
    .DESCRIPTION
        This function creates various test CSV files with different scenarios
        for comprehensive testing of the Import-GlookoCSV function.
    
    .OUTPUTS
        Hashtable with paths to created test files
    #>
    
    # Test CSV with metadata in first row
    $testCSV1 = 'TestDrive:\test1.csv'
    @"
Metadata: Export from system on 2025-10-18
Name,Age,City
John,25,New York
Jane,30,Los Angeles
Bob,35,Chicago
"@ | Out-File -FilePath $testCSV1 -Encoding UTF8

    # Test CSV with different headers in first row
    $testCSV2 = 'TestDrive:\test2.csv'
    @"
OldName,OldAge,OldCity
Name,Age,City
Alice,28,Boston
Charlie,32,Seattle
"@ | Out-File -FilePath $testCSV2 -Encoding UTF8

    # Test CSV with only one data row
    $testCSV3 = 'TestDrive:\test3.csv'
    @"
Skip this line
Name,Age,City
David,40,Miami
"@ | Out-File -FilePath $testCSV3 -Encoding UTF8

    # Empty CSV file
    $testCSVEmpty = 'TestDrive:\test_empty.csv'
    '' | Out-File -FilePath $testCSVEmpty -Encoding UTF8

    # Single line CSV file
    $singleLineFile = 'TestDrive:\single_line.csv'
    'Only one line' | Out-File -FilePath $singleLineFile -Encoding UTF8

    # CSV with special characters
    $specialCharFile = 'TestDrive:\special_chars.csv'
    @"
Skip this metadata line
Name,Description,Value
Test,"Data with, comma",123
Quote,"Data with ""quotes""",456
"@ | Out-File -FilePath $specialCharFile -Encoding UTF8

    # CSV file matching the alarms_data_1.csv pattern
    $alarmsDataFile = 'TestDrive:\alarms_data_1.csv'
    @"
Name:Igor Irić, Date Range:2025-05-31 - 2025-08-17
Timestamp,Alarm/Event,Serial Number
8/17/2025 0:15,tandem_control_low,1266847
8/16/2025 22:35,tandem_control_low,1266847
"@ | Out-File -FilePath $alarmsDataFile -Encoding UTF8

    # Return hashtable with all file paths
    return @{
        TestCSV1 = $testCSV1
        TestCSV2 = $testCSV2
        TestCSV3 = $testCSV3
        TestCSVEmpty = $testCSVEmpty
        SingleLineFile = $singleLineFile
        SpecialCharFile = $specialCharFile
        AlarmsDataFile = $alarmsDataFile
        NonExistentFile = 'TestDrive:\nonexistent.csv'
    }
}
