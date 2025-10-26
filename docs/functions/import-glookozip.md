# Import-GlookoZip Function

The `Import-GlookoZip` function is a PowerShell advanced function that imports data from a Glooko zip file by extracting and processing CSV files. This function automates the manual process of unzipping and importing Glooko export data.

## Features

- **Automated Extraction**: Automatically extracts zip files to a temporary folder
- **Automatic Cleanup**: Removes temporary files after processing
- **Batch Processing**: Processes all CSV files found in the extracted zip
- **Dataset Consolidation**: Automatically merges datasets with matching metadata (via `Import-GlookoFolder`)
- **Pipeline Support**: Accepts pipeline input for flexible usage
- **Error Handling**: Comprehensive validation and error reporting
- **Verbose Logging**: Detailed progress information when using `-Verbose`
- **Safe File Operations**: Ensures temporary folders are cleaned up even if errors occur

## Usage

```powershell
# Basic usage - import a Glooko zip file
Import-GlookoZip -Path "C:\data\export.zip"

# Pipeline usage
"C:\data\export.zip" | Import-GlookoZip

# With verbose output
Import-GlookoZip -Path "C:\data\export.zip" -Verbose
```

## Parameters

- **Path** (Mandatory): The path to the zip file to import. Must be a file with a `.zip` extension. Supports pipeline input and validation.

## Examples

**Example 1**: Basic import of a Glooko zip file
```powershell
$results = Import-GlookoZip -Path "C:\data\glooko_export.zip"
```

**Example 2**: Pipeline processing of a zip file
```powershell
$allData = "C:\data\glooko_export.zip" | Import-GlookoZip
```

**Example 3**: Import with verbose output for troubleshooting
```powershell
$results = Import-GlookoZip -Path "C:\data\glooko_export.zip" -Verbose
```

**Example 4**: Working with imported data
```powershell
$results = Import-GlookoZip -Path "C:\data\glooko_export.zip"
foreach ($dataset in $results) {
    Write-Host "Dataset: $($dataset.Metadata.Dataset)"
    Write-Host "  Total rows: $($dataset.Data.Count)"
    # Process $dataset.Data
}
```

**Example 5**: Processing multiple zip files
```powershell
# Import multiple zip files from a folder
$zipFiles = Get-ChildItem -Path "C:\data\exports" -Filter "*.zip"
$allResults = $zipFiles | ForEach-Object {
    Write-Host "Processing: $($_.Name)"
    Import-GlookoZip -Path $_.FullName
}
```

**Example 6**: Checking what's in a zip before full processing
```powershell
# Get a summary of what's in the zip
$results = Import-GlookoZip -Path "C:\data\export.zip"
$results | ForEach-Object {
    Write-Host "Dataset: $($_.Metadata.Dataset)"
    Write-Host "  File: $($_.Metadata.FullName)"
    Write-Host "  Date Range: $($_.Metadata.DateRange)"
    Write-Host "  Rows: $($_.Data.Count)"
}
```

## Output

Returns an array of objects (same format as `Import-GlookoFolder`), where each object contains:
- **Metadata**: Information about the source CSV file (from `Import-GlookoCSV`)
- **Data**: The CSV data from the file (from `Import-GlookoCSV`)

### Dataset Consolidation

The function uses `Import-GlookoFolder` internally, which means:
- Multiple CSV files with matching `Dataset` and `OriginalFirstLine` metadata are automatically consolidated
- Data is merged in ascending `Order` (based on filename pattern like `dataset_data_1.csv`, `dataset_data_2.csv`, etc.)
- Metadata is taken from the file with the lowest `Order` value
- Files with different `Dataset` or `OriginalFirstLine` values remain separate

**Example**: If a zip file contains:
- `cgm_data_1.csv` (3 rows)
- `cgm_data_2.csv` (2 rows)  
- `cgm_data_3.csv` (2 rows)

All with the same first line: `Name:John Doe, Date Range:2024-06-01 - 2024-06-30`

The result will be a single object with:
- Metadata from `cgm_data_1.csv` (Order=1)
- Combined Data array with 7 rows (3 from file 1, 2 from file 2, 2 from file 3)

## How It Works

1. **Validation**: Verifies the path exists and is a `.zip` file
2. **Extraction**: Creates a temporary folder with a unique GUID name
3. **Extract**: Uses `Expand-Archive` to extract all zip contents to the temporary folder
4. **Import**: Calls `Import-GlookoFolder` to process all CSV files in the extracted folder
5. **Cleanup**: Removes the temporary folder and all extracted files
6. **Return**: Returns the processed data

The cleanup happens even if an error occurs during processing, ensuring no temporary files are left behind.

## Related Functions

- **Import-GlookoFolder**: Used internally to process all CSV files from the extracted zip folder. See [Import-GlookoFolder documentation](import-glookofolder.md) for details.
- **Import-GlookoCSV**: Used by `Import-GlookoFolder` to process individual CSV files. See [Import-GlookoCSV documentation](import-glookocsv.md) for details.

## Error Handling

The function validates:
- The file exists
- The file has a `.zip` extension
- The file is not a folder

Common error messages:
- `File not found: <path>` - The specified zip file does not exist
- `File must have .zip extension: <path>` - The file is not a zip file
- `Error processing zip file: <message>` - An error occurred during extraction or processing

## Performance Notes

- Temporary folder is created in the system temp directory
- Cleanup is guaranteed via try/finally block
- Large zip files may take longer to extract
- Performance depends on the number and size of CSV files in the zip
