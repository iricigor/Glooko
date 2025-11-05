# Glooko

[![release](https://img.shields.io/github/v/release/iricigor/Glooko.svg?logo=github)](https://github.com/iricigor/Glooko/releases) [![release-date](https://img.shields.io/github/release-date/iricigor/Glooko.svg?logo=github)](https://github.com/iricigor/Glooko/releases) [![PSGallery](https://img.shields.io/powershellgallery/v/Glooko.svg?logo=PowerShell)](https://www.powershellgallery.com/packages/Glooko) ![last-commit](https://img.shields.io/github/last-commit/iricigor/Glooko.svg)

[![Run Core Tests](https://github.com/iricigor/Glooko/actions/workflows/test.yml/badge.svg)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Run Other Tests](https://github.com/iricigor/Glooko/actions/workflows/test-other.yml/badge.svg)](https://github.com/iricigor/Glooko/actions/workflows/test-other.yml)
[![Linux Tests](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-linux-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
[![Windows Tests](https://img.shields.io/endpoint?url=https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-windows-tests.json)](https://github.com/iricigor/Glooko/actions/workflows/test.yml)
![supported-OS](https://img.shields.io/powershellgallery/p/Glooko.svg?style=flat&logo=PowerShell)

The Glooko PowerShell module streamlines the processing and conversion of exported diabetes data from Glooko into user-friendly formats.
The module or the author are not affiliated to [Glooko.com](https://glooko.com/about/)

It provides robust import functions for Glooko CSV files, zipped data sets, and entire folders, consolidating and parsing metadata to simplify analysis for technically inclined users.
The module includes advanced export capabilities to generate detailed Excel summaries with separate worksheets for each dataset. 
Internal helper functions ensure accurate merging and transformation of data, while a comprehensive test suite and code analysis maintain reliability across Windows, Linux, and macOS.
Designed for PowerShell 7+, this module is ideal for personal data exploration and custom analytics by tech-savvy individuals.

Looking ahead, future versions will build upon ongoing work to provide static analysis of imported data—including advanced CGM (Continuous Glucose Monitoring) statistics.
This will enable automated quality checks, anomaly detection, and more insightful glucose metrics, further enhancing the analytical capabilities of the module.

**Disclaimer:** This module is intended as a technical tool to assist with personal data analysis. 
It is not a substitute for professional medical advice, diagnosis, or treatment. 
Always consult with qualified healthcare professionals regarding any medical concerns or decisions.

> **Note:** This module requires PowerShell 7.0 or later. It is not compatible with Windows PowerShell 5.1.

[![downloads](https://img.shields.io/powershellgallery/dt/Glooko.svg?label=downloads&logo=PowerShell)](https://www.powershellgallery.com/packages/Glooko) ![GitHub](https://img.shields.io/github/license/iricigor/Glooko.svg?style=flat) ![GitHub top language](https://img.shields.io/github/languages/top/iricigor/Glooko.svg?style=flat) ![GitHub open issues](https://img.shields.io/github/issues/iricigor/Glooko.svg?style=flat) ![GitHub closed issues](https://img.shields.io/github/issues-closed/iricigor/Glooko.svg?style=flat) ![repo-stars](https://img.shields.io/github/stars/iricigor/Glooko.svg) ![repo-watchers](https://img.shields.io/github/watchers/iricigor/Glooko.svg)

## Installation

### From PowerShell Gallery

The recommended way to install this module is from the [PowerShell Gallery](https://www.powershellgallery.com/packages/Glooko):

```powershell
# Install the module
Install-Module -Name Glooko

# Verify the module is loaded
Get-Module Glooko -ListAvailable
```

To update to the latest version:

```powershell
Update-Module -Name Glooko
```

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
- **`Import-GlookoZip`** - Imports data from a Glooko zip file by extracting and processing CSV files, see [detailed documentation](docs/functions/import-glookozip.md).
- **`Get-GlookoDataset`** - Filters datasets by name and returns only their data, making it easy to work with specific dataset types like 'cgm' or 'alarms', see [detailed documentation](docs/functions/get-glookodataset.md).
- **`Export-GlookoZipToXlsx`** - Converts a Glooko zip file to an Excel (XLSX) file with a Summary worksheet as the first tab, followed by each dataset in a separate worksheet, see [detailed documentation](docs/functions/export-glookozip-to-xlsx.md).

### Getting Help

All functions include comprehensive help documentation. Use PowerShell's built-in help system:

```powershell
# View basic help
Get-Help Import-GlookoCSV

# View examples
Get-Help Import-GlookoCSV -Examples

# View detailed help
Get-Help Import-GlookoCSV -Full
```

For information about help file generation, see [Help Generation Documentation](docs/help-generation.md).

### Quick Example

```powershell
# Import a Glooko zip file
$data = Import-GlookoZip -Path "C:\data\export.zip"

# Get data from a specific dataset (e.g., CGM data)
$cgmData = $data | Get-GlookoDataset -Name "cgm"

# Or convert directly to Excel
Export-GlookoZipToXlsx -Path "C:\data\export.zip"
# Creates C:\data\export.xlsx with:
# - Summary worksheet (first tab) showing overview of all datasets
# - Each dataset in a separate worksheet
```

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for detailed information on how to contribute to this project.

## Changelog

For a detailed list of changes, see the [CHANGELOG.md](CHANGELOG.md) file.

## License


This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.



