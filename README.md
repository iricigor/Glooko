# Glooko

A PowerShell module for CSV data processing utilities, specifically designed for handling CSV files that require first-row skipping functionality.

## Installation

### From GitHub

1. Clone the repository:
```powershell
git clone https://github.com/iricigor/Glooko.git
```

2. Import the module:
```powershell
# Navigate to the module directory
cd Glooko

# Import the module
Import-Module .\Glooko.psd1

# Verify the module is loaded
Get-Module Glooko
```

### Alternative Import Methods

```powershell
# Import directly from path
Import-Module "C:\Path\To\Glooko\Glooko.psd1"

# Import with force to reload if already loaded
Import-Module .\Glooko.psd1 -Force

# Check available commands
Get-Command -Module Glooko
```

## Module Structure

```
Glooko/
├── LICENSE              # MIT License
├── README.md            # This documentation
├── Glooko.psd1          # Module manifest
├── Glooko.psm1          # Module loader
├── Public/              # Public functions
│   └── Import-GlookoCSV.ps1
└── Tests/               # Pester tests
    ├── Import-GlookoCSV.Tests.ps1
    └── PesterConfig.ps1
```

## Import-GlookoCSV Function

The `Import-GlookoCSV` function is a PowerShell advanced function that imports data from CSV files while automatically skipping the first row. This is particularly useful when working with CSV files where the first row contains metadata, comments, or headers that differ from the actual column structure.

### Features

- **Skip First Row**: Automatically skips the first line of the CSV file
- **Automatic Headers**: Uses the second row as column headers
- **Fixed Delimiter**: Uses comma as delimiter
- **UTF8 Encoding**: Fixed UTF8 encoding for file reading
- **Pipeline Support**: Accepts pipeline input for batch processing
- **Error Handling**: Comprehensive validation and error reporting
- **Verbose Logging**: Detailed progress information when using `-Verbose`

### Usage

```powershell
# Basic usage - skip first row, use second row as headers
Import-GlookoCSV -Path "data.csv"

# Pipeline usage
Get-ChildItem *.csv | Import-GlookoCSV

# With verbose output
Import-GlookoCSV -Path "data.csv" -Verbose
```

### Parameters

- **Path** (Mandatory): The path to the CSV file to import. Supports pipeline input and validation.

### Examples

**Example 1**: Basic import with automatic header detection
```powershell
$data = Import-GlookoCSV -Path "C:\data\sales.csv"
```

**Example 2**: Pipeline processing of multiple CSV files
```powershell
$allData = Get-ChildItem "C:\data\*.csv" | Import-GlookoCSV
```

**Example 3**: Import with verbose output for troubleshooting
```powershell
$data = Import-GlookoCSV -Path "C:\data\sales.csv" -Verbose
```

## Testing

This module includes comprehensive Pester 5.x tests to ensure reliability and functionality.

### Prerequisites

```powershell
# Install Pester 5.x (if not already installed)
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck
```

### Running Tests

```powershell
# Run all tests
Invoke-Pester -Path .\Tests\

# Run tests with detailed output
Invoke-Pester -Path .\Tests\ -Output Detailed

# Run with code coverage
.\Tests\PesterConfig.ps1

# Run specific test file
Invoke-Pester -Path .\Tests\Import-GlookoCSV.Tests.ps1
```

### Test Coverage

The test suite covers:
- ✅ Basic CSV import functionality
- ✅ First row skipping behavior
- ✅ Automatic header detection from second row
- ✅ Comma delimiter processing
- ✅ UTF8 encoding support
- ✅ Pipeline input support
- ✅ Error handling for invalid files
- ✅ Edge cases (empty files, single rows)
- ✅ Special characters in data
- ✅ Verbose output verification

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.