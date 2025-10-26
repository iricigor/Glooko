# Import-GlookoFolder Function

The `Import-GlookoFolder` function is a PowerShell advanced function that imports all CSV files from a specified folder. This function uses `Import-GlookoCSV` internally to process each CSV file, making it ideal for batch processing multiple Glooko export files.

## Features

- **Batch Processing**: Automatically processes all CSV files in a folder
- **Dataset Consolidation**: Automatically merges datasets with matching `Dataset` and `OriginalFirstLine` metadata
- **Order-Based Merging**: Consolidates data in ascending Order (e.g., file_data_1.csv, file_data_2.csv, etc.)
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

**Example 4**: Working with consolidated datasets
```powershell
$results = Import-GlookoFolder -Path "C:\data\exports"
foreach ($dataset in $results) {
    Write-Host "Dataset: $($dataset.Metadata.Dataset)"
    Write-Host "  Files: $($dataset.Metadata.FullName) (Order: $($dataset.Metadata.Order))"
    Write-Host "  Total rows: $($dataset.Data.Count)"
    # Process $dataset.Data
}
```

**Example 5**: Process each file's data individually (before consolidation)
```powershell
# If you need to process files individually without consolidation,
# use Get-ChildItem and Import-GlookoCSV directly
$csvFiles = Get-ChildItem -Path "C:\data\exports" -Filter "*.csv"
foreach ($file in $csvFiles) {
    $fileResult = Import-GlookoCSV -Path $file.FullName
    Write-Host "Processing file: $($file.Name)"
    # Process $fileResult.Data
}
```

## Output

Returns an array of objects, where each object contains:
- **Metadata**: Information about the source file (from `Import-GlookoCSV`)
- **Data**: The CSV data from the file (from `Import-GlookoCSV`)

### Dataset Consolidation

When multiple CSV files have matching `Dataset` and `OriginalFirstLine` metadata values, they are automatically consolidated:
- Data is merged in ascending `Order` (based on filename pattern like `dataset_data_1.csv`, `dataset_data_2.csv`, etc.)
- Metadata is taken from the file with the lowest `Order` value
- Files with different `Dataset` or `OriginalFirstLine` values remain separate

**Example**: If a folder contains:
- `cgm_data_1.csv` (3 rows)
- `cgm_data_2.csv` (2 rows)  
- `cgm_data_3.csv` (2 rows)

All with the same first line: `Name:John Doe, Date Range:2025-01-01 - 2025-01-31`

The result will be a single object with:
- Metadata from `cgm_data_1.csv` (Order=1)
- Combined Data array with 7 rows (3 from file 1, 2 from file 2, 2 from file 3)

## Related Functions

- **Import-GlookoCSV**: Used internally to process individual CSV files. See [Import-GlookoCSV documentation](import-glookocsv.md) for details on how individual files are processed.
