# Export-GlookoZipToXlsx Function

The `Export-GlookoZipToXlsx` function is a PowerShell advanced function that converts a Glooko zip file to an Excel (XLSX) file. Each dataset is exported to a separate worksheet, making it easy to analyze the data in Excel.

## Features

- **Automated Conversion**: Automatically imports from ZIP and exports to Excel format
- **Multiple Worksheets**: Each dataset gets its own worksheet/tab in the Excel file
- **Automatic Naming**: Output file uses the same name as the ZIP file (with .xlsx extension)
- **Smart Overwrite Handling**: When file exists, creates timestamped version unless -Force is specified
- **Custom Output Path**: Optionally specify a custom location for the XLSX file
- **Formatted Tables**: Data is exported as Excel tables with formatting (Medium2 style)
- **Auto-sizing Columns**: Columns are automatically sized for readability (when supported)
- **Dataset Consolidation**: Leverages `Import-GlookoZip` to consolidate multiple files with matching metadata
- **Pipeline Support**: Accepts pipeline input for flexible usage
- **Error Handling**: Comprehensive validation and error reporting
- **Verbose Logging**: Detailed progress information when using `-Verbose`

## Prerequisites

This function requires the **ImportExcel** PowerShell module to be installed. This module provides Excel file creation without requiring Microsoft Excel to be installed.

### Installing ImportExcel

```powershell
# Install from PowerShell Gallery (recommended)
Install-Module -Name ImportExcel -Scope CurrentUser

# Or clone from GitHub
git clone https://github.com/dfinke/ImportExcel.git
Import-Module ./ImportExcel/ImportExcel.psd1
```

For more information about ImportExcel, visit: https://github.com/dfinke/ImportExcel

## Usage

```powershell
# Basic usage - convert ZIP to XLSX in the same folder
Export-GlookoZipToXlsx -Path "C:\data\export.zip"
# Creates: C:\data\export.xlsx
# If file exists, creates: C:\data\export_311225_143022.xlsx (with timestamp)

# Force overwrite of existing file
Export-GlookoZipToXlsx -Path "C:\data\export.zip" -Force
# Always creates: C:\data\export.xlsx (overwrites if exists)

# Specify custom output path
Export-GlookoZipToXlsx -Path "C:\data\export.zip" -OutputPath "C:\reports\mydata.xlsx"

# Pipeline usage
"C:\data\export.zip" | Export-GlookoZipToXlsx

# With verbose output
Export-GlookoZipToXlsx -Path "C:\data\export.zip" -Verbose
```

## Parameters

- **Path** (Mandatory): The path to the zip file to convert. Must be a file with a `.zip` extension. Supports pipeline input and validation.

- **OutputPath** (Optional): The full path for the output XLSX file. If not specified, the XLSX file will be created in the same folder as the ZIP file with the same name but `.xlsx` extension.

- **Force** (Optional): Switch parameter. If specified, overwrites the existing XLSX file if it exists. If not specified and the file exists, a timestamp will be appended to the filename (e.g., export_311225_143022.xlsx).

## Examples

**Example 1**: Convert a Glooko zip file to Excel
```powershell
$result = Export-GlookoZipToXlsx -Path "C:\data\glooko_export.zip"
Write-Host "Created: $($result.FullName)"
# Output: Created: C:\data\glooko_export.xlsx
```

**Example 2**: Specify a custom output location
```powershell
Export-GlookoZipToXlsx -Path "C:\data\export.zip" -OutputPath "D:\reports\analysis.xlsx"
```

**Example 3**: Pipeline processing of multiple zip files
```powershell
Get-ChildItem -Path "C:\data\exports" -Filter "*.zip" | ForEach-Object {
    Write-Host "Converting: $($_.Name)"
    Export-GlookoZipToXlsx -Path $_.FullName
}
```

**Example 4**: Convert and open the file in Excel
```powershell
$result = Export-GlookoZipToXlsx -Path "C:\data\export.zip"
Invoke-Item $result.FullName  # Opens the XLSX file in Excel
```

**Example 5**: Force overwrite of existing file
```powershell
# First run creates the file
Export-GlookoZipToXlsx -Path "C:\data\export.zip"

# Second run with -Force overwrites the original file
Export-GlookoZipToXlsx -Path "C:\data\export.zip" -Force
# Result: C:\data\export.xlsx (overwritten)

# Without -Force, creates timestamped file
Export-GlookoZipToXlsx -Path "C:\data\export.zip"
# Result: C:\data\export_311225_143530.xlsx (new file with timestamp)
```

**Example 6**: Process with verbose output
```powershell
Export-GlookoZipToXlsx -Path "C:\data\export.zip" -Verbose
# Shows detailed progress:
# VERBOSE: Starting Export-GlookoZipToXlsx function
# VERBOSE: Processing zip file: C:\data\export.zip
# VERBOSE: Importing data from zip file
# VERBOSE: Found 2 dataset(s) to export
# VERBOSE: Exporting dataset 'cgm' with 150 rows
# VERBOSE: Exporting dataset 'insulin' with 45 rows
# VERBOSE: Successfully created Excel file: C:\data\export.xlsx
```

**Example 6**: Batch conversion of all ZIP files in a folder
```powershell
$exportFolder = "C:\GlookoExports"
Get-ChildItem -Path $exportFolder -Filter "*.zip" | 
    Export-GlookoZipToXlsx

# All ZIP files are converted to XLSX in the same folder
```

## Output

