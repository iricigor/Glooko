BeforeAll {
    # Import the module being tested
    $ModulePath = Join-Path $PSScriptRoot '..' '..' 'Glooko.psd1'
    Import-Module $ModulePath -Force
    
    # Import Private functions for direct testing
    . (Join-Path $PSScriptRoot '..' '..' 'Private' 'Merge-GlookoDatasets.ps1')
    . (Join-Path $PSScriptRoot '..' '..' 'Private' 'Expand-GlookoMetadata.ps1')
}

AfterAll {
    # Remove the module
    Remove-Module Glooko -Force -ErrorAction SilentlyContinue
}

Describe 'Merge-GlookoDatasets' {
    
    Context 'Basic merging functionality' {
        
        It 'Should merge datasets with same Dataset and OriginalFirstLine' {
            $data1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data1.csv'
                    Dataset = 'cgm'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @(
                    [PSCustomObject]@{ Time = '2025-01-01'; Value = 100 }
                )
            }
            
            $data2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data2.csv'
                    Dataset = 'cgm'
                    Order = 2
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @(
                    [PSCustomObject]@{ Time = '2025-01-02'; Value = 105 }
                )
            }
            
            $result = Merge-GlookoDatasets -ImportedData @($data1, $data2)
            
            $result | Should -HaveCount 1
            $result[0].Metadata.FullName | Should -Be 'cgm_data1.csv'
            $result[0].Metadata.Order | Should -Be 1
            $result[0].Data | Should -HaveCount 2
            $result[0].Data[0].Value | Should -Be 100
            $result[0].Data[1].Value | Should -Be 105
        }
        
        It 'Should not merge datasets with different Dataset values' {
            $data1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data1.csv'
                    Dataset = 'cgm'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Time = '2025-01-01'; Value = 100 })
            }
            
            $data2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'alarms_data1.csv'
                    Dataset = 'alarms'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Time = '2025-01-01'; Alarm = 'low' })
            }
            
            $result = Merge-GlookoDatasets -ImportedData @($data1, $data2)
            
            $result | Should -HaveCount 2
        }
        
        It 'Should not merge datasets with different OriginalFirstLine values' {
            $data1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data1.csv'
                    Dataset = 'cgm'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Time = '2025-01-01'; Value = 100 })
            }
            
            $data2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data2.csv'
                    Dataset = 'cgm'
                    Order = 2
                    OriginalFirstLine = 'Name:Jane Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Time = '2025-01-01'; Value = 105 })
            }
            
            $result = Merge-GlookoDatasets -ImportedData @($data1, $data2)
            
            $result | Should -HaveCount 2
        }
        
        It 'Should handle single dataset without merging' {
            $data1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data1.csv'
                    Dataset = 'cgm'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Time = '2025-01-01'; Value = 100 })
            }
            
            $result = Merge-GlookoDatasets -ImportedData @($data1)
            
            $result | Should -HaveCount 1
            $result[0] | Should -Be $data1
        }
        
        It 'Should handle empty input array' {
            $result = Merge-GlookoDatasets -ImportedData @()
            
            $result | Should -BeNullOrEmpty
        }
    }
    
    Context 'Order-based merging' {
        
        It 'Should merge datasets in ascending Order' {
            $data2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data2.csv'
                    Dataset = 'cgm'
                    Order = 2
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Value = 'Second' })
            }
            
            $data1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data1.csv'
                    Dataset = 'cgm'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Value = 'First' })
            }
            
            $data3 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data3.csv'
                    Dataset = 'cgm'
                    Order = 3
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Value = 'Third' })
            }
            
            # Pass in non-sorted order
            $result = Merge-GlookoDatasets -ImportedData @($data2, $data1, $data3)
            
            $result | Should -HaveCount 1
            $result[0].Data | Should -HaveCount 3
            $result[0].Data[0].Value | Should -Be 'First'
            $result[0].Data[1].Value | Should -Be 'Second'
            $result[0].Data[2].Value | Should -Be 'Third'
        }
        
        It 'Should use metadata from lowest Order file' {
            $data2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data2.csv'
                    Dataset = 'cgm'
                    Order = 2
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Value = 'Second' })
            }
            
            $data1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data1.csv'
                    Dataset = 'cgm'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Value = 'First' })
            }
            
            # Pass in non-sorted order
            $result = Merge-GlookoDatasets -ImportedData @($data2, $data1)
            
            $result[0].Metadata.FullName | Should -Be 'cgm_data1.csv'
            $result[0].Metadata.Order | Should -Be 1
        }
    }
    
    Context 'Edge cases' {
        
        It 'Should handle null Dataset values' {
            $data1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'file1.csv'
                    Dataset = $null
                    Order = $null
                    OriginalFirstLine = 'Some metadata'
                }
                Data = @([PSCustomObject]@{ Value = 1 })
            }
            
            $data2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'file2.csv'
                    Dataset = $null
                    Order = $null
                    OriginalFirstLine = 'Some metadata'
                }
                Data = @([PSCustomObject]@{ Value = 2 })
            }
            
            $result = Merge-GlookoDatasets -ImportedData @($data1, $data2)
            
            # Should merge as both have same Dataset (null) and OriginalFirstLine
            $result | Should -HaveCount 1
            $result[0].Data | Should -HaveCount 2
        }
        
        It 'Should handle null Order values' {
            $data1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'file1.csv'
                    Dataset = 'test'
                    Order = $null
                    OriginalFirstLine = 'Some metadata'
                }
                Data = @([PSCustomObject]@{ Value = 1 })
            }
            
            $data2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'file2.csv'
                    Dataset = 'test'
                    Order = 1
                    OriginalFirstLine = 'Some metadata'
                }
                Data = @([PSCustomObject]@{ Value = 2 })
            }
            
            $result = Merge-GlookoDatasets -ImportedData @($data1, $data2)
            
            $result | Should -HaveCount 1
            # Null sorts before numbers, so file1 should be first
            $result[0].Metadata.FullName | Should -Be 'file1.csv'
        }
        
        It 'Should handle empty Data arrays' {
            $data1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data1.csv'
                    Dataset = 'cgm'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @()
            }
            
            $data2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data2.csv'
                    Dataset = 'cgm'
                    Order = 2
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Value = 100 })
            }
            
            $result = Merge-GlookoDatasets -ImportedData @($data1, $data2)
            
            $result | Should -HaveCount 1
            $result[0].Data | Should -HaveCount 1
        }
    }
    
    Context 'Complex scenarios' {
        
        It 'Should handle multiple groups requiring different merge strategies' {
            # Group 1: cgm data - should merge
            $cgm1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data1.csv'
                    Dataset = 'cgm'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Value = 100 })
            }
            
            $cgm2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'cgm_data2.csv'
                    Dataset = 'cgm'
                    Order = 2
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Value = 105 })
            }
            
            # Group 2: alarm data - should merge
            $alarm1 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'alarms_data1.csv'
                    Dataset = 'alarms'
                    Order = 1
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Alarm = 'low' })
            }
            
            $alarm2 = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'alarms_data2.csv'
                    Dataset = 'alarms'
                    Order = 2
                    OriginalFirstLine = 'Name:John Doe, Date Range:2025-01-01 - 2025-01-31'
                }
                Data = @([PSCustomObject]@{ Alarm = 'high' })
            }
            
            # Standalone file - should not merge
            $standalone = [PSCustomObject]@{
                Metadata = [PSCustomObject]@{
                    FullName = 'other.csv'
                    Dataset = 'other'
                    Order = 1
                    OriginalFirstLine = 'Different metadata'
                }
                Data = @([PSCustomObject]@{ Other = 'data' })
            }
            
            $result = Merge-GlookoDatasets -ImportedData @($cgm1, $cgm2, $alarm1, $alarm2, $standalone)
            
            # Should have 3 results: merged cgm, merged alarms, standalone
            $result | Should -HaveCount 3
            
            $cgmResult = $result | Where-Object { $_.Metadata.Dataset -eq 'cgm' }
            $cgmResult.Data | Should -HaveCount 2
            
            $alarmResult = $result | Where-Object { $_.Metadata.Dataset -eq 'alarms' }
            $alarmResult.Data | Should -HaveCount 2
            
            $otherResult = $result | Where-Object { $_.Metadata.Dataset -eq 'other' }
            $otherResult.Data | Should -HaveCount 1
        }
    }
}
