# Testing

[![Run Core Tests](https://github.com/iricigor/Glooko/actions/workflows/test.yml/badge.svg)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Run Other Tests](https://github.com/iricigor/Glooko/actions/workflows/test-other.yml/badge.svg)](https://github.com/iricigor/Glooko/actions/workflows/test-other.yml)
[![Linux Tests](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-linux-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Windows Tests](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-windows-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)

This module includes comprehensive Pester 5.x tests to ensure reliability and functionality.

## Prerequisites

```powershell
# Install Pester 5.x (if not already installed)
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck
```

## Running Tests

The test suite is split into two groups:

### Core Tests (Module and Public/Private Functions)
Tests for production code - runs on both Linux and Windows:

```powershell
# Run core tests with code coverage
./config/PesterConfig.ps1

# Run specific core test file
Invoke-Pester -Path .\Tests\Import-GlookoCSV.Tests.ps1
```

### Other Tests (Build, Publishing, Utilities)
Tests for build scripts and internal tools - runs on Linux only:

```powershell
# Run other tests (no code coverage)
./config/PesterConfig.Other.ps1

# Run specific other test file
Invoke-Pester -Path .\Tests\Build.Tests.ps1
```

### Run All Tests
```powershell
# Run all tests
Invoke-Pester -Path .\Tests\

# Run tests with detailed output
Invoke-Pester -Path .\Tests\ -Output Detailed
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

- **Get-GlookoDataset** - Filter datasets by name and return data
  - ✅ Basic filtering by dataset name
  - ✅ Exact matching (no wildcard support)
  - ✅ Case-insensitive matching
  - ✅ Pipeline input support
  - ✅ Fallback to FullName when Dataset is null
  - ✅ Multiple dataset consolidation
  - ✅ Error handling for empty inputs
  - ✅ Data integrity preservation
  - ✅ Verbose output verification

- **Get-GlookoCGMStats** - Basic CGM data analysis
  - ✅ In-range statistics calculation (below/in/above)
  - ✅ Percentage calculations
  - ✅ Date grouping functionality
  - ✅ Custom threshold support
  - ✅ Custom glucose column name support
  - ✅ Pipeline input support
  - ✅ Boundary value handling
  - ✅ Error handling for empty inputs
  - ✅ Verbose output verification

- **Get-GlookoCGMStatsExtended** - Extended CGM data analysis
  - ✅ Five-category analysis (very low/low/in/high/very high)
  - ✅ Percentage calculations with rounding
  - ✅ Date grouping functionality
  - ✅ Date filtering with Days parameter
  - ✅ Date filtering with StartDate/EndDate
  - ✅ Custom threshold support for all categories
  - ✅ Custom glucose column name support
  - ✅ Pipeline input support
  - ✅ Boundary value handling
  - ✅ Error handling for empty inputs and invalid filters
  - ✅ Verbose output verification

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

### Release Automation Helper Functions
- **Test-ChangelogVersion** - Changelog version verification helper (in Release/ folder)
  - ✅ Version header detection in changelog
  - ✅ Support for two-part and three-part version numbers
  - ✅ Error handling for missing changelog
  - ✅ Edge cases with special characters and whitespace
  - ✅ Verbose output verification

### Type and Formatting Tests
- **Glooko.Dataset.Tests.ps1** - Custom type and formatting tests
  - ✅ Type assignment to Import-GlookoCSV results
  - ✅ Type assignment to Import-GlookoFolder results
  - ✅ Type assignment to merged datasets
  - ✅ Script property (RecordCount, DatasetName) functionality
  - ✅ Custom formatting output verification
  - ✅ Backward compatibility with existing code

### Build and Module Tests
- **Build.Tests.ps1** - Module structure validation
  - ✅ Module manifest validation
  - ✅ Function export verification
  - ✅ Required module dependencies

- **Get-ModuleChecksum.Tests.ps1** - Module checksum calculation tests
  - ✅ Checksum calculation for module source files
  - ✅ Consistent checksums for same files
  - ✅ Correct runtime files included in checksum
  - ✅ Version stripping from module manifest
  - ✅ Different checksums when code changes
  - ✅ Error handling for invalid paths

- **Verify-ModuleChecksum.Tests.ps1** - Checksum verification tests
  - ✅ Force flag bypasses verification
  - ✅ Checksum calculation for BuildOutput module
  - ✅ Script structure validation
  - ✅ Parameter acceptance verification
  - ✅ PowerShell Gallery interaction checks

- **Update-Changelog.Tests.ps1** - Changelog automation tests
  - ✅ Script validation and syntax checking
  - ✅ Function definitions verification
  - ✅ Helper function logic tests
  - ✅ Error handling verification
  - ✅ DryRun functionality tests

- **Test-ChangelogVersion.Tests.ps1** - Changelog verification tests
  - ✅ Version header detection in various formats
  - ✅ Validation of missing changelog entries
  - ✅ Error handling for non-existent files
  - ✅ Edge cases and special character handling

- **Publish-ModuleDryRun.Tests.ps1** - Dry run publishing tests
  - ✅ Script structure validation
  - ✅ Changelog verification in publish workflow
  - ✅ Version checking logic
  - ✅ Error handling for invalid scenarios

- **Publish-ModuleToGallery.Tests.ps1** - Publishing tests
  - ✅ Script structure validation
  - ✅ Changelog verification before publishing
  - ✅ PowerShell Gallery version checking
  - ✅ Error handling and exit codes

## Continuous Integration

The repository includes GitHub Actions workflows that automatically run tests on every pull request and push to the main/master branch:

### Core Tests Workflow
Runs core functionality tests (module and Public/Private functions) on both Linux and Windows:
- Test results are displayed directly in the PR checks tab
- Includes code coverage metrics
- Creates detailed check runs in GitHub

### Other Tests Workflow
Runs build, publishing, and utility tests on Linux only:
- Tests for Build.ps1, Publish scripts, and Update-Changelog.ps1
- No code coverage (focused on internal/dev tools)
- Creates separate check runs in GitHub

Both workflows display:
- ✅ Individual test case results with pass/fail status
- ✅ Detailed test names and execution times
- ✅ Test artifacts for download

The workflows use [dorny/test-reporter](https://github.com/dorny/test-reporter) to parse JUnit XML test results and create detailed check runs in GitHub.

### PSScriptAnalyzer Workflow
A separate dedicated workflow runs [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) to ensure code quality and adherence to PowerShell best practices:
- Runs on every pull request and push to main/master
- Analyzes Public/, Private/, and Glooko.psm1 for errors and warnings
- Also runs on all PowerShell files for informational purposes
- The analyzer checks for:
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

The analyzer uses settings defined in `dev/config/PSScriptAnalyzerSettings.psd1`. The following rules are excluded with detailed rationale:

- **`PSAvoidTrailingWhitespace`** - This is a formatting issue better handled by editor settings (e.g., `.editorconfig`, VS Code format-on-save). Enforcing it in the analyzer would create noise without adding security or functional value.

- **`PSUseSingularNouns`** - PowerShell best practices recommend singular nouns for cmdlet names, but this module intentionally uses plural nouns where it makes semantic sense. For example, `Merge-GlookoDatasets` operates on multiple datasets, making the plural form more descriptive and accurate.

- **`PSAvoidUsingWriteHost`** - While `Write-Host` should be avoided in module functions (which use `Write-Verbose`, `Write-Warning`, etc.), it's perfectly acceptable in standalone scripts like `Build.ps1` and `Analyze.ps1` where direct console output is intended.

- **`PSUseBOMForUnicodeEncodedFile`** - Byte Order Mark (BOM) is not required for UTF-8 files and can cause issues with some tools and platforms. Modern editors and PowerShell handle UTF-8 files without BOM correctly.

- **`PSAvoidUsingPositionalParameters`** - In test files, positional parameters improve readability and are a common practice. For example, `Join-Path $root 'Public'` is clearer than `Join-Path -Path $root -ChildPath 'Public'` in test contexts.

- **`PSUseDeclaredVarsMoreThanAssignments`** - In test files, variables are sometimes assigned for debugging or to improve test readability, even if not immediately used. This is acceptable in testing contexts.

- **`PSUseOutputTypeCorrectly`** - This rule can produce false positives with dynamic return types or when functions return arrays of custom objects. Since PowerShell's type system is dynamic, enforcing strict output type declarations can be overly restrictive.

## Viewing Test Results

To view detailed test results for a pull request:

1. Navigate to the **Checks** tab in the pull request
2. Click on the **Pester Test Results** check run in the left sidebar
3. View individual test cases with their pass/fail status and execution times

The test reporter creates detailed check runs similar to the examples shown at the [Test Reporter marketplace page](https://github.com/marketplace/actions/test-reporter).
