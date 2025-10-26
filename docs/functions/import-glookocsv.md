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
