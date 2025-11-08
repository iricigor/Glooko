# Mock Data for Glooko Analysis

This directory contains realistic mock datasets for testing and demonstrating Glooko PowerShell module functionality. The data is **anonymized and artificially generated** to represent typical diabetes data patterns.

## Purpose

These mock datasets are designed to:

1. **Provide realistic test data** for development and testing
2. **Enable data analysis demonstrations** without real patient data
3. **Show typical data patterns** found in Glooko exports
4. **Support documentation examples** with consistent, reproducible data

## Dataset Overview

All datasets follow the Glooko CSV format with:
- **First row**: Metadata line with patient name (anonymized) and date range
- **Second row**: Column headers
- **Subsequent rows**: Data records

### Available Datasets

#### 1a. CGM Data - Synthetic (`cgm_data_1.csv`)
**Continuous Glucose Monitoring data** - artificially generated glucose readings

- **Source**: Synthetic data (manually created)
- **Columns**: `Timestamp`, `Glucose Value (mg/dL)`, `Glucose Trend`
- **Records**: 288 readings (24 hours on 2025-01-01)
- **Patterns**: Realistic glucose variations including:
  - Overnight stability (85-98 mg/dL)
  - Dawn phenomenon (gradual rise starting at 4-5 AM)
  - Post-meal spikes after breakfast, lunch, and dinner
  - Natural glucose decline after meals
  - Trend arrows (Flat, SingleUp, DoubleUp, SingleDown, DoubleDown)

**Typical Use Cases**:
- Time-in-range analysis
- Glucose variability calculations
- Pattern recognition (dawn phenomenon, post-meal spikes)
- Trend arrow analysis

#### 1b. CGM Data - Real Research Data (`cgm_data_2.csv`)
**Continuous Glucose Monitoring data** - from open-source research study

