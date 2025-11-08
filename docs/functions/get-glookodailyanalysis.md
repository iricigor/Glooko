# Get-GlookoDailyAnalysis

## Synopsis

Analyzes CGM data and insulin data grouped by day of week with correlations.

## Syntax

### Pipeline Parameter Set
```powershell
Get-GlookoDailyAnalysis [-InputObject] <Array> [-LowThreshold <Double>] [-HighThreshold <Double>] [-GlucoseColumn <String>]
```

### Separate Parameter Set
```powershell
Get-GlookoDailyAnalysis -CGMData <Array> -InsulinData <Array> [-LowThreshold <Double>] [-HighThreshold <Double>] [-GlucoseColumn <String>]
```

## Description

This function provides comprehensive daily analysis of CGM and insulin data. It groups data by day of week (Monday-Sunday) and workday vs weekend, calculates daily insulin dosages (basal, bolus, total) with percentages, and correlates in-scope CGM readings with insulin values.

The function accepts either separate CGM and insulin data parameters, or an array of datasets from Get-Glooko* functions where it will automatically select the appropriate datasets.

## Parameters

### -InputObject
Array of Glooko.Dataset objects from Import-GlookoFolder or Import-GlookoZip. The function will automatically extract 'cgm' and 'insulin' datasets.

```yaml
Type: Array
Parameter Sets: Pipeline
Required: True
Position: 0
Accept pipeline input: True
```

### -CGMData
CGM data to analyze. Accepts output from Get-GlookoDataset or Import-GlookoCSV. Expected to have 'Timestamp' and a glucose value column.

```yaml
Type: Array
Parameter Sets: Separate
Required: True
Position: Named
Accept pipeline input: False
```

### -InsulinData
Insulin data to analyze. Expected to have 'Timestamp', 'Insulin Type', 'Dose (units)', and optionally 'Method' columns.

```yaml
Type: Array
Parameter Sets: Separate
Required: True
Position: Named
Accept pipeline input: False
```

### -LowThreshold
Lower threshold for target range in mmol/L. Default is 4.0.

```yaml
Type: Double
Parameter Sets: All
Required: False
Default value: 4.0
Accept pipeline input: False
```

### -HighThreshold
Upper threshold for target range in mmol/L. Default is 10.0.

```yaml
Type: Double
Parameter Sets: All
Required: False
Default value: 10.0
Accept pipeline input: False
```

### -GlucoseColumn
Name of the column containing glucose values. Default is 'CGM Glucose Value (mmol/l)'.

```yaml
Type: String
Parameter Sets: All
Required: False
Default value: 'CGM Glucose Value (mmol/l)'
Accept pipeline input: False
```

## Inputs

### Array
Accepts Glooko.Dataset objects via pipeline, or separate CGM and insulin data arrays.

## Outputs

### PSCustomObject
Returns objects with the following properties:
- **DayOfWeek**: Name of the day (Monday-Sunday)
- **DayType**: 'Workday' or 'Weekend'
- **TotalDays**: Number of days in the dataset for this day of week
- **CGMReadings**: Total CGM readings for this day of week
- **BelowRange**: Count of readings below target range
- **BelowRangePercent**: Percentage of readings below target range
- **InRange**: Count of readings in target range
- **InRangePercent**: Percentage of readings in target range
- **AboveRange**: Count of readings above target range
- **AboveRangePercent**: Percentage of readings above target range
- **AvgDailyBasal**: Average daily basal insulin dose (units)
- **BasalPercent**: Basal insulin as percentage of total daily dose
- **AvgDailyBolus**: Average daily bolus insulin dose (units)
- **BolusPercent**: Bolus insulin as percentage of total daily dose
- **AvgDailyTotal**: Average total daily insulin dose (units)
- **TargetRange**: The target range used for analysis
- **CorrelationWithBasal**: Correlation coefficient between in-range % and basal insulin
- **CorrelationWithBolus**: Correlation coefficient between in-range % and bolus insulin
- **CorrelationWithTotal**: Correlation coefficient between in-range % and total insulin
- **CorrelationWithBasalPercent**: Correlation coefficient between in-range % and basal %
- **CorrelationWithBolusPercent**: Correlation coefficient between in-range % and bolus %

## Examples

### Example 1: Analyze data from a zip file
```powershell
Import-GlookoZip -Path "export.zip" | Get-GlookoDailyAnalysis
```

Analyzes both CGM and insulin data from a zip file, grouped by day of week with correlations.

### Example 2: Use explicit parameters
```powershell
$cgmData = Import-GlookoZip -Path "export.zip" | Get-GlookoDataset -Name "cgm"
$insulinData = Import-GlookoZip -Path "export.zip" | Get-GlookoDataset -Name "insulin"
Get-GlookoDailyAnalysis -CGMData $cgmData -InsulinData $insulinData
```

Analyzes data with explicit dataset parameters.

### Example 3: Use custom target range
```powershell
Get-GlookoDailyAnalysis -InputObject $datasets -LowThreshold 3.9 -HighThreshold 10.0
```

Analyzes with custom target range (3.9-10.0 mmol/L).

### Example 4: Focus on specific days
```powershell
$result = Import-GlookoZip -Path "export.zip" | Get-GlookoDailyAnalysis
$result | Where-Object { $_.DayType -eq 'Weekend' }
```

Analyzes all data and then filters to show only weekend statistics.

### Example 5: Find strongest correlations
```powershell
$result = Import-GlookoZip -Path "export.zip" | Get-GlookoDailyAnalysis
$result | Select-Object DayOfWeek, InRangePercent, CorrelationWithBolus, CorrelationWithBasal | Format-Table
```

Shows day of week with in-range percentage and correlation values for insulin types.

## Notes

- The function requires both CGM and insulin data to perform analysis
- Correlation coefficients range from -1 (negative correlation) to +1 (positive correlation)
- Correlation values near 0 indicate no linear relationship
- Days with no data for a particular day of week will not be included in the results
- The function automatically categorizes Saturday and Sunday as 'Weekend', all other days as 'Workday'
- Insulin is categorized as basal (Insulin Type='Basal' or Method contains 'Basal') or bolus (Insulin Type='Rapid' or Method='Bolus')

## Related Links

- [Get-GlookoCGMStats](get-glookocgmstats.md)
- [Get-GlookoCGMStatsExtended](get-glookocgmstatsextended.md)
- [Get-GlookoDataset](get-glookodataset.md)
- [Import-GlookoZip](import-glookozip.md)
