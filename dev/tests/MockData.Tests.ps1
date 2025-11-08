BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
    
    # Path to mock data
    $Script:MockDataPath = Join-Path $PSScriptRoot 'Fixtures' 'MockData'
}

AfterAll {
    # Remove the module
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Mock Data Validation' {
    
    Context 'Mock data files exist' {
        
        It 'MockData directory should exist' {
            Test-Path $Script:MockDataPath | Should -Be $true
        }
        
        It 'Should have CGM data file' {
            $cgmFile = Join-Path $Script:MockDataPath 'cgm_data_1.csv'
            Test-Path $cgmFile | Should -Be $true
        }
        
        It 'Should have insulin data file' {
            $insulinFile = Join-Path $Script:MockDataPath 'insulin_data_1.csv'
            Test-Path $insulinFile | Should -Be $true
        }
        
        It 'Should have alarms data file' {
            $alarmsFile = Join-Path $Script:MockDataPath 'alarms_data_1.csv'
            Test-Path $alarmsFile | Should -Be $true
        }
        
        It 'Should have carbs data file' {
            $carbsFile = Join-Path $Script:MockDataPath 'carbs_data_1.csv'
            Test-Path $carbsFile | Should -Be $true
        }
        
        It 'Should have blood glucose data file' {
            $bgFile = Join-Path $Script:MockDataPath 'bg_data_1.csv'
            Test-Path $bgFile | Should -Be $true
        }
        
        It 'Should have README file' {
            $readmeFile = Join-Path $Script:MockDataPath 'README.md'
            Test-Path $readmeFile | Should -Be $true
        }
        
        It 'Should have real research CGM data file (Broll)' {
            $cgmFile2 = Join-Path $Script:MockDataPath 'cgm_data_2.csv'
            Test-Path $cgmFile2 | Should -Be $true
        }
    }
    
    Context 'CGM data validation' {
        
        BeforeAll {
            $cgmFile = Join-Path $Script:MockDataPath 'cgm_data_1.csv'
            $Script:CgmData = Import-GlookoCSV -Path $cgmFile
        }
        
        It 'Should import CGM data successfully' {
            $Script:CgmData | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have correct dataset name' {
            $Script:CgmData.Metadata.Dataset | Should -Be 'cgm'
        }
        
        It 'Should have CGM data records' {
            $Script:CgmData.Data.Count | Should -BeGreaterThan 0
        }
        
        It 'Should have expected CGM columns' {
            $Script:CgmData.Data[0].PSObject.Properties.Name | Should -Contain 'Timestamp'
            $Script:CgmData.Data[0].PSObject.Properties.Name | Should -Contain 'Glucose Value (mg/dL)'
            $Script:CgmData.Data[0].PSObject.Properties.Name | Should -Contain 'Glucose Trend'
        }
        
        It 'Should have realistic glucose values' {
            $glucoseValues = $Script:CgmData.Data | ForEach-Object { [int]$_.'Glucose Value (mg/dL)' }
            $minGlucose = ($glucoseValues | Measure-Object -Minimum).Minimum
            $maxGlucose = ($glucoseValues | Measure-Object -Maximum).Maximum
            
            $minGlucose | Should -BeGreaterThan 40
            $maxGlucose | Should -BeLessThan 400
        }
    }
    
    Context 'Real research CGM data validation (Broll)' {
        
        BeforeAll {
            $cgmFile2 = Join-Path $Script:MockDataPath 'cgm_data_2.csv'
            $Script:CgmData2 = Import-GlookoCSV -Path $cgmFile2
        }
        
        It 'Should import research CGM data successfully' {
            $Script:CgmData2 | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have correct dataset name' {
            $Script:CgmData2.Metadata.Dataset | Should -Be 'cgm'
        }
        
        It 'Should have CGM data records from Broll study' {
            $Script:CgmData2.Data.Count | Should -BeGreaterThan 0
        }
        
        It 'Should have patient name from Broll study' {
            $Script:CgmData2.Metadata.Name | Should -BeLike '*Broll*'
        }
        
        It 'Should have expected CGM columns' {
            $Script:CgmData2.Data[0].PSObject.Properties.Name | Should -Contain 'Timestamp'
            $Script:CgmData2.Data[0].PSObject.Properties.Name | Should -Contain 'Glucose Value (mg/dL)'
        }
        
        It 'Should have realistic glucose values' {
            $glucoseValues = $Script:CgmData2.Data | ForEach-Object { [int]$_.'Glucose Value (mg/dL)' }
            $minGlucose = ($glucoseValues | Measure-Object -Minimum).Minimum
            $maxGlucose = ($glucoseValues | Measure-Object -Maximum).Maximum
            
            $minGlucose | Should -BeGreaterThan 40
            $maxGlucose | Should -BeLessThan 400
        }
    }
    
    Context 'Insulin data validation' {
        
        BeforeAll {
            $insulinFile = Join-Path $Script:MockDataPath 'insulin_data_1.csv'
            $Script:InsulinData = Import-GlookoCSV -Path $insulinFile
        }
        
        It 'Should import insulin data successfully' {
            $Script:InsulinData | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have correct dataset name' {
            $Script:InsulinData.Metadata.Dataset | Should -Be 'insulin'
        }
        
        It 'Should have insulin data records' {
            $Script:InsulinData.Data.Count | Should -BeGreaterThan 0
        }
        
        It 'Should have expected insulin columns' {
            $Script:InsulinData.Data[0].PSObject.Properties.Name | Should -Contain 'Timestamp'
            $Script:InsulinData.Data[0].PSObject.Properties.Name | Should -Contain 'Insulin Type'
            $Script:InsulinData.Data[0].PSObject.Properties.Name | Should -Contain 'Dose (units)'
            $Script:InsulinData.Data[0].PSObject.Properties.Name | Should -Contain 'Method'
        }
    }
    
    Context 'Folder import with all mock data' {
        
        BeforeAll {
            $Script:AllMockData = Import-GlookoFolder -Path $Script:MockDataPath
        }
        
        It 'Should import all mock data files' {
            $Script:AllMockData.Count | Should -BeGreaterThan 4
        }
        
        It 'Should have CGM dataset' {
            $cgmDataset = $Script:AllMockData | Where-Object { $_.Metadata.Dataset -eq 'cgm' }
            $cgmDataset | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have insulin dataset' {
            $insulinDataset = $Script:AllMockData | Where-Object { $_.Metadata.Dataset -eq 'insulin' }
            $insulinDataset | Should -Not -BeNullOrEmpty
        }
        
        It 'Should have alarms dataset' {
            $alarmsDataset = $Script:AllMockData | Where-Object { $_.Metadata.Dataset -eq 'alarms' }
            $alarmsDataset | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Get-GlookoDataset filtering with mock data' {
        
        BeforeAll {
            $Script:AllMockData = Import-GlookoFolder -Path $Script:MockDataPath
        }
        
        It 'Should filter CGM data correctly' {
            $cgmData = $Script:AllMockData | Get-GlookoDataset -Name 'cgm'
            $cgmData.Count | Should -BeGreaterThan 0
        }
        
        It 'Should filter insulin data correctly' {
            $insulinData = $Script:AllMockData | Get-GlookoDataset -Name 'insulin'
            $insulinData.Count | Should -BeGreaterThan 0
        }
        
        It 'Should filter alarms data correctly' {
            $alarmsData = $Script:AllMockData | Get-GlookoDataset -Name 'alarms'
            $alarmsData.Count | Should -BeGreaterThan 0
        }
    }
}
