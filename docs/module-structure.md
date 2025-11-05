# Module Structure

The Glooko PowerShell module follows a standard modular structure for PowerShell modules:

```
Glooko/
├── LICENSE                     # MIT License
├── README.md                   # Main documentation
├── CONTRIBUTING.md             # Contribution guidelines
├── CHANGELOG.md                # Detailed release notes
├── Glooko.psd1                 # Module manifest
├── Glooko.psm1                 # Module loader
├── Glooko.Types.ps1xml         # Custom type definitions
├── Glooko.Format.ps1xml        # Custom formatting definitions
├── Build.ps1                   # Build script
├── Build-Help.ps1              # Help file generation script
├── Analyze.ps1                 # PSScriptAnalyzer runner
├── PesterConfig.ps1            # Pester configuration for core tests (with code coverage)
├── PesterConfig.Other.ps1      # Pester configuration for other tests (no code coverage)
├── PSScriptAnalyzerSettings.psd1  # PSScriptAnalyzer configuration
├── assets/                     # Module assets
│   └── Glooko.ico              # Module icon
├── en-US/                      # XML help files
│   └── Glooko-help.xml         # External MAML help for all exported functions
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
│   ├── Glooko.Dataset.Tests.ps1  # Type and formatting tests
│   ├── Build.Tests.ps1         # Module structure validation
│   ├── Get-ModuleChecksum.Tests.ps1  # Checksum calculation tests
│   ├── Verify-ModuleChecksum.Tests.ps1  # Checksum verification tests
│   ├── PSScriptAnalyzer.Tests.ps1  # Code quality tests
│   ├── Publish-ModuleDryRun.Tests.ps1  # Dry run publishing tests
│   ├── Publish-ModuleToGallery.Tests.ps1  # Publishing tests
│   ├── Update-Changelog.Tests.ps1  # Changelog automation tests
│   ├── Test-ChangelogVersion.Tests.ps1  # Changelog verification tests
│   ├── Publish-ModuleDryRun.Tests.ps1
│   ├── Publish-ModuleToGallery.Tests.ps1
│   ├── Helpers/                # Test helper functions
│   │   ├── TestHelpers.ps1
│   │   ├── New-TestCSVFile.ps1
│   │   ├── New-TestFolder.ps1
│   │   └── New-TestZipFile.ps1
│   └── Fixtures/               # Test data files
├── docs/                       # Additional documentation
│   ├── alternative-import-methods.md
│   ├── automated-changelog.md # Automated changelog updates guide
│   ├── help-generation.md      # Help file generation guide
│   ├── module-structure.md     # This file
│   ├── testing.md              # Testing documentation
│   ├── badge-setup.md          # Badge configuration guide
│   ├── release-process.md      # Release and publishing guide
│   ├── functions/              # Function documentation
│   │   ├── import-glookocsv.md
│   │   ├── import-glookofolder.md
│   │   ├── import-glookozip.md
│   │   └── export-glookozip-to-xlsx.md
│   └── help/                   # platyPS markdown help files
│       ├── Import-GlookoCSV.md
│       ├── Import-GlookoFolder.md
│       ├── Import-GlookoZip.md
│       └── Export-GlookoZipToXlsx.md
├── .github/                    # GitHub automation
│   ├── scripts/
│   │   ├── Install-ModuleVerbose.ps1  # Reusable function to install PowerShell modules
│   │   └── Install-TestModules.ps1    # Script to install required test modules
│   └── workflows/
│       ├── test.yml            # Continuous integration - Core tests (Linux & Windows)
│       ├── test-other.yml      # Continuous integration - Other tests (Linux only)
│       ├── analyze.yml         # Continuous integration - PSScriptAnalyzer
│       ├── build.yml           # Build module artifacts
│       ├── release.yml         # Release to PowerShell Gallery
│       └── update-changelog.yml # Automated changelog updates
├── Release/                    # Release automation scripts
│   ├── Create-ReleaseArtifact.ps1
│   ├── Create-ReleaseSummary.ps1
│   ├── Download-BuildArtifact.ps1
│   ├── Get-ModuleChecksum.ps1    # Calculate module runtime checksum
│   ├── Publish-ModuleDryRun.ps1
│   ├── Publish-ModuleToGallery.ps1
│   ├── Test-ChangelogVersion.ps1  # Changelog version verification helper
│   ├── Update-Changelog.ps1    # Automated changelog generation
│   ├── Verify-BuildArtifact.ps1
│   └── Verify-ModuleChecksum.ps1  # Verify checksum against published versions
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
- Type files (TypesToProcess)
- Format files (FormatsToProcess)

### Module Loader (Glooko.psm1)
The module loader:
- Dot-sources all scripts in the Public and Private folders
- Exports only public functions
- Handles error reporting for failed imports

### Public Functions
Functions in the `Public/` folder are automatically exported and available to users when they import the module.

### Private Functions
Functions in the `Private/` folder are internal helper functions used by public functions but not exported to users.

### Help Files
The module includes XML help files for all exported functions:
- **en-US/Glooko-help.xml** - External MAML help file that provides comprehensive help accessible via `Get-Help`
- **docs/help/** - platyPS-formatted markdown files generated from comment-based help
- **Build-Help.ps1** - Script to regenerate help files from comment-based help using platyPS

For more information about help file generation and maintenance, see [Help Generation Documentation](help-generation.md).
### Type and Format Files
The module includes custom type and format definitions:
- **Glooko.Types.ps1xml** - Defines the `Glooko.Dataset` custom type with script properties
- **Glooko.Format.ps1xml** - Defines custom formatting for `Glooko.Dataset` objects

These files are automatically loaded when the module is imported via the `TypesToProcess` and `FormatsToProcess` settings in the module manifest.

### Tests
The module uses Pester 5.x for comprehensive testing. Tests are split into two groups:

**Core Tests** (`PesterConfig.ps1`):
- Tests for module and Public/Private functions
- Runs on both Linux and Windows
- Includes code coverage metrics

**Other Tests** (`PesterConfig.Other.ps1`):
- Tests for build scripts, publishing tools, and utilities
- Runs on Linux only
- No code coverage (focused on internal/dev tools)

Test files are organized alongside the code they test in the `Tests/` folder.

### Code Quality
The module uses PSScriptAnalyzer to ensure code quality and adherence to PowerShell best practices:
- **PSScriptAnalyzerSettings.psd1** - Configuration file with rules and exclusions
- **Analyze.ps1** - Script to run PSScriptAnalyzer with custom settings
- **.github/workflows/analyze.yml** - Dedicated CI workflow for code quality checks on Public/, Private/, and Glooko.psm1
- **Analyze.ps1** - Script to run PSScriptAnalyzer with custom settings
- **Tests/PSScriptAnalyzer.Tests.ps1** - Automated tests to ensure code quality in CI/CD
