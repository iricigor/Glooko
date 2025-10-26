# Testing

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

## Continuous Integration

The repository includes a GitHub Actions workflow that automatically runs Pester tests on every pull request and push to the main/master branch. Test results are displayed directly in the PR checks tab, showing:

- ✅ Individual test case results with pass/fail status
- ✅ Detailed test names and execution times
- ✅ Code coverage metrics
- ✅ Test artifacts for download

The workflow uses [dorny/test-reporter](https://github.com/dorny/test-reporter) to parse JUnit XML test results and create detailed check runs in GitHub.

## Viewing Test Results

To view detailed test results for a pull request:

1. Navigate to the **Checks** tab in the pull request
2. Click on the **Pester Test Results** check run in the left sidebar
3. View individual test cases with their pass/fail status and execution times

The test reporter creates detailed check runs similar to the examples shown at the [Test Reporter marketplace page](https://github.com/marketplace/actions/test-reporter).
