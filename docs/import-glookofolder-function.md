# Import-GlookoFolder Function

The `Import-GlookoFolder` function is a PowerShell advanced function that imports all CSV files from a specified folder. This function uses `Import-GlookoCSV` internally to process each CSV file, making it ideal for batch processing multiple Glooko export files.

## Features

- **Batch Processing**: Automatically processes all CSV files in a folder
- **Consistent Processing**: Uses `Import-GlookoCSV` for each file, ensuring consistent handling
- **Pipeline Support**: Accepts pipeline input for flexible usage
- **Error Handling**: Comprehensive validation and error reporting
- **Verbose Logging**: Detailed progress information when using `-Verbose`
- **Warning on Empty**: Warns when no CSV files are found in the folder

## Usage

```powershell
# Basic usage - import all CSV files from a folder
Import-GlookoFolder -Path "C:\data\exports"

# Pipeline usage
"C:\data\exports" | Import-GlookoFolder

# With verbose output
Import-GlookoFolder -Path "C:\data\exports" -Verbose
```

## Parameters

- **Path** (Mandatory): The path to the folder containing CSV files to import. Supports pipeline input and validation. Must be a valid directory path.

## Examples

**Example 1**: Basic import of all CSV files from a folder
```powershell
$results = Import-GlookoFolder -Path "C:\data\exports"
```

**Example 2**: Pipeline processing of folder path
```powershell
$allData = "C:\data\exports" | Import-GlookoFolder
```

**Example 3**: Import with verbose output for troubleshooting
```powershell
$results = Import-GlookoFolder -Path "C:\data\exports" -Verbose
```

**Example 4**: Process each file's data individually
```powershell
$results = Import-GlookoFolder -Path "C:\data\exports"
foreach ($fileResult in $results) {
    Write-Host "Processing file with metadata: $($fileResult.Metadata.FirstLine)"
    # Process $fileResult.Data
}
```

## Output

Returns an array of objects, where each object contains:
- **Metadata**: Information about the source file (from `Import-GlookoCSV`)
- **Data**: The CSV data from the file (from `Import-GlookoCSV`)

## Related Functions

- **Import-GlookoCSV**: Used internally to process individual CSV files. See [Import-GlookoCSV documentation](import-glookocsv-function.md) for details on how individual files are processed.
