BeforeAll {
    # Import the Private function for direct testing
    . (Join-Path $PSScriptRoot '..' 'Private' 'ConvertTo-ExtendedMetadata.ps1')
}

Describe 'ConvertTo-ExtendedMetadata' {
    
    Context 'Filename parsing' {
        
        It 'Should parse valid dataset filename pattern' {
            $result = ConvertTo-ExtendedMetadata -FileName 'alarms_data_1.csv' -FirstLine 'Some metadata'
            
            $result.FullName | Should -Be 'alarms_data_1.csv'
            $result.Dataset | Should -Be 'alarms'
            $result.Order | Should -Be 1
        }
        
        It 'Should parse different dataset names and orders' {
            $result = ConvertTo-ExtendedMetadata -FileName 'glucose_data_5.csv' -FirstLine 'Some metadata'
            
            $result.Dataset | Should -Be 'glucose'
            $result.Order | Should -Be 5
        }
        
        It 'Should handle complex dataset names' {
            $result = ConvertTo-ExtendedMetadata -FileName 'blood_pressure_data_10.csv' -FirstLine 'Some metadata'
            
            $result.Dataset | Should -Be 'blood_pressure'
            $result.Order | Should -Be 10
        }
        
        It 'Should return null for dataset/order when filename does not match pattern' {
            $result = ConvertTo-ExtendedMetadata -FileName 'random_file.csv' -FirstLine 'Some metadata'
            
            $result.FullName | Should -Be 'random_file.csv'
            $result.Dataset | Should -BeNullOrEmpty
            $result.Order | Should -BeNullOrEmpty
        }
        
        It 'Should return null for dataset/order when filename has wrong extension' {
            $result = ConvertTo-ExtendedMetadata -FileName 'alarms_data_1.txt' -FirstLine 'Some metadata'
            
            $result.FullName | Should -Be 'alarms_data_1.txt'
            $result.Dataset | Should -BeNullOrEmpty
            $result.Order | Should -BeNullOrEmpty
        }
    }
    
    Context 'First line parsing' {
        
        It 'Should parse valid name and date range format' {
            $result = ConvertTo-ExtendedMetadata -FileName 'test.csv' -FirstLine 'Name:John Doe, Date Range:2024-01-01 - 2024-12-31'
            
            $result.Name | Should -Be 'John Doe'
            $result.DateRange | Should -Be '2024-01-01 - 2024-12-31'
            $result.StartDate | Should -Be '2024-01-01'
            $result.EndDate | Should -Be '2024-12-31'
        }
        
        It 'Should handle Unicode characters in name' {
            $result = ConvertTo-ExtendedMetadata -FileName 'test.csv' -FirstLine 'Name:Igor Irić, Date Range:2025-05-31 - 2025-08-17'
            
            $result.Name | Should -Be 'Igor Irić'
            $result.DateRange | Should -Be '2025-05-31 - 2025-08-17'
            $result.StartDate | Should -Be '2025-05-31'
            $result.EndDate | Should -Be '2025-08-17'
        }
        
        It 'Should handle extra whitespace in first line' {
            $result = ConvertTo-ExtendedMetadata -FileName 'test.csv' -FirstLine 'Name:  Jane Smith  ,   Date Range:  2023-01-15 - 2023-12-20  '
            
            $result.Name | Should -Be 'Jane Smith'
            $result.DateRange | Should -Be '2023-01-15 - 2023-12-20'
            $result.StartDate | Should -Be '2023-01-15'
            $result.EndDate | Should -Be '2023-12-20'
        }
        
        It 'Should return null values when first line does not match expected format' {
            $result = ConvertTo-ExtendedMetadata -FileName 'test.csv' -FirstLine 'This is just random metadata'
            
            $result.Name | Should -BeNullOrEmpty
            $result.DateRange | Should -BeNullOrEmpty
            $result.StartDate | Should -BeNullOrEmpty
            $result.EndDate | Should -BeNullOrEmpty
            $result.OriginalFirstLine | Should -Be 'This is just random metadata'
        }
        
        It 'Should handle malformed date range in first line' {
            $result = ConvertTo-ExtendedMetadata -FileName 'test.csv' -FirstLine 'Name:Test User, Date Range:January to December'
            
            $result.Name | Should -Be 'Test User'
            $result.DateRange | Should -Be 'January to December'
            $result.StartDate | Should -BeNullOrEmpty
            $result.EndDate | Should -BeNullOrEmpty
        }
        
        It 'Should handle empty first line' {
            $result = ConvertTo-ExtendedMetadata -FileName 'test.csv' -FirstLine ''
            
            $result.Name | Should -BeNullOrEmpty
            $result.DateRange | Should -BeNullOrEmpty
            $result.StartDate | Should -BeNullOrEmpty
            $result.EndDate | Should -BeNullOrEmpty
            $result.OriginalFirstLine | Should -Be ''
        }
    }
    
    Context 'Combined parsing scenarios' {
        
        It 'Should parse both filename and first line successfully' {
            $result = ConvertTo-ExtendedMetadata -FileName 'glucose_data_3.csv' -FirstLine 'Name:Alice Johnson, Date Range:2024-06-01 - 2024-06-30'
            
            # Filename parsing
            $result.FullName | Should -Be 'glucose_data_3.csv'
            $result.Dataset | Should -Be 'glucose'
            $result.Order | Should -Be 3
            
            # First line parsing
            $result.Name | Should -Be 'Alice Johnson'
            $result.DateRange | Should -Be '2024-06-01 - 2024-06-30'
            $result.StartDate | Should -Be '2024-06-01'
            $result.EndDate | Should -Be '2024-06-30'
            $result.OriginalFirstLine | Should -Be 'Name:Alice Johnson, Date Range:2024-06-01 - 2024-06-30'
        }
        
        It 'Should handle filename pattern match with first line parsing failure' {
            $result = ConvertTo-ExtendedMetadata -FileName 'blood_data_7.csv' -FirstLine 'Random metadata here'
            
            # Filename parsing should work
            $result.FullName | Should -Be 'blood_data_7.csv'
            $result.Dataset | Should -Be 'blood'
            $result.Order | Should -Be 7
            
            # First line parsing should fail gracefully
            $result.Name | Should -BeNullOrEmpty
            $result.DateRange | Should -BeNullOrEmpty
            $result.StartDate | Should -BeNullOrEmpty
            $result.EndDate | Should -BeNullOrEmpty
            $result.OriginalFirstLine | Should -Be 'Random metadata here'
        }
        
        It 'Should handle filename pattern failure with first line parsing success' {
            $result = ConvertTo-ExtendedMetadata -FileName 'some_random_file.csv' -FirstLine 'Name:Bob Wilson, Date Range:2023-03-15 - 2023-09-20'
            
            # Filename parsing should fail gracefully
            $result.FullName | Should -Be 'some_random_file.csv'
            $result.Dataset | Should -BeNullOrEmpty
            $result.Order | Should -BeNullOrEmpty
            
            # First line parsing should work
            $result.Name | Should -Be 'Bob Wilson'
            $result.DateRange | Should -Be '2023-03-15 - 2023-09-20'
            $result.StartDate | Should -Be '2023-03-15'
            $result.EndDate | Should -Be '2023-09-20'
        }
        
        It 'Should handle both parsing failures gracefully' {
            $result = ConvertTo-ExtendedMetadata -FileName 'unknown_file.txt' -FirstLine 'Just some text'
            
            # All parsed fields should be null
            $result.FullName | Should -Be 'unknown_file.txt'
            $result.Dataset | Should -BeNullOrEmpty
            $result.Order | Should -BeNullOrEmpty
            $result.Name | Should -BeNullOrEmpty
            $result.DateRange | Should -BeNullOrEmpty
            $result.StartDate | Should -BeNullOrEmpty
            $result.EndDate | Should -BeNullOrEmpty
            $result.OriginalFirstLine | Should -Be 'Just some text'
        }
    }
    
    Context 'Object structure validation' {
        
        It 'Should always return PSCustomObject with all expected properties' {
            $result = ConvertTo-ExtendedMetadata -FileName 'test.csv' -FirstLine 'test'
            
            $result | Should -BeOfType [PSCustomObject]
            $result.PSObject.Properties.Name | Should -Contain 'FullName'
            $result.PSObject.Properties.Name | Should -Contain 'Dataset'
            $result.PSObject.Properties.Name | Should -Contain 'Order'
            $result.PSObject.Properties.Name | Should -Contain 'Name'
            $result.PSObject.Properties.Name | Should -Contain 'DateRange'
            $result.PSObject.Properties.Name | Should -Contain 'StartDate'
            $result.PSObject.Properties.Name | Should -Contain 'EndDate'
            $result.PSObject.Properties.Name | Should -Contain 'OriginalFirstLine'
        }
        
        It 'Should preserve original first line exactly as provided' {
            $originalLine = 'Name:Test User, Date Range:2024-01-01 - 2024-12-31'
            $result = ConvertTo-ExtendedMetadata -FileName 'test.csv' -FirstLine $originalLine
            
            $result.OriginalFirstLine | Should -Be $originalLine
        }
    }
    
    Context 'Edge cases and error conditions' {
        
        It 'Should handle very large order numbers' {
            $result = ConvertTo-ExtendedMetadata -FileName 'dataset_data_999999.csv' -FirstLine 'test'
            
            $result.Dataset | Should -Be 'dataset'
            $result.Order | Should -Be 999999
        }
        
        It 'Should handle zero as order number' {
            $result = ConvertTo-ExtendedMetadata -FileName 'dataset_data_0.csv' -FirstLine 'test'
            
            $result.Dataset | Should -Be 'dataset'
            $result.Order | Should -Be 0
        }
    }
}