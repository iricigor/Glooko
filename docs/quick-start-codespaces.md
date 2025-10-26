# Quick Start with GitHub Codespaces

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=iricigor/Glooko)

The fastest way to get started is using GitHub Codespaces:

1. **Click the badge above** or go to the repository and click "Code" → "Create codespace on main"
2. **Wait for setup** (~2-3 minutes) - PowerShell, Pester, and all tools will be automatically installed
3. **Start developing** - The module will be pre-loaded and ready to use

## What You Get with Codespaces
- ✅ **PowerShell 7.4** with optimized settings
- ✅ **Pester 5.x** for testing
- ✅ **PSScriptAnalyzer** for code quality
- ✅ **VS Code** with PowerShell extensions
- ✅ **Pre-configured tasks** for build, test, and analysis
- ✅ **Debug configurations** ready to use
- ✅ **Sample data** for testing

## Quick Test in Codespaces
```powershell
# The module is auto-loaded, try it immediately:
Import-GlookoCSV -Path "Tests/sample-data.csv" -Verbose

# Run tests
Test-Module

# Build and validate everything
Build-Module
```