- **Source**: Adapted from [Broll et al. iglu dataset](https://github.com/irinagain/iglu) (Subject 1)
- **Original Study**: Available via [GlucoBench repository](https://github.com/IrinaStatsLab/GlucoBench)
- **License**: GPL-2 (original data), adapted for Glooko format
- **Columns**: `Timestamp`, `Glucose Value (mg/dL)`
- **Records**: 500 readings (June 6-9, 2015)
- **Patterns**: Real-world CGM data showing:
  - Natural glucose variability
  - Meal-related glucose excursions
  - Day-to-day variation patterns
  - Authentic sensor data characteristics

**Typical Use Cases**:
- Realistic data analysis workflows
- Algorithm testing with real patterns
- Comparative analysis with synthetic data
- Research-grade data validation

#### 2. Insulin Data (`insulin_data_1.csv`)
**Insulin delivery records** - both basal and bolus insulin

- **Columns**: `Timestamp`, `Insulin Type`, `Dose (units)`, `Method`, `Device`
- **Records**: 77 insulin doses over 3 days
- **Patterns**:
  - Basal insulin: 1.0-1.2 units/hour (lower at night, higher during day)
  - Bolus insulin: 7.5-12.0 units with meals
  - Correction doses: 1.5-2.5 units as needed
  - All delivered via insulin pump

**Typical Use Cases**:
- Total daily insulin calculation
- Basal vs. bolus ratio analysis
- Insulin timing relative to meals
- Insulin adjustment pattern tracking

#### 3. Alarms Data (`alarms_data_1.csv`)
**Device alerts and alarms** - system notifications

- **Columns**: `Timestamp`, `Alarm/Event`, `Severity`, `Serial Number`
- **Records**: 14 alarms over 3 days
- **Types**:
  - Glucose alarms (high/low warnings and predictions)
  - Sensor calibration reminders
  - Insulin cartridge low warnings
  
**Typical Use Cases**:
- Alarm frequency analysis
- Pattern identification (time of day, alarm types)
- Device maintenance tracking
- Safety alert monitoring

#### 4. Carbohydrates Data (`carbs_data_1.csv`)
**Carbohydrate intake logging** - meal and snack entries

- **Columns**: `Timestamp`, `Carbohydrates (grams)`, `Food Description`, `Meal Type`
- **Records**: 15 food entries over 3 days
- **Patterns**:
  - Breakfast: 40-45g carbs
  - Lunch: 55-65g carbs
  - Dinner: 50-60g carbs
  - Snacks: 10-20g carbs
  - Correction snacks for low glucose

**Typical Use Cases**:
- Carb counting accuracy verification
- Meal timing analysis
- Insulin-to-carb ratio calculations
- Dietary pattern assessment

#### 5. Blood Glucose Data (`bg_data_1.csv`)
**Fingerstick blood glucose readings** - manual measurements

- **Columns**: `Timestamp`, `Blood Glucose (mg/dL)`, `Reading Type`, `Context`
- **Records**: 21 fingerstick readings over 3 days
- **Contexts**:
  - Fasting (morning readings): 108-112 mg/dL
  - Pre-meal readings: 115-123 mg/dL
  - Post-meal readings: 148-207 mg/dL
  - Before bed: 117-125 mg/dL

**Typical Use Cases**:
- CGM accuracy verification (compare with CGM data)
- Sensor calibration tracking
- Fasting glucose trends
- Pre/post-meal glucose excursions

## Data Characteristics

### Date Range
All datasets cover: **January 1-7, 2025** (or a subset thereof)

### Patient Information
- **Name**: Anonymous Patient (all datasets use anonymized identifier)
- **Device Serial Number**: 1234567 (where applicable)

### Data Quality
The mock data reflects realistic patterns:
- ✅ **Physiologically plausible** glucose values and variations
- ✅ **Coordinated timing** between datasets (meals, insulin, glucose)
- ✅ **Typical alarm patterns** based on glucose trends
- ✅ **Realistic insulin dosing** for an adult patient
- ✅ **Natural variability** in day-to-day patterns

## Usage Examples

### Example 1: Import and Analyze CGM Data

```powershell
# Import CGM data
$mockDataPath = "dev/tests/Fixtures/MockData"
$cgmData = Import-GlookoCSV -Path "$mockDataPath/cgm_data_1.csv"

# Analyze the data
$cgmData.Data | Measure-Object -Property "Glucose Value (mg/dL)" -Average -Minimum -Maximum

# Time in range (70-180 mg/dL)
$inRange = ($cgmData.Data | Where-Object { 
    $_.'Glucose Value (mg/dL)' -ge 70 -and $_.'Glucose Value (mg/dL)' -le 180 
}).Count
$totalReadings = $cgmData.Data.Count
$percentInRange = [math]::Round(($inRange / $totalReadings) * 100, 1)
Write-Host "Time in Range: $percentInRange%"
```

### Example 2: Import All Mock Datasets from Folder

```powershell
# Import all mock data files
$mockDataPath = "dev/tests/Fixtures/MockData"
$allData = Import-GlookoFolder -Path $mockDataPath

# Show summary
Write-Host "Total datasets: $($allData.Count)"
$allData | ForEach-Object {
    $datasetName = if ($_.Metadata.Dataset) { $_.Metadata.Dataset } else { $_.Metadata.FullName }
    Write-Host "  - $datasetName : $($_.Data.Count) records"
}
```

### Example 3: Filter by Dataset Type

```powershell
# Import folder and get only insulin data
$mockDataPath = "dev/tests/Fixtures/MockData"
$insulinData = Import-GlookoFolder -Path $mockDataPath | Get-GlookoDataset -Name "insulin"

# Calculate total daily insulin
$totalInsulin = ($insulinData | Measure-Object -Property "Dose (units)" -Sum).Sum
Write-Host "Total insulin delivered: $totalInsulin units"

# Calculate bolus vs basal ratio
$bolusDoses = $insulinData | Where-Object { $_.'Method' -eq 'Bolus' }
$basalDoses = $insulinData | Where-Object { $_.'Method' -eq 'Auto-Basal' }
$bolusTotal = ($bolusDoses | Measure-Object -Property "Dose (units)" -Sum).Sum
$basalTotal = ($basalDoses | Measure-Object -Property "Dose (units)" -Sum).Sum
Write-Host "Bolus: $bolusTotal units, Basal: $basalTotal units"
```

### Example 4: Create Test Zip File for Analysis

```powershell
# Create a zip file with mock data for testing
$mockDataPath = "dev/tests/Fixtures/MockData"
$zipPath = "TestDrive:\mock_export.zip"
Compress-Archive -Path "$mockDataPath\*.csv" -DestinationPath $zipPath

# Import the zip
$datasets = Import-GlookoZip -Path $zipPath

# Or export directly to Excel
Export-GlookoZipToXlsx -Path $zipPath -OutputPath "analysis_report.xlsx"
```

## File Naming Convention

All mock data files follow the Glooko naming pattern:
```
<dataset_name>_data_<order_number>.csv
```

Examples:
- `cgm_data_1.csv` - First CGM dataset
- `insulin_data_1.csv` - First insulin dataset
- `alarms_data_1.csv` - First alarms dataset

This naming convention allows the Glooko module to:
- Automatically identify dataset types
- Merge multiple files of the same type
- Order datasets consistently

## Data Sources

This directory contains two types of mock data:

### 1. Synthetic Data (Manually Created)
Most datasets are **completely synthetic** and do not represent any real patient. They were created by:

1. **Understanding typical patterns** from diabetes management literature
2. **Modeling realistic glucose dynamics** (meals, insulin action, circadian rhythms)
3. **Generating coordinated timestamps** across datasets
4. **Adding natural variability** to avoid unrealistic uniformity

**Files**:
- `cgm_data_1.csv` - Synthetic CGM data
- `insulin_data_1.csv` - Synthetic insulin delivery data
- `alarms_data_1.csv` - Synthetic device alarms
- `carbs_data_1.csv` - Synthetic carbohydrate intake
- `bg_data_1.csv` - Synthetic blood glucose readings

### 2. Open-Source Research Data (Adapted)
Some datasets are derived from publicly available research data:

**`cgm_data_2.csv`** - Adapted from the **Broll et al. iglu dataset**
- **Original Source**: [iglu R package](https://github.com/irinagain/iglu) by Broll et al.
- **Distributed via**: [GlucoBench repository](https://github.com/IrinaStatsLab/GlucoBench) by IrinaStatsLab
- **Original License**: GPL-2
- **Citation**: Broll, S., Urbanek, J., Buchanan, D., Chun, E., Muschelli, J., Punjabi, N. M., & Gaynanova, I. (2021). Interpreting blood GLUcose data with R package iglu. *PLOS ONE*, 16(4), e0248560. https://doi.org/10.1371/journal.pone.0248560
- **Adaptation**: Converted from original CSV format to Glooko-compatible format (added metadata header, renamed columns)
- **Subject**: Subject 1 from the original study (500 CGM readings from June 6-9, 2015)

**Attribution**: The cgm_data_2.csv file contains data from the iglu dataset (Broll et al., 2021), adapted for use with the Glooko PowerShell module. The original data was collected as part of research studies and made publicly available for scientific use.

## Privacy & Ethics

- ✅ **Synthetic data**: No real patient data was used for manually created datasets
- ✅ **Research data**: Open-source data from published studies with proper licensing
- ✅ **All values are anonymized** with generic identifiers
- ✅ **Safe for public repositories** and documentation
- ✅ **Proper attribution** provided for research-derived data

## Extending Mock Data

To add more mock data:

1. **Follow the existing file format** (metadata line + headers + data)
2. **Use realistic values** based on clinical knowledge
3. **Coordinate timestamps** with related datasets
4. **Use the naming convention** `<type>_data_<number>.csv`
5. **Document the new dataset** in this README

## Related Documentation

- [Import-GlookoCSV Documentation](../../../../docs/functions/import-glookocsv.md)
- [Import-GlookoFolder Documentation](../../../../docs/functions/import-glookofolder.md)
- [Import-GlookoZip Documentation](../../../../docs/functions/import-glookozip.md)
- [Get-GlookoDataset Documentation](../../../../docs/functions/get-glookodataset.md)
- [Testing Documentation](../../../../docs/testing.md)

## License

This mock data is part of the Glooko PowerShell module and is licensed under the MIT License. See [LICENSE](../../../../LICENSE) for details.
