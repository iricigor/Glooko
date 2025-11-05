# Get-GlookoCGMStatsExtended

## Synopsis
Analyzes CGM data with extended statistics including very low and very high categories.

## Description
This function provides detailed analysis of Continuous Glucose Monitoring (CGM) data with customizable ranges including very low, low, in range, high, and very high categories. Results are grouped by date and include both counts and percentages. Supports date range filtering.

Default ranges (mmol/L):
- Very Low: < 3.0 mmol/L (< 54 mg/dL)
- Low: 3.0-3.9 mmol/L (54-70 mg/dL)
- In Range: 4.0-10.0 mmol/L (70-180 mg/dL)
- High: 10.1-13.9 mmol/L (181-250 mg/dL)
- Very High: >= 14.0 mmol/L (>= 250 mg/dL)

## Parameters

### InputObject
CGM data to analyze. Accepts output from `Get-GlookoDataset` or `Import-GlookoCSV`. Expected to have 'Timestamp' and a glucose value column.

- **Type**: Array
- **Required**: Yes
- **Pipeline Input**: Yes

### VeryLowThreshold
Threshold for very low readings in mmol/L. Default is 3.0. Readings below this are considered very low.

- **Type**: Double
- **Required**: No
- **Default**: 3.0
- **Range**: 0-50

### LowThreshold
Lower threshold for target range in mmol/L. Default is 4.0. Readings between VeryLowThreshold and LowThreshold are considered low.

- **Type**: Double
- **Required**: No
- **Default**: 4.0
- **Range**: 0-50

### HighThreshold
Upper threshold for target range in mmol/L. Default is 10.0. Readings between LowThreshold and HighThreshold are considered in range.

- **Type**: Double
- **Required**: No
- **Default**: 10.0
- **Range**: 0-50

### VeryHighThreshold
Threshold for very high readings in mmol/L. Default is 14.0. Readings above this are considered very high.

- **Type**: Double
- **Required**: No
- **Default**: 14.0
- **Range**: 0-50

### GlucoseColumn
Name of the column containing glucose values. Default is 'CGM Glucose Value (mmol/l)'.

- **Type**: String
- **Required**: No
- **Default**: 'CGM Glucose Value (mmol/l)'

### StartDate
Start date for filtering data (inclusive). Format: yyyy-MM-dd

- **Type**: DateTime
- **Required**: No

### EndDate
End date for filtering data (inclusive). Format: yyyy-MM-dd

- **Type**: DateTime
- **Required**: No

### Days
Number of days to include in analysis (from most recent date backwards).

- **Type**: Int
- **Required**: No
- **Range**: 1-365

## Examples

### Example 1: Analyze CGM data with detailed statistics
```powershell
Import-GlookoZip -Path "export.zip" | Get-GlookoDataset -Name "cgm" | Get-GlookoCGMStatsExtended
```
Analyzes CGM data with detailed statistics grouped by date.

### Example 2: Analyze last 7 days
```powershell
$cgmData = Import-GlookoCSV -Path "cgm.csv"
Get-GlookoCGMStatsExtended -InputObject $cgmData.Data -Days 7
```
Analyzes the last 7 days of CGM data.

### Example 3: Analyze specific date range
```powershell
Get-GlookoCGMStatsExtended -InputObject $cgmData -StartDate "2025-10-20" -EndDate "2025-10-27"
```
Analyzes CGM data for a specific date range.

### Example 4: Custom thresholds
```powershell
Get-GlookoCGMStatsExtended -InputObject $cgmData -VeryLowThreshold 2.8 -VeryHighThreshold 15.0
```
Analyzes with custom thresholds for very low and very high categories.

## Output
Returns PSCustomObject with the following properties:
- **Date**: The date for the statistics (yyyy-MM-dd format)
- **TotalReadings**: Total number of CGM readings for that date
- **VeryLow**: Count of readings in very low range
- **VeryLowPercent**: Percentage of very low readings (rounded to 1 decimal)
- **Low**: Count of readings in low range
- **LowPercent**: Percentage of low readings (rounded to 1 decimal)
- **InRange**: Count of readings within the target range
- **InRangePercent**: Percentage of readings in range (rounded to 1 decimal)
- **High**: Count of readings in high range
- **HighPercent**: Percentage of high readings (rounded to 1 decimal)
- **VeryHigh**: Count of readings in very high range
- **VeryHighPercent**: Percentage of very high readings (rounded to 1 decimal)
- **Ranges**: String showing all range definitions used

## Notes
- Results are grouped by date for easy day-by-day analysis
- Percentages are rounded to one decimal place
- Date filtering options are mutually exclusive (use either Days OR StartDate/EndDate)
- When using Days parameter, the last N days from the most recent reading are included
- For simpler analysis with just below/in/above range, use `Get-GlookoCGMStats`

## Related Links
- [Get-GlookoCGMStats](get-glookocgmstats.md) - Basic CGM statistics
- [Get-GlookoDataset](get-glookodataset.md) - Filter datasets by name
- [Import-GlookoCSV](import-glookocsv.md) - Import Glooko CSV files
- [Import-GlookoZip](import-glookozip.md) - Import Glooko zip files
