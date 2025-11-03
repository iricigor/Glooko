# Contributing to Glooko PowerShell Module

Thank you for your interest in contributing to the Glooko PowerShell module! This document provides guidelines and instructions for contributing to this project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation](#documentation)
- [Submitting Changes](#submitting-changes)
- [Release Process](#release-process)

## Code of Conduct

By participating in this project, you are expected to uphold our commitment to a welcoming and inclusive environment. Please be respectful and constructive in all interactions.

## Getting Started

### Prerequisites

- **PowerShell 7.0 or later** (required) - This module is NOT compatible with Windows PowerShell 5.1
- **Pester 5.0 or later** for testing
- **Git** for version control
- Basic knowledge of PowerShell module development

### Quick Start Options

#### Option 1: GitHub Codespaces (Recommended for fastest setup)

[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=iricigor/Glooko)

The fastest way to get started:

1. **Click the badge above** or go to the repository and click "Code" → "Create codespace on main"
2. **Wait for setup** (~2-3 minutes) - PowerShell, Pester, and all tools will be automatically installed
3. **Start developing** - The module will be pre-loaded and ready to use

**What You Get with Codespaces:**
- ✅ **PowerShell 7.4** with optimized settings
- ✅ **Pester 5.x** for testing
- ✅ **PSScriptAnalyzer** for code quality
- ✅ **VS Code** with PowerShell extensions
- ✅ **Pre-configured tasks** for build, test, and analysis
- ✅ **Debug configurations** ready to use
- ✅ **Sample data** for testing

**Quick Test in Codespaces:**
```powershell
# The module is auto-loaded, try it immediately:
Import-GlookoCSV -Path "Tests/sample-data.csv" -Verbose

# Run tests
Test-Module

# Build and validate everything
Build-Module
```

#### Option 2: Local Development

```powershell
# Clone the repository
git clone https://github.com/iricigor/Glooko.git
cd Glooko

# Install Pester 5.x (if not already installed)
Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck

# Import the module
Import-Module ./Glooko.psd1 -Force

# Verify it loaded
Get-Module Glooko
```

### Understanding the Codebase

Before making changes, familiarize yourself with:

- [Module Structure](docs/module-structure.md) - Module organization and components
- [Testing Documentation](docs/testing.md) - Testing framework and standards
- [Release Process](docs/release-process.md) - Publishing to PowerShell Gallery
- [README.md](README.md) - User-facing documentation

The module uses [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer) to ensure code quality and Pester 5.x for comprehensive testing. All contributions must pass tests and code analysis before being merged.

## Development Environment

### Repository Structure

```
Glooko/
├── Public/                  # Exported functions (public API)
├── Private/                 # Internal helper functions
├── Tests/                   # Pester test files
├── docs/                    # Documentation
├── Glooko.psm1             # Module loader
├── Glooko.psd1             # Module manifest
├── Build.ps1               # Build script
├── Analyze.ps1             # PSScriptAnalyzer runner
└── PesterConfig.ps1        # Test configuration
```

### Running Tests

```powershell
# Run all tests with coverage
./PesterConfig.ps1

# Run specific test file
Invoke-Pester -Path ./Tests/Import-GlookoCSV.Tests.ps1

# Run with detailed output
Invoke-Pester -Path ./Tests/ -Output Detailed
```

### Code Quality

```powershell
# Run PSScriptAnalyzer on module code
./Analyze.ps1 -Path Public,Private,Glooko.psm1

# Auto-fix issues where possible
./Analyze.ps1 -Fix
```

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **Bug fixes** - Fix issues and improve reliability
- **New features** - Add new functionality to the module
- **Documentation** - Improve or add documentation
- **Tests** - Add or improve test coverage
- **Code quality** - Refactor code, improve performance

### Reporting Issues

Before creating an issue:

1. Check if the issue already exists in [GitHub Issues](https://github.com/iricigor/Glooko/issues)
2. Verify you're using PowerShell 7.0 or later
3. Include:
   - PowerShell version (`$PSVersionTable`)
   - Operating system
   - Steps to reproduce
   - Expected vs. actual behavior
   - Error messages (if any)

### Suggesting Features

When suggesting a new feature:

1. Open an issue with the `[FEATURE]` prefix
2. Describe the use case and benefit
3. Consider implementation complexity
4. Be open to discussion and feedback

## Coding Standards

### PowerShell Best Practices

#### 1. Function Structure
- Use approved verbs (Get, Set, Import, Export, etc.)
- Include proper comment-based help with examples
- Use `[CmdletBinding()]` attribute for advanced functions
- Support pipeline input where appropriate
- Include proper parameter validation

Example:
```powershell
function Import-GlookoCSV {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string]$Path
    )
    
    begin {
        Write-Verbose "Starting CSV import"
    }
    
    process {
        # Implementation
    }
    
    end {
        Write-Verbose "CSV import completed"
    }
}
```

#### 2. Parameter Naming
- Use PascalCase for parameter names
- Follow PowerShell naming conventions
- Use standard parameter names (Path, Force, Verbose, etc.)

#### 3. Error Handling
- Use try/catch blocks for error handling
- Provide meaningful error messages
- Use `Write-Error` for terminating errors
- Use `Write-Warning` for non-terminating issues
- Use `Write-Verbose` for detailed logging

#### 4. Code Style
- Use 4-space indentation
- Place opening braces on the same line as the statement
- Use meaningful variable names
- Add comments for complex logic only
- Keep functions focused and single-purpose
- **Prefer PowerShell cmdlets over .NET calls**: Use native PowerShell commands instead of .NET classes when possible (e.g., use `New-Guid` instead of `[System.Guid]::NewGuid()`)
  - Exception: `[System.IO.Path]::GetTempPath()` is allowed for getting the system temp directory path

#### 5. Verbose Output
- Add `Write-Verbose` statements for debugging and tracing
- Use verbose output to explain what the function is doing
- Example pattern: `Write-Verbose "Processing file: $Path"`

### Cross-Platform Compatibility

This module must work on Windows, Linux, and macOS:

- Avoid Windows-specific cmdlets
- Use cross-platform file paths (use `Join-Path`, avoid hardcoded separators)
- Test on multiple platforms when possible
- Use PowerShell 7+ features (not Windows PowerShell 5.1)

## Testing Requirements

### Testing Standards

1. **Test Organization**:
   - Use Pester 5.x syntax (Describe/Context/It blocks)
   - Group related tests in Context blocks
   - Use descriptive test names that explain what is being tested

2. **Test Coverage**:
   - Aim for at least 75% code coverage
   - Test both success and error scenarios
   - Test edge cases and boundary conditions
   - Use TestDrive for file-based tests

3. **Test Data**:
   - Store test fixture files in `Tests/Fixtures/`
   - Use TestDrive for temporary test files
   - Clean up test data after tests complete

4. **Assertions**:
   - Use Should operators (Should -Be, Should -Throw, etc.)
   - Test specific properties, not entire objects
   - Verify error messages and warnings

### Writing Tests

Example test structure:
```powershell
Describe "Import-GlookoCSV" {
    Context "Valid CSV file" {
        It "Should import data successfully" {
            $result = Import-GlookoCSV -Path "test.csv"
            $result | Should -Not -BeNullOrEmpty
        }
    }
    
    Context "Error handling" {
        It "Should throw on non-existent file" {
            { Import-GlookoCSV -Path "nonexistent.csv" } | Should -Throw
        }
    }
}
```

### Running Tests Before Submission

Always run tests before submitting:

```powershell
# Run all tests with coverage
./PesterConfig.ps1

# Ensure all tests pass
# Ensure code coverage meets minimum 75%
```

## Documentation

### Documentation Requirements

1. **Comment-Based Help**: All public functions must have complete comment-based help including:
   - Synopsis
   - Description
   - Parameter descriptions
   - Examples (at least one)
   - Input/Output types

2. **Function Documentation**: Create a markdown file in `docs/functions/` for each public function

3. **Keep Documentation Updated**:
   - Update README.md for user-facing changes
   - Update function help when behavior changes
   - Update `docs/testing.md` and `docs/module-structure.md` when:
     - Adding new functions
     - Adding new test files
     - Changing module structure

### Documentation Style

- Use clear, concise language
- Provide practical examples
- Include error scenarios and troubleshooting
- Keep formatting consistent

## Submitting Changes

### Git Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Keep commits focused and atomic
   - Write clear commit messages
   - Follow coding standards
   - Add/update tests
   - Update documentation

3. **Test your changes**:
   ```powershell
   # Run tests
   ./PesterConfig.ps1
   
   # Run code analysis
   ./Analyze.ps1
   ```

4. **Commit your changes**:
   ```bash
   git add .
   git commit -m "Clear description of changes"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Create a Pull Request**:
   - Provide a clear title and description
   - Reference related issues (e.g., "Fixes #123")
   - Describe what changed and why
   - Ensure CI tests pass

### Pull Request Guidelines

- Keep PRs focused on a single issue or feature
- Ensure all tests pass (CI will verify)
- Include tests for new functionality
- Update documentation as needed
- Respond to review feedback promptly
- Be patient - reviews may take time

### Commit Message Format

Use clear, descriptive commit messages:

```
Add Import-GlookoFolder function for batch processing

- Implements folder scanning for CSV files
- Adds dataset consolidation
- Includes comprehensive tests
- Updates documentation

Fixes #42
```

## Release Process

The release process is managed by the repository owner. Contributors should focus on creating high-quality pull requests.

### Version Updates

When making changes that affect versioning:

- **New features**: Minor version increment (e.g., 1.0 → 1.1)
- **Breaking changes**: Major version increment (e.g., 1.9 → 2.0)
- **Bug fixes**: No version change unless explicitly requested

### Updating the Changelog

When making changes, update [CHANGELOG.md](CHANGELOG.md):

1. Add your changes under the `[Unreleased]` section
2. Use appropriate category:
   - **Added** for new features
   - **Changed** for changes in existing functionality
   - **Deprecated** for soon-to-be removed features
   - **Removed** for now removed features
   - **Fixed** for any bug fixes
   - **Security** for security-related changes

Example:
```markdown
## [Unreleased]

### Added
- `Import-GlookoFolder` function for batch CSV processing

### Fixed
- Error handling in `Import-GlookoCSV` for malformed files
```

For more details, see [Release Process](docs/release-process.md).

## Common Tasks

### Adding a New Public Function

1. Create function file in `Public/` directory
2. Add proper comment-based help
3. Export function in `Glooko.psd1` FunctionsToExport array
4. Create corresponding test file in `Tests/` with `.Tests.ps1` suffix
5. Ensure all tests pass and coverage meets minimum threshold
6. Create documentation file in `docs/functions/` directory
7. Add the function to README.md under the Usage section
8. Update CHANGELOG.md

### Adding a New Private Function

1. Create function file in `Private/` directory
2. Add proper comment-based help
3. Create corresponding test file in `Tests/` with `.Tests.ps1` suffix
4. Private functions are auto-imported by `Glooko.psm1`
5. Ensure all tests pass

### Modifying Existing Functions

1. Understand the current behavior by reading tests
2. Update or add tests first (TDD approach)
3. Make minimal changes to achieve the goal
4. Ensure all tests pass
5. Update comment-based help if behavior changes
6. Update documentation if needed
7. Update CHANGELOG.md

## Need Help?

- **Issues**: [GitHub Issues](https://github.com/iricigor/Glooko/issues)
- **Discussions**: Use GitHub Discussions for questions
- **Documentation**: Check the `docs/` folder for detailed guides

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to the Glooko PowerShell module! 🎉
