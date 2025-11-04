# Import-GlookoCSV Function

The `Import-GlookoCSV` function is a PowerShell advanced function that imports data from CSV files while automatically skipping the first row. This is particularly useful when working with CSV files where the first row contains metadata, comments, or headers that differ from the actual column structure.

## Features

- **Skip First Row**: Automatically skips the first line of the CSV file
- **Automatic Headers**: Uses the second row as column headers
- **Fixed Delimiter**: Uses comma as delimiter
- **UTF8 Encoding**: Fixed UTF8 encoding for file reading
- **Pipeline Support**: Accepts pipeline input for batch processing
- **Error Handling**: Comprehensive validation and error reporting
- **Verbose Logging**: Detailed progress information when using `-Verbose`
- **Custom Type**: Returns objects with custom `Glooko.Dataset` type for enhanced formatting
- **Script Properties**: Provides `RecordCount` and `DatasetName` properties for easy access

## Usage

```powershell
# Basic usage - skip first row, use second row as headers
Import-GlookoCSV -Path "data.csv"

# Pipeline usage
Get-ChildItem *.csv | Import-GlookoCSV

# With verbose output
Import-GlookoCSV -Path "data.csv" -Verbose
```

## Parameters

- **Path** (Mandatory): The path to the CSV file to import. Supports pipeline input and validation.

## Examples

**Example 1**: Basic import with automatic header detection
```powershell
$data = Import-GlookoCSV -Path "C:\data\sales.csv"
```

**Example 2**: Pipeline processing of multiple CSV files
```powershell
$allData = Get-ChildItem "C:\data\*.csv" | Import-GlookoCSV
```

**Example 3**: Import with verbose output for troubleshooting
```powershell
$data = Import-GlookoCSV -Path "C:\data\sales.csv" -Verbose
```

## Output

The function returns a custom `Glooko.Dataset` object with the following structure:

- **Metadata**: Extended metadata parsed from the filename and first line
  - `FullName`: Original filename
  - `Dataset`: Dataset name (extracted from filename pattern `{dataset}_data_{order}.csv`)
  - `Order`: Order number (extracted from filename)
  - `Name`: Person's name (extracted from first line)
  - `DateRange`: Date range string (extracted from first line)
  - `StartDate`: Start date (parsed from date range)
  - `EndDate`: End date (parsed from date range)
  - `OriginalFirstLine`: Original first line content
- **Data**: Array of CSV records (each row as a PSCustomObject)
- **RecordCount** (Script Property): Number of data records
- **DatasetName** (Script Property): Dataset name or filename

### Custom Formatting

The `Glooko.Dataset` type includes custom formatting that displays:
- Dataset name
- Number of records
- Name and date range from metadata
- Filename
- Complete metadata object
- Data summary (count of records)

```powershell
# Example output
PS> Import-GlookoCSV -Path "test_data_1.csv"

Dataset   : test
Records   : 10
Name      : John Doe
DateRange : 2025-01-01 - 2025-01-31
FileName  : test_data_1.csv
Metadata  : @{FullName=test_data_1.csv; Dataset=test; Order=1; ...}
Data      : [10 records]
```
