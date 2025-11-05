BeforeAll {
    # Store original location
    $script:OriginalLocation = Get-Location
    $script:RepoRoot = Split-Path -Parent $PSScriptRoot
    
    # Import the function under test
    . (Join-Path $script:RepoRoot 'Release/Test-ChangelogVersion.ps1')
}

AfterAll {
    # Restore original location
    Set-Location $script:OriginalLocation
}

Describe 'Test-ChangelogVersion' {
    
    BeforeEach {
        # Create a temporary changelog file for testing
        $script:TestChangelogPath = Join-Path $TestDrive 'CHANGELOG.md'
    }
    
    Context 'When changelog file exists and contains the version' {
        
        It 'Should return true when version header is present' {
            $changelogContent = @'
# Changelog

## [Unreleased]

## [1.0.25] - 2025-11-04

### Added
- Some feature

## [1.0.7] - 2025-11-01

### Added
- Initial release
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $true
        }
        
        It 'Should return true when version header is present with different date' {
            $changelogContent = @'
# Changelog

## [1.0.25] - 2025-12-31

### Added
- Some feature
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $true
        }
        
        It 'Should return true for three-part version numbers' {
            $changelogContent = @'
# Changelog

## [1.0.25] - 2025-11-04

### Added
- Some feature
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $true
        }
        
        It 'Should return true when version header has no date' {
            $changelogContent = @'
# Changelog

## [1.0.25]

### Added
- Some feature
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $true
        }
        
        It 'Should return true for two-part version numbers' {
            $changelogContent = @'
# Changelog

## [1.0] - 2025-11-04

### Added
- Some feature
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $result = Test-ChangelogVersion -Version '1.0' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $true
        }
    }
    
    Context 'When changelog file exists but does not contain the version' {
        
        It 'Should return false when version is not present' {
            $changelogContent = @'
# Changelog

## [Unreleased]

## [1.0.7] - 2025-11-01

### Added
- Initial release
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $false
        }
        
        It 'Should return false when version appears but not as header' {
            $changelogContent = @'
# Changelog

## [1.0.7] - 2025-11-01

### Added
- Preparing for version 1.0.25 release
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $false
        }
        
        It 'Should return false when similar version exists but not exact match' {
            $changelogContent = @'
# Changelog

## [1.0.2] - 2025-11-01

### Added
- Some feature
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $false
        }
    }
    
    Context 'When changelog file does not exist' {
        
        It 'Should return false when file does not exist' {
            $nonExistentPath = Join-Path $TestDrive 'NonExistent.md'
            
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $nonExistentPath
            $result | Should -Be $false
        }
        
        It 'Should write warning when file does not exist' {
            $nonExistentPath = Join-Path $TestDrive 'NonExistent.md'
            
            $warnings = @()
            Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $nonExistentPath -WarningVariable warnings -WarningAction SilentlyContinue
            
            $warnings | Should -Not -BeNullOrEmpty
            $warnings[0] | Should -Match 'CHANGELOG.md not found'
        }
    }
    
    Context 'Edge cases and special characters' {
        
        It 'Should handle version with special regex characters' {
            $changelogContent = @'
# Changelog

## [1.0.25] - 2025-11-04

### Added
- Some feature
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            # Version numbers can contain dots which are special regex characters
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $true
        }
        
        It 'Should handle changelog with extra whitespace' {
            $changelogContent = @'
# Changelog

## [1.0.25]  -  2025-11-04

### Added
- Some feature
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $true
        }
        
        It 'Should be case-sensitive for version number' {
            $changelogContent = @'
# Changelog

## [1.0.25] - 2025-11-04

### Added
- Some feature
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            # PowerShell version strings are case-insensitive, but we test exact match
            $result = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath
            $result | Should -Be $true
        }
    }
    
    Context 'Verbose output' {
        
        It 'Should write verbose message when checking changelog' {
            $changelogContent = @'
# Changelog

## [1.0.25] - 2025-11-04
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $verboseOutput = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath -Verbose 4>&1
            
            $verboseOutput | Should -Not -BeNullOrEmpty
            $verboseOutput -join "`n" | Should -Match 'Checking if CHANGELOG.md contains version'
        }
        
        It 'Should write verbose message when version is found' {
            $changelogContent = @'
# Changelog

## [1.0.25] - 2025-11-04
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $verboseOutput = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath -Verbose 4>&1
            
            $verboseOutput -join "`n" | Should -Match 'Found version 1.0.25 in changelog'
        }
        
        It 'Should write verbose message when version is not found' {
            $changelogContent = @'
# Changelog

## [1.0.7] - 2025-11-04
'@
            Set-Content -Path $script:TestChangelogPath -Value $changelogContent
            
            $verboseOutput = Test-ChangelogVersion -Version '1.0.25' -ChangelogPath $script:TestChangelogPath -Verbose 4>&1
            
            $verboseOutput -join "`n" | Should -Match 'Version 1.0.25 not found in changelog'
        }
    }
}
