# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) using major.minor version format.

## [Unreleased]

### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security

## [1.0] - 2024-11-02

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

[Unreleased]: https://github.com/iricigor/Glooko/compare/v1.0...HEAD
[1.0]: https://github.com/iricigor/Glooko/releases/tag/v1.0
