# Get-GlookoDataset Function

The `Get-GlookoDataset` function is a PowerShell advanced function that filters Glooko datasets by name and returns their data. This function simplifies working with specific dataset types from Glooko exports by extracting just the data you need.

## Features

- **Simple Filtering**: Filter datasets by exact name match
- **Data Extraction**: Returns only the Data property, removing the metadata wrapper
- **Pipeline Support**: Accepts pipeline input from Import-GlookoFolder, Import-GlookoZip, or Import-GlookoCSV
- **Case-Insensitive**: Matching is case-insensitive for convenience
- **Multiple Dataset Support**: Combines data from multiple datasets with the same name
- **Fallback Matching**: Uses FullName (filename) when Dataset property is not available
- **Error Handling**: Provides clear warnings when no matches are found
- **Verbose Logging**: Detailed progress information when using `-Verbose`

## Usage

```powershell
# Filter datasets by name
Import-GlookoFolder -Path "C:\data\exports" | Get-GlookoDataset -Name "cgm"

# Using parameter name
$datasets = Import-GlookoZip -Path "C:\data\export.zip"
$cgmData = Get-GlookoDataset -InputObject $datasets -Name "cgm"

# Case-insensitive matching
Import-GlookoFolder -Path "C:\data" | Get-GlookoDataset -Name "ALARMS"
```

## Parameters

- **InputObject** (Mandatory): Array of Glooko.Dataset objects to filter. Accepts pipeline input.
- **Name** (Mandatory, Position 0): The name of the dataset to retrieve. Uses exact matching (case-insensitive). Matches against the Dataset property in Metadata (e.g., 'cgm', 'alarms'). If Dataset is not available, matches against FullName (filename).

## Examples

**Example 1**: Get CGM data from a folder of exports
```powershell
$cgmData = Import-GlookoFolder -Path "C:\data\exports" | Get-GlookoDataset -Name "cgm"

# Now $cgmData contains just the data records, not the metadata wrapper
$cgmData | Select-Object -First 5 | Format-Table
```

**Example 2**: Get alarm data from a zip file
```powershell
$datasets = Import-GlookoZip -Path "C:\data\export.zip"
$alarmData = Get-GlookoDataset -InputObject $datasets -Name "alarms"

# Process the alarm data
$alarmData | Where-Object { $_.Alarm -eq 'High' } | Measure-Object
```

**Example 3**: Work with insulin data
```powershell
$insulinData = Import-GlookoFolder -Path "C:\data" | Get-GlookoDataset -Name "insulin"

# Calculate total insulin
$totalInsulin = ($insulinData | Measure-Object -Property Dose -Sum).Sum
Write-Host "Total insulin delivered: $totalInsulin units"
```

**Example 4**: Handle cases where dataset name is not found
```powershell
# Will display a warning and return empty array if no match
$data = Import-GlookoFolder -Path "C:\data" | Get-GlookoDataset -Name "nonexistent"

if ($data.Count -eq 0) {
    Write-Host "No data found for the specified dataset"
}
```

**Example 5**: Get data using filename when Dataset property is not available
```powershell
# For files that don't follow the naming pattern (e.g., no Dataset property)
$data = Import-GlookoCSV -Path "C:\data\myfile.csv" | Get-GlookoDataset -Name "myfile.csv"
```

**Example 6**: Combine with other PowerShell cmdlets
```powershell
# Get CGM data and export to CSV
Import-GlookoFolder -Path "C:\data" | 
    Get-GlookoDataset -Name "cgm" | 
    Export-Csv -Path "C:\output\cgm-only.csv" -NoTypeInformation

# Get CGM data and calculate statistics
$cgmData = Import-GlookoZip -Path "C:\data\export.zip" | Get-GlookoDataset -Name "cgm"
$stats = $cgmData | Measure-Object -Property Value -Average -Minimum -Maximum
Write-Host "Average glucose: $($stats.Average) mmol/L"
Write-Host "Min: $($stats.Minimum), Max: $($stats.Maximum)"
```

## Output

Returns an array of CSV data objects from the matching dataset(s). The metadata wrapper is removed, so you get direct access to the data records.

If the dataset contains 3 CGM readings, for example, you'll get an array of 3 objects with properties like Timestamp, Value, Unit, etc.

### Multiple Datasets with Same Name

If multiple datasets have the same name (which can happen after consolidation by Import-GlookoFolder), the function combines all their data into a single array:

```powershell
# If folder contains cgm_data_1.csv and cgm_data_2.csv (both with Dataset='cgm')
# Get-GlookoDataset will return data from both files combined
$allCgmData = Import-GlookoFolder -Path "C:\data" | Get-GlookoDataset -Name "cgm"
```

## Exact Matching

The function uses exact, case-insensitive matching. Wildcard patterns are not supported:

```powershell
# This will match datasets named exactly "cgm"
Get-GlookoDataset -Name "cgm"  # ✓ Matches 'cgm', 'CGM', 'Cgm'

# This will NOT work - it looks for a dataset literally named "*alarm*"
Get-GlookoDataset -Name "*alarm*"  # ✗ No wildcard support

# To get different datasets, call the function multiple times
$cgmData = $datasets | Get-GlookoDataset -Name "cgm"
$alarmData = $datasets | Get-GlookoDataset -Name "alarms"
$insulinData = $datasets | Get-GlookoDataset -Name "insulin"
```

## Common Workflow

Here's a typical workflow using Get-GlookoDataset:

```powershell
# 1. Import all datasets from a Glooko export
$datasets = Import-GlookoZip -Path "C:\data\glooko-export.zip"

# 2. Extract specific datasets
$cgmData = $datasets | Get-GlookoDataset -Name "cgm"
$alarmData = $datasets | Get-GlookoDataset -Name "alarms"
$insulinData = $datasets | Get-GlookoDataset -Name "insulin"

# 3. Analyze the data
$highGlucose = $cgmData | Where-Object { $_.Value -gt 10.0 }
Write-Host "High glucose readings: $($highGlucose.Count)"

$lowAlarms = $alarmData | Where-Object { $_.Alarm -eq 'Low' }
Write-Host "Low alarms: $($lowAlarms.Count)"

# 4. Export results
$cgmData | Export-Csv -Path "C:\output\cgm.csv" -NoTypeInformation
```

## Related Functions

- **Import-GlookoFolder**: Imports all CSV files from a folder. See [Import-GlookoFolder documentation](import-glookofolder.md).
- **Import-GlookoZip**: Imports data from a Glooko zip file. See [Import-GlookoZip documentation](import-glookozip.md).
- **Import-GlookoCSV**: Imports individual CSV files. See [Import-GlookoCSV documentation](import-glookocsv.md).
