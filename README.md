# Glooko

[![Run Pester Tests](https://github.com/iricigor/Glooko/actions/workflows/test.yml/badge.svg)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Linux Tests](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-linux-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Windows Tests](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-windows-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)

A PowerShell module for processing Glooko exports data. Not related to [Glooko.com](https://glooko.com/about/)

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

This module provides the following functions:

- **`Import-GlookoCSV`** - Imports CSV data while skipping the first row, see [detailed documentation](docs/functions/import-glookocsv.md).
- **`Import-GlookoFolder`** - Imports all CSV files from a specified folder using Import-GlookoCSV, see [detailed documentation](docs/functions/import-glookofolder.md).

## Development

### 🚀 Quick Start

For the fastest way to get started, see the [Quick Start with GitHub Codespaces](docs/quick-start-codespaces.md) guide.

### Module Structure

For information about the module's organization and components, see [Module Structure](docs/module-structure.md).

### Testing

This module includes comprehensive Pester 5.x tests. For detailed testing information, see [Testing](docs/testing.md).

## License


This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
