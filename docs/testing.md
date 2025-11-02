# Testing

[![Run Pester Tests](https://github.com/iricigor/Glooko/actions/workflows/test.yml/badge.svg)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Linux Tests](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-linux-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Windows Tests](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-windows-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)

This module includes comprehensive Pester 5.x tests to ensure reliability and functionality.

## Prerequisites

```powershell
# Install Pester 5.x (if not already installed)
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck
```

## Running Tests

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

## Test Coverage

The test suite covers all public and private functions:

### Public Functions
- **Import-GlookoCSV** - CSV import with first row skipping
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

- **Import-GlookoFolder** - Import all CSV files from a folder
  - ✅ Folder processing with multiple CSV files
  - ✅ Dataset consolidation functionality
  - ✅ Pipeline input support
  - ✅ Error handling for invalid paths
  - ✅ Empty folder handling

- **Import-GlookoZip** - Import data from Glooko zip files
  - ✅ Zip file extraction and processing
  - ✅ CSV file discovery within zip archives
  - ✅ Dataset consolidation from zip contents
  - ✅ Error handling for invalid zip files
  - ✅ Pipeline input support

- **Export-GlookoZipToXlsx** - Convert Glooko zip to Excel
  - ✅ Zip to Excel conversion functionality
  - ✅ Summary worksheet generation
  - ✅ Multiple dataset worksheets
  - ✅ Error handling for invalid inputs
  - ✅ Output file creation verification

### Private Functions
- **Expand-GlookoMetadata** - Metadata parsing helper
  - ✅ Metadata extraction from CSV first row
  - ✅ Key-value pair parsing
  - ✅ Error handling for malformed metadata

- **Merge-GlookoDatasets** - Dataset consolidation helper
  - ✅ Multiple dataset merging
  - ✅ Dataset type identification
  - ✅ Property consolidation
  - ✅ Error handling for incompatible datasets

### Build and Module Tests
- **Build.Tests.ps1** - Module structure validation
  - ✅ Module manifest validation
  - ✅ Function export verification
  - ✅ Required module dependencies

## Continuous Integration

The repository includes GitHub Actions workflows that automatically run tests on every pull request and push to the main/master branch:

### Pester Tests
Test results are displayed directly in the PR checks tab, showing:

- ✅ Individual test case results with pass/fail status
- ✅ Detailed test names and execution times
- ✅ Code coverage metrics
- ✅ Test artifacts for download

The workflow uses [dorny/test-reporter](https://github.com/dorny/test-reporter) to parse JUnit XML test results and create detailed check runs in GitHub.

### PSScriptAnalyzer
The repository uses [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) to ensure code quality and adherence to PowerShell best practices. The analyzer checks for:

- ✅ Security vulnerabilities
- ✅ Code style issues
- ✅ Best practice violations
- ✅ Potential bugs

#### Running PSScriptAnalyzer Locally

```powershell
# Install PSScriptAnalyzer
Install-Module -Name PSScriptAnalyzer -Force -SkipPublisherCheck

# Run analyzer on module code only
.\Analyze.ps1 -Path Public,Private,Glooko.psm1

# Run analyzer on all PowerShell files
.\Analyze.ps1

# Auto-fix issues where possible
.\Analyze.ps1 -Fix
```

#### PSScriptAnalyzer Configuration

The analyzer uses settings defined in `PSScriptAnalyzerSettings.psd1`. Some rules are excluded because they don't apply to this project:

- `PSAvoidTrailingWhitespace` - Handled by editor settings
- `PSUseSingularNouns` - Plural nouns are intentional (e.g., Merge-GlookoDatasets)
- `PSAvoidUsingWriteHost` - Write-Host is acceptable for scripts
- `PSUseBOMForUnicodeEncodedFile` - BOM is not required for UTF-8
- `PSUseOutputTypeCorrectly` - Dynamic type detection may not be accurate

## Viewing Test Results

To view detailed test results for a pull request:

1. Navigate to the **Checks** tab in the pull request
2. Click on the **Pester Test Results** check run in the left sidebar
3. View individual test cases with their pass/fail status and execution times

The test reporter creates detailed check runs similar to the examples shown at the [Test Reporter marketplace page](https://github.com/marketplace/actions/test-reporter).
