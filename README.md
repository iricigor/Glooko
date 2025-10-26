# Glooko

[![Run Pester Tests](https://github.com/iricigor/Glooko/actions/workflows/test.yml/badge.svg)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Linux Tests](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/iricigor/Glooko/badges/linux-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Windows Tests](https://img.shields.io/endpoint?url=https://raw.githubusercontent.com/iricigor/Glooko/badges/windows-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)

A PowerShell module for CSV data processing utilities, specifically designed for handling CSV files that require first-row skipping functionality.

## 🚀 Quick Start

For the fastest way to get started, see the [Quick Start with GitHub Codespaces](docs/quick-start-codespaces.md) guide.

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

For more import options including using Install-GitModule, see [Alternative Import Methods](docs/alternative-import-methods.md).

## Usage

The main function provided by this module is `Import-GlookoCSV`, which imports CSV data while skipping the first row.

For detailed documentation about the function, see [Import-GlookoCSV Function](docs/import-glookocsv-function.md).

## Module Structure

For information about the module's organization and components, see [Module Structure](docs/module-structure.md).

## Testing

This module includes comprehensive Pester 5.x tests. For detailed testing information, see [Testing](docs/testing.md).

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.