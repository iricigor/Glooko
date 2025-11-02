# Module Structure

The Glooko PowerShell module follows a standard modular structure for PowerShell modules:

```
Glooko/
├── LICENSE                     # MIT License
├── README.md                   # Main documentation
├── Glooko.psd1                 # Module manifest
├── Glooko.psm1                 # Module loader
├── Build.ps1                   # Build script
├── Analyze.ps1                 # PSScriptAnalyzer runner
├── PesterConfig.ps1            # Pester configuration for code coverage
├── PSScriptAnalyzerSettings.psd1  # PSScriptAnalyzer configuration
├── assets/                     # Module assets (icons, images)
│   ├── README.md               # Asset documentation
│   ├── icon.svg                # Module icon (SVG source)
│   └── icon.png                # Module icon (PNG)
├── Public/                     # Public functions (exported)
│   ├── Import-GlookoCSV.ps1    # Main CSV import function
│   ├── Import-GlookoFolder.ps1 # Folder import with dataset consolidation
│   ├── Import-GlookoZip.ps1    # Zip file import and processing
│   └── Export-GlookoZipToXlsx.ps1  # Zip to Excel conversion
├── Private/                    # Private functions (internal use only)
│   ├── Expand-GlookoMetadata.ps1  # Metadata parsing helper
│   └── Merge-GlookoDatasets.ps1   # Dataset consolidation helper
├── Tests/                      # Pester test files
│   ├── Import-GlookoCSV.Tests.ps1
│   ├── Import-GlookoFolder.Tests.ps1
│   ├── Import-GlookoZip.Tests.ps1
│   ├── Export-GlookoZipToXlsx.Tests.ps1
│   ├── Expand-GlookoMetadata.Tests.ps1
│   ├── Merge-GlookoDatasets.Tests.ps1
│   ├── Build.Tests.ps1         # Module structure validation
│   ├── PSScriptAnalyzer.Tests.ps1  # Code quality tests
│   ├── Helpers/                # Test helper functions
│   │   ├── TestHelpers.ps1
│   │   ├── New-TestCSVFile.ps1
│   │   ├── New-TestFolder.ps1
│   │   └── New-TestZipFile.ps1
│   └── Fixtures/               # Test data files
├── docs/                       # Additional documentation
│   ├── quick-start-codespaces.md
│   ├── alternative-import-methods.md
│   ├── module-structure.md     # This file
│   ├── testing.md              # Testing documentation
│   ├── badge-setup.md          # Badge configuration guide
│   └── functions/              # Function documentation
│       ├── import-glookocsv.md
│       ├── import-glookofolder.md
│       ├── import-glookozip.md
│       └── export-glookozip-to-xlsx.md
├── .github/                    # GitHub automation
│   ├── scripts/
│   │   ├── Install-ModuleVerbose.ps1  # Reusable function to install PowerShell modules
│   │   └── Install-TestModules.ps1    # Script to install required test modules
│   └── workflows/
│       ├── test.yml            # Continuous integration - Pester tests
│       └── analyze.yml         # Continuous integration - PSScriptAnalyzer
└── .gitignore                  # Git ignore patterns
```

## Key Components

### Module Manifest (Glooko.psd1)
The module manifest defines metadata about the module including:
- Module version
- Author information
- Required PowerShell version
- Exported functions and cmdlets
- Module dependencies

### Module Loader (Glooko.psm1)
The module loader:
- Dot-sources all scripts in the Public and Private folders
- Exports only public functions
- Handles error reporting for failed imports

### Public Functions
Functions in the `Public/` folder are automatically exported and available to users when they import the module.

### Private Functions
Functions in the `Private/` folder are internal helper functions used by public functions but not exported to users.

### Assets
The `assets/` folder contains visual resources for the module:
- **icon.svg** - The source SVG icon file
- **icon.png** - The PNG icon file (referenced by the module manifest)

The PNG icon is referenced in the module manifest via the `IconUri` property and is displayed in the PowerShell Gallery.

### Tests
The module uses Pester 5.x for comprehensive testing, with test files organized alongside the code they test.

### Code Quality
The module uses PSScriptAnalyzer to ensure code quality and adherence to PowerShell best practices:
- **PSScriptAnalyzerSettings.psd1** - Configuration file with rules and exclusions
- **Analyze.ps1** - Script to run PSScriptAnalyzer with custom settings
- **Tests/PSScriptAnalyzer.Tests.ps1** - Automated tests to ensure code quality in CI/CD
