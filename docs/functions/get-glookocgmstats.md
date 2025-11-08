# Get-GlookoCGMStats

## Synopsis
Analyzes CGM data and provides basic statistics grouped by date.

## Description
This function analyzes Continuous Glucose Monitoring (CGM) data and calculates statistics for readings that are in range, above range, and below range. Results are grouped by date and include both counts and percentages.

Default ranges (mmol/L):
- Below range: < 4.0 mmol/L (< 70 mg/dL)
- In range: 4.0-10.0 mmol/L (70-180 mg/dL)
- Above range: > 10.0 mmol/L (> 180 mg/dL)

## Parameters

### InputObject
CGM data to analyze. Accepts output from `Get-GlookoDataset` or `Import-GlookoCSV`. Expected to have 'Timestamp' and a glucose value column.

- **Type**: Array
- **Required**: Yes
- **Pipeline Input**: Yes

### LowThreshold
Lower threshold for target range in mmol/L. Default is 4.0.

- **Type**: Double
- **Required**: No
- **Default**: 4.0
- **Range**: 0-50

### HighThreshold
Upper threshold for target range in mmol/L. Default is 10.0.

- **Type**: Double
- **Required**: No
- **Default**: 10.0
- **Range**: 0-50

### GlucoseColumn
Name of the column containing glucose values. Default is 'CGM Glucose Value (mmol/l)'.

- **Type**: String
- **Required**: No
- **Default**: 'CGM Glucose Value (mmol/l)'

## Examples

### Example 1: Analyze CGM data from a zip file
```powershell
Import-GlookoZip -Path "export.zip" | Get-GlookoDataset -Name "cgm" | Get-GlookoCGMStats
```
Analyzes CGM data from a zip file and shows in-range statistics by date.

### Example 2: Analyze CGM data from a single CSV file
```powershell
$cgmData = Import-GlookoCSV -Path "cgm.csv"
Get-GlookoCGMStats -InputObject $cgmData.Data
```
Analyzes CGM data from a single CSV file.

### Example 3: Custom target range
```powershell
$stats = Get-GlookoCGMStats -InputObject $cgmData -LowThreshold 3.9 -HighThreshold 10.0
```
Analyzes with custom target range (3.9-10.0 mmol/L).

## Output
Returns PSCustomObject with the following properties:
- **Date**: The date for the statistics (yyyy-MM-dd format)
- **TotalReadings**: Total number of CGM readings for that date
- **BelowRange**: Count of readings below the target range
- **BelowRangePercent**: Percentage of readings below range (rounded to 1 decimal)
- **InRange**: Count of readings within the target range
- **InRangePercent**: Percentage of readings in range (rounded to 1 decimal)
- **AboveRange**: Count of readings above the target range
- **AboveRangePercent**: Percentage of readings above range (rounded to 1 decimal)
- **TargetRange**: String showing the target range used (e.g., "4-10 mmol/L")

## Notes
- Results are grouped by date for easy day-by-day analysis
- Percentages are rounded to one decimal place
- The function uses the standard Time in Range (TIR) thresholds by default
- For more detailed analysis with very low and very high categories, use `Get-GlookoCGMStatsExtended`

## Related Links
- [Get-GlookoCGMStatsExtended](get-glookocgmstatsextended.md) - Extended CGM statistics with more categories
- [Get-GlookoDataset](get-glookodataset.md) - Filter datasets by name
- [Import-GlookoCSV](import-glookocsv.md) - Import Glooko CSV files
- [Import-GlookoZip](import-glookozip.md) - Import Glooko zip files
