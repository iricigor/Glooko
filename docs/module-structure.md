# Module Structure

The Glooko PowerShell module follows a standard modular structure for PowerShell modules:

```
Glooko/
├── LICENSE                     # MIT License
├── README.md                   # Main documentation
├── Glooko.psd1                 # Module manifest
├── Glooko.psm1                 # Module loader
├── Public/                     # Public functions (exported)
│   └── Import-GlookoCSV.ps1    # Main CSV import function
├── Private/                    # Private functions (internal use only)
│   └── Expand-GlookoMetadata.ps1  # Metadata parsing helper
├── Tests/                      # Pester test files
│   ├── Import-GlookoCSV.Tests.ps1
│   ├── Expand-GlookoMetadata.Tests.ps1
│   ├── TestHelpers.ps1         # Test helper functions
│   └── Fixtures/               # Test data files
├── docs/                       # Additional documentation
│   ├── quick-start-codespaces.md
│   ├── alternative-import-methods.md
│   ├── module-structure.md
│   ├── import-glookocsv-function.md
│   └── testing.md
├── .github/                    # GitHub automation
│   └── workflows/
│       └── ci-cd.yml          # Continuous integration
├── .gitignore                  # Git ignore patterns
└── PesterConfig.ps1            # Pester configuration for code coverage
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

### Tests
The module uses Pester 5.x for comprehensive testing, with test files organized alongside the code they test.
