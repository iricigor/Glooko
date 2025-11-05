BeforeAll {
    # Import the function
    . "$PSScriptRoot/../Release/Get-LatestChangelogVersion.ps1"
}

Describe 'Get-LatestChangelogVersion' {
    Context 'When changelog file exists with valid versions' {
        BeforeAll {
            # Create a test changelog
            $testChangelog = @"
# Changelog

## [Unreleased]

### Documentation
- Some unreleased changes

## [1.0.25] - 2025-11-04

### Added
- New feature

## [1.0.7] - 2025-11-01

### Fixed
- Bug fix
"@
            $testFile = Join-Path $TestDrive 'test-changelog.md'
            Set-Content -Path $testFile -Value $testChangelog
        }

        It 'Should return the latest version number' {
            $result = Get-LatestChangelogVersion -ChangelogPath $testFile
            $result | Should -Be '1.0.25'
        }

        It 'Should ignore the Unreleased section' {
            $result = Get-LatestChangelogVersion -ChangelogPath $testFile
            $result | Should -Not -Be 'Unreleased'
        }

        It 'Should return a string' {
            $result = Get-LatestChangelogVersion -ChangelogPath $testFile
            $result | Should -BeOfType [string]
        }
    }

    Context 'When changelog has two-part and three-part versions' {
        BeforeAll {
            $testChangelog = @"
# Changelog

## [Unreleased]

## [2.1.15] - 2025-11-05

## [2.1] - 2025-11-04

## [1.0.25] - 2025-11-04

## [1.0] - 2025-11-01
"@
            $testFile = Join-Path $TestDrive 'mixed-versions.md'
            Set-Content -Path $testFile -Value $testChangelog
        }

        It 'Should return the highest version regardless of format' {
            $result = Get-LatestChangelogVersion -ChangelogPath $testFile
            $result | Should -Be '2.1.15'
        }
    }

    Context 'When changelog has versions in non-sorted order' {
        BeforeAll {
            $testChangelog = @"
# Changelog

## [1.0.5] - 2025-11-01

## [1.0.25] - 2025-11-04

## [1.0.7] - 2025-11-02
"@
            $testFile = Join-Path $TestDrive 'unsorted.md'
            Set-Content -Path $testFile -Value $testChangelog
        }

        It 'Should still find the latest version' {
            $result = Get-LatestChangelogVersion -ChangelogPath $testFile
            $result | Should -Be '1.0.25'
        }
    }

    Context 'When changelog file does not exist' {
        It 'Should return null' {
            $result = Get-LatestChangelogVersion -ChangelogPath (Join-Path $TestDrive 'nonexistent.md') -WarningAction SilentlyContinue
            $result | Should -BeNullOrEmpty
        }

        It 'Should write a warning' {
            $warnings = @()
            Get-LatestChangelogVersion -ChangelogPath (Join-Path $TestDrive 'nonexistent.md') -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
            $warnings[0] | Should -Match 'not found'
        }
    }

    Context 'When changelog has no version entries' {
        BeforeAll {
            $testChangelog = @"
# Changelog

## [Unreleased]

No versions yet.
"@
            $testFile = Join-Path $TestDrive 'no-versions.md'
            Set-Content -Path $testFile -Value $testChangelog
        }

        It 'Should return null' {
            $result = Get-LatestChangelogVersion -ChangelogPath $testFile -WarningAction SilentlyContinue
            $result | Should -BeNullOrEmpty
        }

        It 'Should write a warning' {
            $warnings = @()
            Get-LatestChangelogVersion -ChangelogPath $testFile -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Verbose output' {
        BeforeAll {
            $testChangelog = @"
## [1.0.25] - 2025-11-04
## [1.0.7] - 2025-11-01
"@
            $testFile = Join-Path $TestDrive 'verbose-test.md'
            Set-Content -Path $testFile -Value $testChangelog
        }

        It 'Should write verbose messages when requested' {
            $verboseOutput = Get-LatestChangelogVersion -ChangelogPath $testFile -Verbose 4>&1
            $verboseOutput | Should -Not -BeNullOrEmpty
            $verboseOutput | Where-Object { $_ -match 'Found version' } | Should -Not -BeNullOrEmpty
        }
    }

    Context 'Using actual repository changelog' {
        It 'Should find a version in the real CHANGELOG.md' {
            $changelogPath = Join-Path $PSScriptRoot '..' 'CHANGELOG.md'
            if (Test-Path $changelogPath) {
                $result = Get-LatestChangelogVersion -ChangelogPath $changelogPath
                $result | Should -Not -BeNullOrEmpty
                $result | Should -Match '^\d+\.\d+(\.\d+)?$'
            }
        }
    }
}
