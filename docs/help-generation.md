# Help File Generation

This document describes how XML help files are generated for the Glooko PowerShell module using platyPS.

## Overview

The Glooko module uses [platyPS](https://github.com/PowerShell/platyPS) to generate external MAML (Microsoft Assistance Markup Language) help files from PowerShell comment-based help. This enables users to access comprehensive help documentation using PowerShell's built-in `Get-Help` cmdlet.

## File Structure

```
Glooko/
├── Build-Help.ps1           # Script to generate help files
├── en-US/                   # XML help files (MAML format)
│   └── Glooko-help.xml     # Compiled help for all exported functions
└── docs/
    └── help/                # platyPS markdown files
        ├── Export-GlookoZipToXlsx.md
        ├── Import-GlookoCSV.md
        ├── Import-GlookoFolder.md
        └── Import-GlookoZip.md
```

## Prerequisites

The `Build-Help.ps1` script automatically installs the required dependency:

- **platyPS** (v0.14.2 or later) - PowerShell module for generating help files

## Generating Help Files

### Automatic Generation

Run the `Build-Help.ps1` script to generate both platyPS markdown and XML help files:

```powershell
./dev/build/Build-Help.ps1
```

This will:
1. Install platyPS if not already installed
2. Import the Glooko module
3. Generate platyPS-formatted markdown files in `docs/help/` from comment-based help
4. Convert markdown files to XML (MAML) format in `en-US/Glooko-help.xml`

### With Verbose Output

For troubleshooting or to see detailed progress:

```powershell
./Build-Help.ps1 -Verbose
```

## Build Integration

The `Build.ps1` script automatically includes the `en-US/` folder in the module artifact, ensuring that help files are distributed with the module.

When building the module:
```powershell
./dev/build/Build.ps1
```

The output in `BuildOutput/` will include:
```
BuildOutput/
├── en-US/
│   └── Glooko-help.xml
└── ... (other module files)
```

## Using Help Files

After importing the module, users can access help using standard PowerShell help commands:

### View Basic Help
```powershell
Get-Help Import-GlookoCSV
```

### View Examples
```powershell
Get-Help Import-GlookoCSV -Examples
```

### View Detailed Help
```powershell
Get-Help Import-GlookoCSV -Detailed
```

### View Full Help (All Sections)
```powershell
Get-Help Import-GlookoCSV -Full
```

### View Parameter Details
```powershell
Get-Help Import-GlookoCSV -Parameter Path
```

## Updating Help Files

When you modify comment-based help in the function files (in `Public/`), you should regenerate the help files:

1. Update the comment-based help in the `.ps1` file
2. Run `./Build-Help.ps1` to regenerate both markdown and XML
3. Review the changes in `docs/help/` and `en-US/`
4. Commit the updated files

### Example Workflow

```powershell
# 1. Edit function with updated help
# Edit Public/Import-GlookoCSV.ps1

# 2. Regenerate help files
./dev/build/Build-Help.ps1

# 3. Test the help
Import-Module ./Glooko.psd1 -Force
Get-Help Import-GlookoCSV -Full

# 4. Commit changes
git add Public/Import-GlookoCSV.ps1 docs/help/Import-GlookoCSV.md en-US/Glooko-help.xml
git commit -m "Update Import-GlookoCSV help documentation"
```

## platyPS Markdown Format

The markdown files in `docs/help/` follow the platyPS schema with YAML front matter:

```markdown
---
external help file: Glooko-help.xml
Module Name: Glooko
online version:
schema: 2.0.0
---

# Function-Name

## SYNOPSIS
Brief description

## SYNTAX
...
```

These files are auto-generated from comment-based help and should not be manually edited unless necessary. If you need to make changes, prefer updating the comment-based help in the source `.ps1` files and regenerating.

## Manual Markdown Editing

If you need to manually edit the platyPS markdown files (e.g., to add online version links or fix formatting):

1. Edit the markdown file in `docs/help/`
2. Run `./Build-Help.ps1` to regenerate XML
3. Test the changes with `Get-Help`
4. Commit both markdown and XML changes

## Troubleshooting

### Help Not Showing

If `Get-Help` doesn't show the external help:

1. Verify `en-US/Glooko-help.xml` exists
2. Ensure you're importing the module from the correct path
3. Try `Import-Module ./Glooko.psd1 -Force` to reload
4. Check that the module is loaded: `Get-Module Glooko`

### platyPS Not Installed

The script will automatically install platyPS. If you encounter issues:

```powershell
Install-Module -Name platyPS -Scope CurrentUser -Force
```

### Invalid MAML

If the XML file is corrupted or invalid:

1. Delete `en-US/Glooko-help.xml`
2. Run `./Build-Help.ps1` to regenerate
3. If the issue persists, check the markdown files in `docs/help/`

## References

- [platyPS Documentation](https://github.com/PowerShell/platyPS)
- [About Comment-Based Help](https://docs.microsoft.com/en-us/powershell/scripting/developer/help/writing-comment-based-help-topics)
- [MAML Help Files](https://docs.microsoft.com/en-us/powershell/scripting/developer/help/writing-help-for-windows-powershell-cmdlets)
