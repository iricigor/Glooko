# Copilot Instructions for Glooko PowerShell Module

## Repository Overview

This is a PowerShell module for CSV data processing utilities, specifically designed for handling CSV files that require first-row skipping functionality. The module requires PowerShell 7.0 or later and is NOT backwards compatible with Windows PowerShell 5.1.

## Module Structure

- **Public/**: Contains exported functions (public API)
  - `Import-GlookoCSV.ps1`: Main function for importing CSV data with first-row skipping
- **Private/**: Contains internal helper functions
  - `Expand-GlookoMetadata.ps1`: Metadata parsing helper
- **Tests/**: Pester 5.x test files
  - `Import-GlookoCSV.Tests.ps1`: Tests for the main function
  - `Expand-GlookoMetadata.Tests.ps1`: Tests for metadata parsing
  - `TestHelpers.ps1`: Shared test utilities
  - `Fixtures/`: Test data files
- **docs/**: Documentation files
- **build/**: Build and development scripts
- **config/**: Configuration files
- **Glooko.psm1**: Root module file that imports all functions
- **Glooko.psd1**: Module manifest with metadata and exports

## Building and Testing

### Prerequisites
- PowerShell 7.0 or later (required)
- Pester 5.0 or later for testing

### Running Tests
Tests are run using Pester 5.x framework:
```powershell
# Run all tests with coverage
./config/PesterConfig.ps1

# Or run Pester directly
Invoke-Pester -Configuration $PesterConfig
```

### Test Configuration
- Tests are located in the `Tests/` directory
- Test results are output to `Tests/TestResults.xml` (JUnit format)
- Code coverage reports are generated in `Tests/CodeCoverage.xml` (JaCoCo format)
- Code coverage is tracked for `Public/*.ps1` and `Glooko.psm1` files (see config/PesterConfig.ps1)
- Target coverage: 75% minimum
- All tests should pass before submitting changes

### CI/CD
- GitHub Actions runs tests on both Linux (Ubuntu) and Windows
- Tests run on PowerShell 7
- Workflow file: `.github/workflows/test.yml`
- Tests run on PR creation and push to main/master branches

## Coding Standards

### PowerShell Best Practices
1. **Function Structure**:
   - Use approved verbs (Get, Set, Import, Export, etc.)
   - Include proper comment-based help with examples
   - Use CmdletBinding attribute for advanced functions
   - Support pipeline input where appropriate
   - Include proper parameter validation

2. **Parameter Naming**:
   - Use PascalCase for parameter names
   - Follow PowerShell naming conventions
   - Use standard parameter names (Path, Force, Verbose, etc.)

3. **Error Handling**:
   - Use try/catch blocks for error handling
   - Provide meaningful error messages
   - Use Write-Error for terminating errors
   - Use Write-Warning for non-terminating issues
   - Use Write-Verbose for detailed logging

4. **Code Style**:
   - Use 4-space indentation
   - Place opening braces on the same line as the statement
   - Use meaningful variable names
   - Add comments for complex logic only
   - Keep functions focused and single-purpose
   - **Prefer PowerShell cmdlets over .NET calls**: Use native PowerShell commands instead of .NET classes when possible (e.g., use `New-Guid` instead of `[System.Guid]::NewGuid()`). Exception: `[System.IO.Path]::GetTempPath()` is allowed for getting the system temp directory path.

5. **Verbose Output**:
   - Add Write-Verbose statements for debugging and tracing
   - Use verbose output to explain what the function is doing
   - Example pattern: `Write-Verbose "Processing file: $Path"`

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

## Common Tasks

### Adding a New Public Function
1. Create function file in `Public/` directory
2. Add proper comment-based help
3. Export function in `Glooko.psd1` FunctionsToExport array
4. Create corresponding test file in `Tests/` with `.Tests.ps1` suffix
5. Ensure all tests pass and coverage meets minimum threshold
6. Create a documentation file in `docs/functions/` directory (e.g., `docs/functions/functionname.md`) - see `docs/functions/import-glookocsv.md` as an example
7. Add the function to the main README.md file under the Usage section

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

### Working with CSV Files
- The module is designed for CSV files with special first-row metadata
- Use `Import-GlookoCSV` to import CSV data while skipping the first row
- The second row becomes the headers
- Metadata parsing is handled by `Expand-GlookoMetadata` (private function)

## Module Import
To test the module locally:
```powershell
# Import the module
Import-Module ./Glooko.psd1 -Force

# Verify it loaded
Get-Module Glooko

# Test a function
Import-GlookoCSV -Path path/to/file.csv
```

## Documentation
- Keep documentation in the `docs/` folder
- Update README.md for user-facing changes
- Keep function help up to date with examples
- Document breaking changes in release notes
- **Keep `docs/testing.md` and `docs/module-structure.md` up-to-date** when:
  - Adding new public or private functions (update both files)
  - Adding new test files (update both files)
  - Adding new helper functions in Tests/Helpers/ (update module-structure.md)
  - Adding new documentation files in docs/ (update module-structure.md)
  - Changing the module structure or file organization (update module-structure.md)
  - Adding or modifying test coverage (update testing.md)

## Git Workflow
- Work on feature branches
- Keep commits focused and atomic
- Write clear commit messages
- Ensure all tests pass before pushing
- CI will run tests on both Windows and Linux

## Versioning

### Version Format
- The module **must** use a **major.minor** version format (e.g., `1.0`, `2.1`)
- Do **not** use three-part versioning like `1.0.0` or `1.2.3`
- Version is specified in the `ModuleVersion` field in `Glooko.psd1`

### Version Updates
- **New feature requests** must increment the **minor version** (e.g., `1.0` → `1.1`, `1.5` → `1.6`)
- **Breaking changes** must increment the **major version** (e.g., `1.9` → `2.0`)
- **Bug fixes** that don't add new features should not change the version unless explicitly requested
- Always update the `ReleaseNotes` field in `Glooko.psd1` when changing the version

## Important Notes
- This module requires PowerShell 7.0 or later and is NOT compatible with Windows PowerShell 5.1
- Test on both Linux and Windows platforms when making significant changes
- The module has no external dependencies beyond Pester for testing
- Do not add dependencies on PowerShell 5.1 features as the module is designed for PowerShell 7+
- Use cross-platform compatible code (avoid Windows-specific cmdlets)
