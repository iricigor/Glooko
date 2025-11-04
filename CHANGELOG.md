# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html) using major.minor version format.

## [1.0.24] - 2025-11-04

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

[1.0.24]: https://github.com/iricigor/Glooko/releases/tag/v1.0.24
[1.0.7]: https://github.com/iricigor/Glooko/releases/tag/v1.0.7
