# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) using major.minor version format.

## [Unreleased]


## [1.1.3] - 2025-11-08

### Added
- **`Get-GlookoDailyAnalysis`** - New function to provide comprehensive daily analysis of CGM and insulin data
  - Groups data by day of week (Monday-Sunday)
  - Categorizes days as workday vs weekend
  - Calculates daily insulin dosages (basal, bolus, total) with percentages
  - Calculates correlation between in-range CGM percentage and insulin values
  - Supports pipeline input from Import-GlookoZip or separate CGM and insulin data parameters
  - Includes comprehensive test coverage
  - Full documentation in docs/functions/get-glookodailyanalysis.md
- **`Get-GlookoCGMStats`** - New function to analyze CGM data with basic statistics (below range, in range, above range)
  - Provides counts and percentages for each category
  - Groups results by date for day-by-day analysis
  - Supports customizable low and high thresholds
  - Default ranges: Below < 4.0, In Range 4.0-10.0, Above > 10.0 mmol/L
- **`Get-GlookoCGMStatsExtended`** - New function for extended CGM analysis with detailed statistics
  - Five categories: Very Low, Low, In Range, High, Very High
  - Date range filtering with StartDate, EndDate, or Days parameters
  - Fully customizable thresholds for all categories
  - Default ranges: Very Low < 3.0, Low 3.0-3.9, In Range 4.0-10.0, High 10.1-13.9, Very High >= 14.0 mmol/L
- **`Get-GlookoDataset`** - New function to filter and retrieve specific datasets from Glooko data
- **`Get-Correlation`** - Private helper function for statistical correlation calculations
- Mock data fixtures for testing and examples
- Comprehensive test coverage for all new functions (78.15% overall coverage)
- Full documentation in docs/functions/ for all new functions

### Changed
- Improve ReleaseNotes in psd1 with concise CHANGELOG summary ([#168](https://github.com/iricigor/Glooko/pull/168))
- Reorganize repository structure: consolidate folders and optimize root directory (10→5 folders) ([#147](https://github.com/iricigor/Glooko/pull/147))
- Updated module version to 1.1.3
- Updated README.md to include new CGM analysis functions
- Updated module manifest with new release notes

### Fixed
- Fix Update-Changelog.ps1 path resolution to repository root ([#172](https://github.com/iricigor/Glooko/pull/172))
- Fix cache key mismatch preventing build version auto-increment ([#170](https://github.com/iricigor/Glooko/pull/170))
- Fix automatic issue labeling after label rename ([#151](https://github.com/iricigor/Glooko/pull/151))

## [1.0.39] - 2025-11-05

### Added
- Add version numbers to changelog update PR titles ([#145](https://github.com/iricigor/Glooko/pull/145))
- Add changelog verification to release process ([#128](https://github.com/iricigor/Glooko/pull/128))
- Add module checksum verification to prevent duplicate releases ([#129](https://github.com/iricigor/Glooko/pull/129))
- Add external MAML help files for module cmdlets using platyPS ([#125](https://github.com/iricigor/Glooko/pull/125))
- Add custom type and formatting for Import-Glooko* command outputs ([#126](https://github.com/iricigor/Glooko/pull/126))
- Add version numbers to changelog update PR titles ([#145](https://github.com/iricigor/Glooko/pull/145))

### Changed
- Split tests into core and other workflows ([#127](https://github.com/iricigor/Glooko/pull/127))

### Fixed
- Fix release workflow to skip build number 0 artifacts from PR builds ([#143](https://github.com/iricigor/Glooko/pull/143))
- Fix changelog ordering: insert new versions after [Unreleased], not at EOF ([#140](https://github.com/iricigor/Glooko/pull/140))
- Fix changelog ordering: insert new versions after [Unreleased], not at EOF ([#140](https://github.com/iricigor/Glooko/pull/140))
- Fix module import missing in daily PS Gallery verification test step ([#138](https://github.com/iricigor/Glooko/pull/138))
- Fix changelog version sorting and add release tag links ([#136](https://github.com/iricigor/Glooko/pull/136))
- Fix release pipeline: Pass correct module path to checksum verification ([#135](https://github.com/iricigor/Glooko/pull/135))

### Documentation
- docs: clarify release process order - release BEFORE merging changelog PR ([#124](https://github.com/iricigor/Glooko/pull/124))

## [1.0.25] - 2025-11-04

### Added
- Add automated changelog generation workflow ([#102](https://github.com/iricigor/Glooko/pull/102))
- Add title-based fallback categorization for changelog entries ([#117](https://github.com/iricigor/Glooko/pull/117))
- Add CONTRIBUTING.md and consolidate contributor documentation ([#99](https://github.com/iricigor/Glooko/pull/99))
- Add daily verification pipelines for build/test and PS Gallery ([#118](https://github.com/iricigor/Glooko/pull/118))
- Group changelog items by category based on PR labels ([#114](https://github.com/iricigor/Glooko/pull/114))

### Changed
- Suppress ImportExcel verbose output when loading module ([#106](https://github.com/iricigor/Glooko/pull/106))
- Revise README for improved clarity and detail ([#98](https://github.com/iricigor/Glooko/pull/98))

### Fixed
- Fix bug to prevent duplicate module version uploads ([#116](https://github.com/iricigor/Glooko/pull/116))
- Fix changelog headers to use full version numbers instead of major.minor ([#110](https://github.com/iricigor/Glooko/pull/110))
- Fix Update-Changelog.ps1 strict mode error on empty version collections ([#107](https://github.com/iricigor/Glooko/pull/107))
- Fix null reference error in Update-Changelog.ps1 under strict mode ([#104](https://github.com/iricigor/Glooko/pull/104))

## [1.0.7] - 2025-11-01

### Added
- Initial release with `Import-GlookoCSV` function for CSV processing with first row skipping capability
- `Import-GlookoFolder` function to import all CSV files from a specified folder
- `Import-GlookoZip` function to import data from Glooko zip files
- `Export-GlookoZipToXlsx` function to convert Glooko zip files to Excel format
- Comprehensive Pester 5.x test suite with 75%+ code coverage target
- Cross-platform support for PowerShell 7.0+ on Windows and Linux
- GitHub Actions workflows for automated testing and building
- PSScriptAnalyzer integration for code quality checks
- Release automation to PowerShell Gallery

### Changed
- Updated to use major.minor version format (e.g., 1.0 instead of 1.0.0)

### Security
- Module requires PowerShell 7.0 or later (not compatible with Windows PowerShell 5.1)
- Released under MIT License

[Unreleased]: https://github.com/iricigor/Glooko/compare/v1.1.3...HEAD
[1.1.3]: https://github.com/iricigor/Glooko/releases/tag/v1.1.3
[1.0.39]: https://github.com/iricigor/Glooko/releases/tag/v1.0.39
[1.0.25]: https://github.com/iricigor/Glooko/releases/tag/v1.0.25
[1.0.7]: https://github.com/iricigor/Glooko/releases/tag/v1.0.7