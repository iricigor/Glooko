BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
}

AfterAll {
    # Remove the module
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Get-GlookoDataset' {
    
    BeforeAll {
        # Create test datasets that simulate Import-GlookoFolder output
        $Script:TestDatasets = @(
            [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data_1.csv'
                    Dataset = 'cgm'
                    Order = 1
                    Name = 'Test User'
                    DateRange = '2025-01-01 - 2025-01-31'
                    StartDate = '2025-01-01'
                    EndDate = '2025-01-31'
                    OriginalFirstLine = 'Name:Test User, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @(
                    [PSCustomObject]@{ Timestamp = '2025-01-01 10:00'; Value = 100; Unit = 'mg/dL' }
                    [PSCustomObject]@{ Timestamp = '2025-01-01 10:05'; Value = 105; Unit = 'mg/dL' }
                    [PSCustomObject]@{ Timestamp = '2025-01-01 10:10'; Value = 110; Unit = 'mg/dL' }
                )
            }
            [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'alarms_data_1.csv'
                    Dataset = 'alarms'
                    Order = 1
                    Name = 'Test User'
                    DateRange = '2025-01-01 - 2025-01-31'
                    StartDate = '2025-01-01'
                    EndDate = '2025-01-31'
                    OriginalFirstLine = 'Name:Test User, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @(
                    [PSCustomObject]@{ Timestamp = '2025-01-01 10:00'; Alarm = 'Low' }
                    [PSCustomObject]@{ Timestamp = '2025-01-01 15:00'; Alarm = 'High' }
                )
            }
            [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'insulin_data_1.csv'
                    Dataset = 'insulin'
                    Order = 1
                    Name = 'Test User'
                    DateRange = '2025-01-01 - 2025-01-31'
                    StartDate = '2025-01-01'
                    EndDate = '2025-01-31'
                    OriginalFirstLine = 'Name:Test User, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @(
                    [PSCustomObject]@{ Timestamp = '2025-01-01 08:00'; Dose = 10; Type = 'Basal' }
                )
            }
        )
        
        # Add Glooko.Dataset type to all test datasets
        $Script:TestDatasets | ForEach-Object {
            $_.PSObject.TypeNames.Insert(0, 'Glooko.Dataset')
        }
    }
    
    Context 'Basic functionality' {
        
        It 'Should return data from a specific dataset' {
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name 'cgm'
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 3
            $result[0].Value | Should -Be 100
            $result[1].Value | Should -Be 105
            $result[2].Value | Should -Be 110
        }
        
        It 'Should return data from alarms dataset' {
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name 'alarms'
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
            $result[0].Alarm | Should -Be 'Low'
            $result[1].Alarm | Should -Be 'High'
        }
        
        It 'Should return data from insulin dataset' {
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name 'insulin'
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 1
            $result[0].Dose | Should -Be 10
            $result[0].Type | Should -Be 'Basal'
        }
        
        It 'Should return empty array when no match found' {
            $warnings = @()
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name 'nonexistent' -WarningVariable warnings
            
            $result | Should -BeNullOrEmpty
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "No datasets found matching"
        }
    }
    
    Context 'Exact matching' {
        
        It 'Should use exact matching, not wildcards' {
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name '*alarm*'
            
            # Should not match anything since no dataset is literally named '*alarm*'
            $result | Should -BeNullOrEmpty
        }
        
        It 'Should match exact dataset name only' {
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name 'cgm'
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 3
        }
        
        It 'Should not match partial names' {
            # Create test data
            $partialDatasets = @(
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{ Dataset = 'cgm_test'; FullName = 'cgm_test.csv' }
                    Data = @([PSCustomObject]@{ Value = 1 })
                }
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{ Dataset = 'cgm'; FullName = 'cgm.csv' }
                    Data = @([PSCustomObject]@{ Value = 2 })
                }
            )
            
            $result = Get-GlookoDataset -InputObject $partialDatasets -Name 'cgm'
            
            # Should only match the exact 'cgm', not 'cgm_test'
            $result | Should -HaveCount 1
            $result[0].Value | Should -Be 2
        }
    }
    
    Context 'Pipeline support' {
        
        It 'Should accept pipeline input' {
            $result = $Script:TestDatasets | Get-GlookoDataset -Name 'cgm'
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 3
        }
        
        It 'Should work with Import-GlookoCSV output' {
            $testFile = Join-Path $PSScriptRoot 'Fixtures' 'test-data01.csv'
            $result = Import-GlookoCSV -Path $testFile | Get-GlookoDataset -Name 'test-data01.csv'
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 2
        }
        
        It 'Should work with Import-GlookoFolder output' {
            # Create a test folder with CGM files
            $tempFolder = Join-Path ([System.IO.Path]::GetTempPath()) "test-$(New-Guid)"
            New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null
            
            try {
                $cgmFile = Join-Path $tempFolder 'cgm_data_1.csv'
                @"
Name:Test User, Date Range:2025-01-01 - 2025-01-31
Timestamp,Value,Unit
2025-01-01 10:00,100,mg/dL
2025-01-01 10:05,105,mg/dL
"@ | Out-File -FilePath $cgmFile -Encoding UTF8
                
                $alarmsFile = Join-Path $tempFolder 'alarms_data_1.csv'
                @"
Name:Test User, Date Range:2025-01-01 - 2025-01-31
Timestamp,Alarm
2025-01-01 10:00,Low
"@ | Out-File -FilePath $alarmsFile -Encoding UTF8
                
                $result = Import-GlookoFolder -Path $tempFolder | Get-GlookoDataset -Name 'cgm'
                
                $result | Should -Not -BeNullOrEmpty
                $result | Should -HaveCount 2
                $result[0].Value | Should -Be 100
            } finally {
                if (Test-Path $tempFolder) {
                    Remove-Item $tempFolder -Recurse -Force
                }
            }
        }
    }
    
    Context 'Fallback to FullName when Dataset is not available' {
        
        It 'Should use FullName when Dataset property is null' {
            $datasetsWithoutDatasetName = @(
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{
                        FullName = 'myfile.csv'
                        Dataset = $null
                    }
                    Data = @([PSCustomObject]@{ Value = 'test' })
                }
            )
            
            $result = Get-GlookoDataset -InputObject $datasetsWithoutDatasetName -Name 'myfile.csv'
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 1
            $result[0].Value | Should -Be 'test'
        }
        
        It 'Should support exact matching on FullName' {
            $datasetsWithoutDatasetName = @(
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{
                        FullName = 'test-file-1.csv'
                        Dataset = $null
                    }
                    Data = @([PSCustomObject]@{ Value = 1 })
                }
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{
                        FullName = 'test-file-2.csv'
                        Dataset = $null
                    }
                    Data = @([PSCustomObject]@{ Value = 2 })
                }
            )
            
            $result = Get-GlookoDataset -InputObject $datasetsWithoutDatasetName -Name 'test-file-1.csv'
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 1
            $result[0].Value | Should -Be 1
        }
    }
    
    Context 'Edge cases' {
        
        It 'Should handle empty input array' {
            $warnings = @()
            $result = Get-GlookoDataset -InputObject @() -Name 'cgm' -WarningVariable warnings
            
            $result | Should -BeNullOrEmpty
            $warnings | Should -HaveCount 1
            $warnings[0] | Should -Match "No datasets provided"
        }
        
        It 'Should handle dataset with empty Data array' {
            $emptyDataset = @(
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{ Dataset = 'empty'; FullName = 'empty.csv' }
                    Data = @()
                }
            )
            
            $result = Get-GlookoDataset -InputObject $emptyDataset -Name 'empty'
            
            # Should return empty array but not null
            $result | Should -BeNullOrEmpty
        }
        
        It 'Should handle dataset with null Data property' {
            $nullDataset = @(
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{ Dataset = 'nulldata'; FullName = 'null.csv' }
                    Data = $null
                }
            )
            
            $result = Get-GlookoDataset -InputObject $nullDataset -Name 'nulldata'
            
            # Should not throw error
            $result | Should -BeNullOrEmpty
        }
        
        It 'Should be case-insensitive by default' {
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name 'CGM'
            
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 3
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should provide verbose output when requested' {
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name 'cgm' -Verbose
            
            # Verify the function still works correctly with verbose output
            $result | Should -Not -BeNullOrEmpty
            $result | Should -HaveCount 3
        }
    }
    
    Context 'Data integrity' {
        
        It 'Should return actual data objects, not copies' {
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name 'cgm'
            
            # Verify structure is preserved
            $result[0].PSObject.Properties.Name | Should -Contain 'Timestamp'
            $result[0].PSObject.Properties.Name | Should -Contain 'Value'
            $result[0].PSObject.Properties.Name | Should -Contain 'Unit'
        }
        
        It 'Should preserve data types' {
            $result = Get-GlookoDataset -InputObject $Script:TestDatasets -Name 'cgm'
            
            $result[0].Value | Should -BeOfType [int]
            $result[0].Timestamp | Should -BeOfType [string]
        }
    }
    
    Context 'Multiple datasets consolidation' {
        
        It 'Should combine data from multiple matching datasets' {
            # Create multiple datasets with the same name
            $multipleDatasets = @(
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{ Dataset = 'cgm'; FullName = 'cgm1.csv' }
                    Data = @(
                        [PSCustomObject]@{ Value = 100 }
                        [PSCustomObject]@{ Value = 105 }
                    )
                }
                [PSCustomObject]@{
                    Metadata = [PSCustomObject]@{ Dataset = 'cgm'; FullName = 'cgm2.csv' }
                    Data = @(
                        [PSCustomObject]@{ Value = 110 }
                    )
                }
            )
            
            $result = Get-GlookoDataset -InputObject $multipleDatasets -Name 'cgm'
            
            # Should combine data from both datasets
            $result | Should -HaveCount 3
            $result[0].Value | Should -Be 100
            $result[1].Value | Should -Be 105
            $result[2].Value | Should -Be 110
        }
    }
}
