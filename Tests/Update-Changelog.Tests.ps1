BeforeAll {
    # Store original location
    $script:OriginalLocation = Get-Location
    $script:RepoRoot = Split-Path -Parent $PSScriptRoot
    $script:UpdateChangelogScript = Join-Path $script:RepoRoot 'Release/Update-Changelog.ps1'
}

AfterAll {
    # Restore original location
    Set-Location $script:OriginalLocation
}

Describe 'Update-Changelog.ps1' {
    
    Context 'Script Validation' {
        It 'Should exist' {
            $script:UpdateChangelogScript | Should -Exist
        }
        
        It 'Should be a valid PowerShell script' {
            { $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $script:UpdateChangelogScript -Raw), [ref]$null) } | Should -Not -Throw
        }
        
        It 'Should have proper parameter definitions' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'param\s*\('
            $scriptContent | Should -Match '\[Parameter\(Mandatory\)\]'
            $scriptContent | Should -Match '\$Repository'
            $scriptContent | Should -Match '\$GH_TOKEN'
            $scriptContent | Should -Match '\$DryRun'
        }
        
        It 'Should have proper comment-based help' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match '\.SYNOPSIS'
            $scriptContent | Should -Match '\.DESCRIPTION'
            $scriptContent | Should -Match '\.PARAMETER'
            $scriptContent | Should -Match '\.EXAMPLE'
        }
    }
    
    Context 'Function Definitions' {
        BeforeAll {
            # Note: We extract function definitions using regex for validation purposes only.
            # This is acceptable in tests as we're only checking that functions are defined,
            # not executing or parsing complex logic.
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            
            # Extract just the function definitions for testing
            $functionPattern = 'function\s+[\w-]+\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\}'
            $functions = [regex]::Matches($scriptContent, $functionPattern)
        }
        
        It 'Should define Get-LatestRelease function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Get-LatestRelease'
        }
        
        It 'Should define Get-BuildsSinceRelease function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Get-BuildsSinceRelease'
        }
        
        It 'Should define Get-BuildVersion function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Get-BuildVersion'
        }
        
        It 'Should define Get-PRForCommit function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Get-PRForCommit'
        }
        
        It 'Should define Format-ChangelogEntry function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Format-ChangelogEntry'
        }
        
        It 'Should define Group-ByMajorMinor function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Group-ByMajorMinor'
        }
        
        It 'Should define Get-CategoryFromLabels function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Get-CategoryFromLabels'
        }
        
        It 'Should define Update-ChangelogFile function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Update-ChangelogFile'
        }
    }
    
    Context 'Helper Functions Logic' {
        BeforeAll {
            # Note: We use Invoke-Expression here in a controlled test environment
            # to extract and test specific helper functions in isolation.
            # The input is from a trusted source (our own script file) and the 
            # regex pattern ensures we only execute function definitions.
            # This approach is acceptable in tests for validating function logic
            # without requiring the full script execution context.
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            
            # Extract and execute the Get-CategoryFromLabels function
            if ($scriptContent -match '(function Get-CategoryFromLabels\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
            
            # Extract and execute only the Format-ChangelogEntry function for testing
            if ($scriptContent -match '(function Format-ChangelogEntry\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
            
            # Extract and execute the Group-ByMajorMinor function
            if ($scriptContent -match '(function Group-ByMajorMinor\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
        }
        
        It 'Get-CategoryFromLabels should categorize bug labels as Fixed' {
            $result = Get-CategoryFromLabels -Labels @('bug', 'other')
            $result | Should -Be 'Fixed'
        }
        
        It 'Get-CategoryFromLabels should categorize feature labels as Added' {
            $result = Get-CategoryFromLabels -Labels @('feature')
            $result | Should -Be 'Added'
        }
        
        It 'Get-CategoryFromLabels should categorize enhancement labels as Added' {
            $result = Get-CategoryFromLabels -Labels @('enhancement')
            $result | Should -Be 'Added'
        }
        
        It 'Get-CategoryFromLabels should categorize documentation labels as Documentation' {
            $result = Get-CategoryFromLabels -Labels @('documentation')
            $result | Should -Be 'Documentation'
        }
        
        It 'Get-CategoryFromLabels should categorize security labels as Security' {
            $result = Get-CategoryFromLabels -Labels @('security')
            $result | Should -Be 'Security'
        }
        
        It 'Get-CategoryFromLabels should default to Changed for unknown labels' {
            $result = Get-CategoryFromLabels -Labels @('something-else')
            $result | Should -Be 'Changed'
        }
        
        It 'Get-CategoryFromLabels should default to Changed for empty labels' {
            $result = Get-CategoryFromLabels -Labels @()
            $result | Should -Be 'Changed'
        }
        
        It 'Get-CategoryFromLabels should categorize by title when labels are empty - fix prefix' {
            $result = Get-CategoryFromLabels -Labels @() -Title 'fix: resolve issue with X'
            $result | Should -Be 'Fixed'
        }
        
        It 'Get-CategoryFromLabels should categorize by title when labels are empty - Fix prefix' {
            $result = Get-CategoryFromLabels -Labels @() -Title 'Fix Update-Changelog.ps1 strict mode error'
            $result | Should -Be 'Fixed'
        }
        
        It 'Get-CategoryFromLabels should categorize by title when labels are empty - FIX prefix (case insensitive)' {
            $result = Get-CategoryFromLabels -Labels @() -Title 'FIX: resolve issue with X'
            $result | Should -Be 'Fixed'
        }
        
        It 'Get-CategoryFromLabels should categorize by title when labels are empty - feat prefix' {
            $result = Get-CategoryFromLabels -Labels @() -Title 'feat: add new feature'
            $result | Should -Be 'Added'
        }
        
        It 'Get-CategoryFromLabels should categorize by title when labels are empty - Add prefix' {
            $result = Get-CategoryFromLabels -Labels @() -Title 'Add automated changelog generation'
            $result | Should -Be 'Added'
        }
        
        It 'Get-CategoryFromLabels should NOT categorize "addition" as Added (word boundary check)' {
            $result = Get-CategoryFromLabels -Labels @() -Title 'addition of new items'
            $result | Should -Be 'Changed'
        }
        
        It 'Get-CategoryFromLabels should categorize by title when labels are empty - docs prefix' {
            $result = Get-CategoryFromLabels -Labels @() -Title 'docs: update README'
            $result | Should -Be 'Documentation'
        }
        
        It 'Get-CategoryFromLabels should prioritize labels over title' {
            $result = Get-CategoryFromLabels -Labels @('bug') -Title 'feat: add something'
            $result | Should -Be 'Fixed'
        }
        
        It 'Format-ChangelogEntry should format entry correctly with PR' {
            $pr = @{
                number = 123
                title = 'Test PR Title'
                html_url = 'https://github.com/test/repo/pull/123'
            }
            
            $result = Format-ChangelogEntry -Version '1.0.1' -Date '2024-11-03T10:00:00Z' -PR $pr
            
            $result.Version | Should -Be '1.0.1'
            $result.Date | Should -Be '2024-11-03'
            $result.Title | Should -Be 'Test PR Title'
            $result.PRLink | Should -Match '\[#123\]'
        }
        
        It 'Format-ChangelogEntry should include category with PR labels' {
            $pr = @{
                number = 123
                title = 'Test PR Title'
                html_url = 'https://github.com/test/repo/pull/123'
                labels = @('bug')
            }
            
            $result = Format-ChangelogEntry -Version '1.0.1' -Date '2024-11-03T10:00:00Z' -PR $pr
            
            $result.Category | Should -Be 'Fixed'
        }
        
        It 'Format-ChangelogEntry should default category to Changed without labels' {
            $pr = @{
                number = 123
                title = 'Test PR Title'
                html_url = 'https://github.com/test/repo/pull/123'
            }
            
            $result = Format-ChangelogEntry -Version '1.0.1' -Date '2024-11-03T10:00:00Z' -PR $pr
            
            $result.Category | Should -Be 'Changed'
        }
        
        It 'Format-ChangelogEntry should handle missing PR' {
            $result = Format-ChangelogEntry -Version '1.0.2' -Date '2024-11-03T10:00:00Z' -PR $null
            
            $result.Version | Should -Be '1.0.2'
            $result.Title | Should -Be 'Build 1.0.2'
            $result.PRLink | Should -Be ''
        }
        
        It 'Group-ByMajorMinor should group entries correctly' {
            $entries = @(
                @{ Version = '1.0.1'; Title = 'First' }
                @{ Version = '1.0.2'; Title = 'Second' }
                @{ Version = '1.1.0'; Title = 'Third' }
                @{ Version = '1.1.1'; Title = 'Fourth' }
            )
            
            $result = Group-ByMajorMinor -Entries $entries
            
            $result.Keys.Count | Should -Be 2
            $result.ContainsKey('1.0') | Should -Be $true
            $result.ContainsKey('1.1') | Should -Be $true
            $result['1.0'].Count | Should -Be 2
            $result['1.1'].Count | Should -Be 2
        }
    }
    
    Context 'Category Grouping' {
        BeforeAll {
            # Create a temporary test changelog
            $script:TestDrive = Join-Path ([System.IO.Path]::GetTempPath()) "PesterTest-$(New-Guid)"
            New-Item -Path $script:TestDrive -ItemType Directory -Force | Out-Null
            $script:TestChangelog = Join-Path $script:TestDrive "CHANGELOG.md"
            
            $initialContent = @"
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
### Changed

## [1.0] - 2024-11-02

### Added
- Initial release

[Unreleased]: https://github.com/iricigor/Glooko/compare/v1.0...HEAD
[1.0]: https://github.com/iricigor/Glooko/releases/tag/v1.0
"@
            Set-Content -Path $script:TestChangelog -Value $initialContent
            
            # Set repository for tests
            $script:Repository = 'iricigor/Glooko'
            
            # Extract and execute the Update-ChangelogFile function
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            if ($scriptContent -match '(function Update-ChangelogFile\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
            if ($scriptContent -match '(function Group-ByMajorMinor\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
        }
        
        AfterAll {
            if (Test-Path $script:TestDrive) {
                Remove-Item $script:TestDrive -Recurse -Force
            }
        }
        
        It 'Should group changelog entries by category' {
            $entries = @(
                @{ Version = '1.0.1'; Date = '2024-11-03'; Title = 'Add new feature'; PRLink = ' ([#101](https://example.com))'; Category = 'Added' }
                @{ Version = '1.0.2'; Date = '2024-11-03'; Title = 'Fix bug'; PRLink = ' ([#102](https://example.com))'; Category = 'Fixed' }
                @{ Version = '1.0.3'; Date = '2024-11-03'; Title = 'Update docs'; PRLink = ' ([#103](https://example.com))'; Category = 'Documentation' }
            )
            
            $result = Update-ChangelogFile -ChangelogPath $script:TestChangelog -NewEntries $entries
            
            # Should have separate category sections
            $result | Should -Match '### Added'
            $result | Should -Match '### Fixed'
            $result | Should -Match '### Documentation'
            
            # Should have entries under correct categories
            $result | Should -Match '### Added\s+- Add new feature'
            $result | Should -Match '### Fixed\s+- Fix bug'
            $result | Should -Match '### Documentation\s+- Update docs'
        }
        
        It 'Should maintain category order: Added, Changed, Fixed, etc.' {
            $entries = @(
                @{ Version = '1.0.1'; Date = '2024-11-03'; Title = 'Fix something'; PRLink = ''; Category = 'Fixed' }
                @{ Version = '1.0.2'; Date = '2024-11-03'; Title = 'Add feature'; PRLink = ''; Category = 'Added' }
                @{ Version = '1.0.3'; Date = '2024-11-03'; Title = 'Change behavior'; PRLink = ''; Category = 'Changed' }
            )
            
            $result = Update-ChangelogFile -ChangelogPath $script:TestChangelog -NewEntries $entries
            
            # Find positions of each category
            $addedPos = $result.IndexOf('### Added')
            $changedPos = $result.IndexOf('### Changed')
            $fixedPos = $result.IndexOf('### Fixed')
            
            # Added should come before Changed, which should come before Fixed
            $addedPos | Should -BeLessThan $changedPos
            $changedPos | Should -BeLessThan $fixedPos
        }
    }
    
    Context 'Changelog Header Version Format' {
        BeforeAll {
            # Create a temporary test changelog
            $script:TestDrive = Join-Path ([System.IO.Path]::GetTempPath()) "PesterTest-$(New-Guid)"
            New-Item -Path $script:TestDrive -ItemType Directory -Force | Out-Null
            $script:TestChangelog = Join-Path $script:TestDrive "CHANGELOG.md"
            
            $initialContent = @"
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

### Added
### Changed

## [1.0] - 2024-11-02

### Added
- Initial release

[Unreleased]: https://github.com/iricigor/Glooko/compare/v1.0...HEAD
[1.0]: https://github.com/iricigor/Glooko/releases/tag/v1.0
"@
            Set-Content -Path $script:TestChangelog -Value $initialContent
            
            # Set repository for tests
            $script:Repository = 'iricigor/Glooko'
            
            # Extract and execute the Update-ChangelogFile function
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            if ($scriptContent -match '(function Update-ChangelogFile\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
            if ($scriptContent -match '(function Group-ByMajorMinor\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
        }
        
        AfterAll {
            if (Test-Path $script:TestDrive) {
                Remove-Item $script:TestDrive -Recurse -Force
            }
        }
        
        It 'Should use full version number in changelog header, not just major.minor' {
            $entries = @(
                @{ Version = '1.0.14'; Date = '2025-11-03'; Title = 'Fix Update-Changelog.ps1'; PRLink = ' ([#107](https://example.com))' }
                @{ Version = '1.0.15'; Date = '2025-11-03'; Title = 'Another fix'; PRLink = ' ([#108](https://example.com))' }
                @{ Version = '1.0.16'; Date = '2025-11-03'; Title = 'Yet another fix'; PRLink = ' ([#109](https://example.com))' }
            )
            
            $result = Update-ChangelogFile -ChangelogPath $script:TestChangelog -NewEntries $entries
            
            # The header should use the latest full version (1.0.16), not just the major.minor (1.0)
            $result | Should -Match '## \[1\.0\.16\] - 2025-11-03'
            $result | Should -Not -Match '## \[1\.0\] - 2025-11-03'
        }
        
        It 'Should update version comparison links with full version numbers' {
            $entries = @(
                @{ Version = '1.0.14'; Date = '2025-11-03'; Title = 'Fix one'; PRLink = ' ([#107](https://example.com))' }
                @{ Version = '1.0.15'; Date = '2025-11-03'; Title = 'Fix two'; PRLink = ' ([#108](https://example.com))' }
            )
            
            $result = Update-ChangelogFile -ChangelogPath $script:TestChangelog -NewEntries $entries
            
            # Links should reference full versions
            $result | Should -Match '\[Unreleased\]: https://github\.com/iricigor/Glooko/compare/v1\.0\.15\.\.\.HEAD'
            # Only the latest version from each major.minor group should have a release tag link
            $result | Should -Match '\[1\.0\.15\]: https://github\.com/iricigor/Glooko/releases/tag/v1\.0\.15'
        }
        
        It 'Should add release tag links for each version section header' {
            # When multiple versions are in different major.minor groups, each gets its own section and link
            $entries = @(
                @{ Version = '1.0.14'; Date = '2025-11-03'; Title = 'Fix one'; PRLink = ' ([#107](https://example.com))'; Category = 'Fixed' }
                @{ Version = '1.1.15'; Date = '2025-11-03'; Title = 'Fix two'; PRLink = ' ([#108](https://example.com))'; Category = 'Fixed' }
                @{ Version = '2.0.16'; Date = '2025-11-03'; Title = 'Fix three'; PRLink = ' ([#109](https://example.com))'; Category = 'Fixed' }
            )
            
            $result = Update-ChangelogFile -ChangelogPath $script:TestChangelog -NewEntries $entries
            
            # Each major.minor group gets one section header and one release tag link
            $result | Should -Match '\[2\.0\.16\]: https://github\.com/iricigor/Glooko/releases/tag/v2\.0\.16'
            $result | Should -Match '\[1\.1\.15\]: https://github\.com/iricigor/Glooko/releases/tag/v1\.1\.15'
            $result | Should -Match '\[1\.0\.14\]: https://github\.com/iricigor/Glooko/releases/tag/v1\.0\.14'
        }
    }
    
    Context 'Version Sorting' {
        BeforeAll {
            # Create a temporary test changelog
            $script:TestDrive = Join-Path ([System.IO.Path]::GetTempPath()) "PesterTest-$(New-Guid)"
            New-Item -Path $script:TestDrive -ItemType Directory -Force | Out-Null
            $script:TestChangelog = Join-Path $script:TestDrive "CHANGELOG.md"
            
            $initialContent = @"
# Changelog

All notable changes to this project will be documented in this file.

## [Unreleased]

## [1.0] - 2024-11-02

### Added
- Initial release

[Unreleased]: https://github.com/iricigor/Glooko/compare/v1.0...HEAD
[1.0]: https://github.com/iricigor/Glooko/releases/tag/v1.0
"@
            Set-Content -Path $script:TestChangelog -Value $initialContent
            
            # Set repository for tests
            $script:Repository = 'iricigor/Glooko'
            
            # Extract and execute the Update-ChangelogFile function
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            if ($scriptContent -match '(function Update-ChangelogFile\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
            if ($scriptContent -match '(function Group-ByMajorMinor\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
        }
        
        AfterAll {
            if (Test-Path $script:TestDrive) {
                Remove-Item $script:TestDrive -Recurse -Force
            }
        }
        
        It 'Should sort versions numerically, not alphabetically (1.10 > 1.9 > 1.2)' {
            # This test verifies that version 1.10 is correctly sorted after 1.9 and 1.2
            # With string sorting (bug), 1.10 would come before 1.2
            # With version sorting (fix), 1.10 comes after 1.9
            $entries = @(
                @{ Version = '1.2.0'; Date = '2025-11-03'; Title = 'Version 1.2'; PRLink = ''; Category = 'Added' }
                @{ Version = '1.9.0'; Date = '2025-11-04'; Title = 'Version 1.9'; PRLink = ''; Category = 'Added' }
                @{ Version = '1.10.0'; Date = '2025-11-05'; Title = 'Version 1.10'; PRLink = ''; Category = 'Added' }
            )
            
            $result = Update-ChangelogFile -ChangelogPath $script:TestChangelog -NewEntries $entries
            
            # Extract the order of version headers from the result
            # Match both two-part (1.0) and three-part (1.0.1) version formats
            $versionHeaders = [regex]::Matches($result, '## \[(\d+\.\d+(?:\.\d+)?)\]') | ForEach-Object { $_.Groups[1].Value }
            
            # The versions should appear in descending order: 1.10.0, then 1.9.0, then 1.2.0
            $versionHeaders[0] | Should -Be '1.10.0'
            $versionHeaders[1] | Should -Be '1.9.0'
            $versionHeaders[2] | Should -Be '1.2.0'
        }
        
        It 'Should use version sorting in the script, not string sorting' {
            # Verify the script uses [version] cast for sorting
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            
            # Check that version sorting is used for major.minor keys
            $scriptContent | Should -Match 'Sort-Object\s+\{\s*\[version\]\$_\s*\}\s+-Descending'
        }
    }
    
    Context 'StrictMode Compliance' {
        It 'Should handle empty build results without error in strict mode' {
            # This test verifies the fix for the bug where accessing .Count on null
            # in strict mode caused: "The property 'Count' cannot be found on this object"
            
            # Simulate the scenario that caused the original bug
            $testScript = {
                Set-StrictMode -Version Latest
                $ErrorActionPreference = 'Stop'
                
                # Simulate what Get-BuildsSinceRelease does with no results
                $builds = @{ workflow_runs = @() }
                $relevantBuilds = @($builds.workflow_runs | Where-Object { $false })
                
                # This line was throwing the error before the fix
                Write-Host "Found $($relevantBuilds.Count) build runs"
                
                return $true
            }
            
            { & $testScript } | Should -Not -Throw
        }
        
        It 'Should return arrays consistently from Get-BuildsSinceRelease function' {
            # Verify the function always returns an array type
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            
            # The function should use Write-Output -NoEnumerate to prevent array unwrapping
            $scriptContent | Should -Match 'Write-Output\s+-NoEnumerate'
            
            # The function should wrap Where-Object results in @() for safety
            $scriptContent | Should -Match '@\(\$builds\.workflow_runs\s+\|\s+Where-Object'
        }
    }
    
    Context 'Script Execution Safety' {
        It 'Should have proper error handling' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'try\s*\{'
            $scriptContent | Should -Match 'catch\s*\{'
            $scriptContent | Should -Match '\$ErrorActionPreference'
        }
        
        It 'Should use Set-StrictMode' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'Set-StrictMode\s+-Version\s+Latest'
        }
        
        It 'Should exit with appropriate codes' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'exit\s+0'
            $scriptContent | Should -Match 'exit\s+1'
        }
    }
    
    Context 'DryRun Functionality' {
        It 'Should support DryRun switch parameter' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match '\[switch\]\$DryRun'
        }
        
        It 'Should pass DryRun to Update-ChangelogFile function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'DryRun:\$DryRun'
        }
    }
    
    Context 'GitHub Actions Output' {
        It 'Should check for GITHUB_OUTPUT environment variable' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match '\$env:GITHUB_OUTPUT'
        }
        
        It 'Should output version information when GITHUB_OUTPUT is set' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'versions='
            $scriptContent | Should -Match 'Out-File.*GITHUB_OUTPUT'
        }
        
        It 'Should format single version correctly' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            # Should have logic for single version: v{version}
            $scriptContent | Should -Match 'versionInfo\s*=\s*"v\$\('
        }
        
        It 'Should format multiple versions correctly' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            # Should have logic for two versions: v{version1} and v{version2}
            $scriptContent | Should -Match 'and v\$\('
            # Should have logic for more than two: v{version} and {count} more
            $scriptContent | Should -Match 'and \$\(\$versions\.Count - 1\) more'
        }
    }
}
