# Get-GlookoCGMStatsExtended

## Synopsis
Analyzes CGM data with flexible statistics - supports both basic (3 categories) and extended (5 categories) analysis.

## Description
This function provides flexible analysis of Continuous Glucose Monitoring (CGM) data. By default, uses three categories (low, in range, high) similar to Get-GlookoCGMStats. When the `UseVeryLowHigh` switch is enabled, provides extended analysis with five categories (very low, low, in range, high, very high). Results are grouped by date and include both counts and percentages. Supports date range filtering and customizable thresholds.

Default ranges without UseVeryLowHigh (mmol/L):
- Low: < 4.0 mmol/L (< 70 mg/dL)
- In Range: 4.0-10.0 mmol/L (70-180 mg/dL)
- High: > 10.0 mmol/L (> 180 mg/dL)

Default ranges with UseVeryLowHigh (mmol/L):
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

### UseVeryLowHigh
Switch to enable very low and very high categories. When not specified, uses three categories (same as Get-GlookoCGMStats).

- **Type**: Switch
- **Required**: No
- **Default**: False (uses 3 categories)

### VeryLowThreshold
Threshold for very low readings in mmol/L. Only used when `UseVeryLowHigh` is enabled. Default is 3.0.

- **Type**: Double
- **Required**: No
- **Default**: 3.0
- **Range**: 0-50

### LowThreshold
Lower threshold for target range in mmol/L. Default is 4.0.

- When `UseVeryLowHigh` is disabled: readings below this are considered low
- When `UseVeryLowHigh` is enabled: readings between VeryLowThreshold and LowThreshold are considered low

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
Threshold for very high readings in mmol/L. Only used when `UseVeryLowHigh` is enabled. Default is 14.0.

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

### Example 1: Analyze CGM data with 3 categories (default)
```powershell
Import-GlookoZip -Path "export.zip" | Get-GlookoDataset -Name "cgm" | Get-GlookoCGMStatsExtended
```
Analyzes CGM data with three categories (low, in range, high) grouped by date.

### Example 2: Analyze CGM data with 5 categories
```powershell
$cgmData | Get-GlookoCGMStatsExtended -UseVeryLowHigh
```
Analyzes CGM data with five categories including very low and very high.

### Example 3: Analyze last 7 days with 5 categories
```powershell
$cgmData = Import-GlookoCSV -Path "cgm.csv"
Get-GlookoCGMStatsExtended -InputObject $cgmData.Data -UseVeryLowHigh -Days 7
```
Analyzes the last 7 days of CGM data with extended categories.

### Example 4: Analyze specific date range
```powershell
Get-GlookoCGMStatsExtended -InputObject $cgmData -StartDate "2025-10-20" -EndDate "2025-10-27"
```
Analyzes CGM data for a specific date range (uses 3 categories by default).

### Example 5: Custom thresholds with 5 categories
```powershell
Get-GlookoCGMStatsExtended -InputObject $cgmData -UseVeryLowHigh -VeryLowThreshold 2.8 -VeryHighThreshold 15.0
```
Analyzes with custom thresholds for very low (< 2.8) and very high (>= 15.0) categories.

## Output
Returns PSCustomObject with the following properties:

**Without UseVeryLowHigh (3 categories):**
- **Date**: The date for the statistics (yyyy-MM-dd format)
- **TotalReadings**: Total number of CGM readings for that date
- **Low**: Count of readings below target range
- **LowPercent**: Percentage of low readings (rounded to 1 decimal)
- **InRange**: Count of readings within the target range
- **InRangePercent**: Percentage of readings in range (rounded to 1 decimal)
- **High**: Count of readings above target range
- **HighPercent**: Percentage of high readings (rounded to 1 decimal)
- **TargetRange**: String showing the target range used (e.g., "4-10 mmol/L")

**With UseVeryLowHigh (5 categories):**
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
- By default, uses 3 categories (low/in range/high) - same as `Get-GlookoCGMStats` but with date filtering support
- Enable `UseVeryLowHigh` switch for 5 categories (very low/low/in range/high/very high)
- Results are grouped by date for easy day-by-day analysis
- Percentages are rounded to one decimal place
- Date filtering options: use either `Days` OR `StartDate`/`EndDate` (not both)
- When using `Days` parameter, the last N days from the most recent reading are included
- VeryLowThreshold and VeryHighThreshold are only used when `UseVeryLowHigh` is enabled
- For simpler analysis without date filtering, use `Get-GlookoCGMStats`

## Related Links
- [Get-GlookoCGMStats](get-glookocgmstats.md) - Basic CGM statistics
- [Get-GlookoDataset](get-glookodataset.md) - Filter datasets by name
- [Import-GlookoCSV](import-glookocsv.md) - Import Glooko CSV files
- [Import-GlookoZip](import-glookozip.md) - Import Glooko zip files