Returns a `System.IO.FileInfo` object representing the created XLSX file. This object contains properties like:
- **FullName**: The complete path to the XLSX file
- **Name**: The filename with extension
- **Directory**: The directory containing the file
- **Length**: File size in bytes
- **Exists**: Boolean indicating if the file exists

## Worksheet Organization

The function creates one worksheet per dataset:

1. **Worksheet Names**: Based on the `Dataset` metadata property from the CSV filename
   - Example: `cgm_data_1.csv` → worksheet named "cgm"
   - If no dataset name is available, uses "Sheet1", "Sheet2", etc.
   
2. **Name Sanitization**: Excel worksheet names have constraints:
   - Maximum 31 characters (automatically truncated if longer)
   - Cannot contain: `\ / ? * [ ] :` (automatically replaced with `_`)

3. **Table Formatting**: Each worksheet contains:
   - Data formatted as an Excel table
   - Medium2 table style applied
   - Auto-sized columns (when supported by the system)
   - Header row from the CSV data

4. **Empty Datasets**: Worksheets with no data are skipped with a warning

### Example Worksheet Structure

If a ZIP file contains these CSV files:
- `cgm_data_1.csv` (100 rows)
- `cgm_data_2.csv` (50 rows)  
- `insulin_data_1.csv` (30 rows)

With matching metadata in cgm files, the resulting XLSX will have:
- **cgm** worksheet: 150 rows (consolidated from both cgm files)
- **insulin** worksheet: 30 rows

## How It Works

1. **Module Check**: Verifies ImportExcel module is available (either already loaded or can be loaded)
2. **Path Resolution**: Resolves the ZIP file path to an absolute path
3. **Output Path**: Determines the output XLSX path (default or custom)
4. **Import Data**: Uses `Import-GlookoZip` to extract and process all CSV files
5. **Dataset Processing**: Iterates through each consolidated dataset
6. **Worksheet Creation**: Creates a worksheet for each dataset with:
   - Sanitized worksheet name
   - Formatted Excel table
   - Auto-sized columns
7. **File Handling**: If the XLSX file already exists:
   - With `-Force`: Removes the existing file and creates a new one
   - Without `-Force`: Appends timestamp to filename and creates a new file (e.g., export_311225_143022.xlsx)
8. **Return**: Returns the FileInfo object for the created XLSX file

## Related Functions

- **Import-GlookoZip**: Used internally to import data from the ZIP file. See [Import-GlookoZip documentation](import-glookozip.md) for details.
- **Import-GlookoFolder**: Used by `Import-GlookoZip` to process all CSV files. See [Import-GlookoFolder documentation](import-glookofolder.md) for details.
- **Import-GlookoCSV**: Used to process individual CSV files. See [Import-GlookoCSV documentation](import-glookocsv.md) for details.

## Error Handling

The function validates:
- The file exists
- The file has a `.zip` extension
- The file is not a folder
- The ImportExcel module is available

Common error messages:
- `File not found: <path>` - The specified zip file does not exist
- `File must have .zip extension: <path>` - The file is not a zip file
- `ImportExcel module not found` - The ImportExcel module is not installed
- `No data found in zip file: <path>` - Warning when the ZIP contains no CSV files
- `Dataset '<name>' has no data, skipping` - Warning when a dataset has no rows

### Handling Missing ImportExcel Module

If the ImportExcel module is not installed, you'll receive a helpful error message:

```
The ImportExcel module is required but not installed.

To install it, run one of the following commands:
  Install-Module -Name ImportExcel -Scope CurrentUser
  
Or clone it from GitHub:
  git clone https://github.com/dfinke/ImportExcel.git
  Import-Module ./ImportExcel/ImportExcel.psd1

For more information, visit: https://github.com/dfinke/ImportExcel
```

## Performance Notes

- The function creates the entire XLSX file in memory before writing to disk
- Large datasets may require significant memory
- Auto-sizing columns can be slow for very large datasets
- By default, the function creates a new timestamped file if the output file exists
- Use `-Force` to overwrite existing files instead of creating timestamped versions
- Processing time depends on:
  - Number of datasets in the ZIP
  - Total number of rows across all datasets
  - System resources (CPU, memory, disk I/O)

## Limitations

- Requires ImportExcel module to be installed
- Excel worksheet names are limited to 31 characters
- Certain characters are not allowed in worksheet names
- Auto-sizing may not work on all operating systems (e.g., Linux without libgdiplus)
- Very large datasets may cause memory issues

## Tips

1. **Keep Worksheet Names Short**: If your dataset names are long, they will be truncated to 31 characters
2. **Check Dataset Names**: Use `Import-GlookoZip` first to see what datasets are in your ZIP
3. **Memory Usage**: For very large ZIP files, monitor memory usage during conversion
4. **Batch Processing**: When converting many files, consider doing them one at a time to avoid memory issues
5. **Verification**: After conversion, open the XLSX file to verify all data was exported correctly
6. **Prevent Overwrite**: By default, the function creates timestamped files to preserve existing exports. Use `-Force` only when you're sure you want to overwrite

## Troubleshooting

**Problem**: "Auto-fitting columns is not available with this OS configuration"  
**Solution**: This is a warning, not an error. The columns won't be auto-sized, but the data is still exported correctly. On Linux, install libgdiplus: `apt-get install -y libgdiplus libc6-dev`

**Problem**: Worksheet names are truncated or have underscores  
**Solution**: This is expected behavior for long names or names with special characters. Excel has strict naming requirements.

**Problem**: "No data found in zip file"  
**Solution**: The ZIP file doesn't contain any CSV files that match the Glooko format. Verify the ZIP contents.
