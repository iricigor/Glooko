# Glooko

## Import-GlookoCSV Function

The `Import-GlookoCSV` function is a PowerShell advanced function that imports data from CSV files while automatically skipping the first row. This is particularly useful when working with CSV files where the first row contains metadata, comments, or headers that differ from the actual column structure.

### Features

- **Skip First Row**: Automatically skips the first line of the CSV file
- **Flexible Headers**: Use the second row as headers or provide custom column names
- **Multiple Delimiters**: Support for comma, semicolon, or any custom delimiter
- **Encoding Support**: Configurable file encoding (default: UTF8)
- **Pipeline Support**: Accepts pipeline input for batch processing
- **Error Handling**: Comprehensive validation and error reporting
- **Verbose Logging**: Detailed progress information when using `-Verbose`

### Usage

```powershell
# Basic usage - skip first row, use second row as headers
Import-GlookoCSV -Path "data.csv"

# Use custom headers
Import-GlookoCSV -Path "data.csv" -Header "Name","Age","City"

# Different delimiter and encoding
Import-GlookoCSV -Path "data.csv" -Delimiter ";" -Encoding UTF8

# Pipeline usage
Get-ChildItem *.csv | Import-GlookoCSV
```

### Parameters

- **Path** (Mandatory): The path to the CSV file to import
- **Delimiter** (Optional): The delimiter used in the CSV file (default: ",")
- **Encoding** (Optional): The encoding of the CSV file (default: "UTF8")
- **Header** (Optional): Custom header names for the columns

### Examples

**Example 1**: Basic import with automatic header detection
```powershell
$data = Import-GlookoCSV -Path "C:\data\sales.csv"
```

**Example 2**: Import with custom headers
```powershell
$data = Import-GlookoCSV -Path "C:\data\sales.csv" -Header "Product","Quantity","Revenue"
```

**Example 3**: Import semicolon-delimited file
```powershell
$data = Import-GlookoCSV -Path "C:\data\european.csv" -Delimiter ";"
```