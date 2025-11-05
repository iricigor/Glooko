BeforeAll {
    # Store original location
    $script:OriginalLocation = Get-Location
    $script:RepoRoot = Split-Path -Parent $PSScriptRoot
    $script:DryRunScript = Join-Path $script:RepoRoot 'Release/Publish-ModuleDryRun.ps1'
}

AfterAll {
    # Restore original location
    Set-Location $script:OriginalLocation
}

Describe 'Publish-ModuleDryRun.ps1' {
    
    BeforeEach {
        # Create a temporary directory for testing using Pester's TestDrive
        $script:TestDir = New-Item -Path (Join-Path $TestDrive (New-Guid)) -ItemType Directory
        
        # Create minimal module structure for testing
        $buildOutputDir = Join-Path $script:TestDir 'BuildOutput/Glooko'
        New-Item -Path $buildOutputDir -ItemType Directory -Force | Out-Null
        New-Item -Path (Join-Path $buildOutputDir 'Public') -ItemType Directory -Force | Out-Null
        
        # Create test files
        Set-Content -Path (Join-Path $buildOutputDir 'Glooko.psm1') -Value @'
# Test module
Get-ChildItem -Path $PSScriptRoot/Public/*.ps1 | ForEach-Object {
    . $_.FullName
}
'@
        Set-Content -Path (Join-Path $buildOutputDir 'Public/Test-Function.ps1') -Value 'function Test-Function { "test" }'
        
        # Create a basic module manifest
        $manifestPath = Join-Path $buildOutputDir 'Glooko.psd1'
        @"
@{
    RootModule = 'Glooko.psm1'
    ModuleVersion = '99.99.99'
    GUID = '02ff76d0-8773-4042-a1c6-343cc40deba5'
    Author = 'Test Author'
    Description = 'Test module for dry run testing'
    PowerShellVersion = '7.0'
    FunctionsToExport = @('Test-Function')
}
"@ | Set-Content -Path $manifestPath
        
        # Copy the dry run script to test directory
        Copy-Item -Path $script:DryRunScript -Destination $script:TestDir -Force
        
        # Copy the Test-ChangelogVersion helper function that the script depends on
        $helperScript = Join-Path $script:RepoRoot 'Release/Test-ChangelogVersion.ps1'
        Copy-Item -Path $helperScript -Destination $script:TestDir -Force
        
        # Create a minimal CHANGELOG.md with the test version to pass changelog verification
        # Place it one level up from TestDir since Test-ChangelogVersion looks for ../CHANGELOG.md
        $changelogContent = @'
# Changelog

## [99.99.99] - 2025-11-05

### Added
- Test version for testing
'@
        $changelogPath = Join-Path (Split-Path $script:TestDir -Parent) 'CHANGELOG.md'
        Set-Content -Path $changelogPath -Value $changelogContent
        
        # Change to test directory
        Set-Location $script:TestDir
    }
    
    AfterEach {
        # Clean up test directory
        Set-Location $script:OriginalLocation
    }
    
    Context 'Changelog verification in dry run' {
        
        It 'Should check if version exists in CHANGELOG.md' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match 'Test-ChangelogVersion'
        }
        
        It 'Should import the Test-ChangelogVersion helper function' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match "Test-ChangelogVersion\.ps1"
        }
        
        It 'Should contain warning message about missing changelog entry' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match 'CHANGELOG.md does not contain an entry'
        }
        
        It 'Should exit with error when changelog check fails' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            
            # Verify the script has the logic to check changelog and error if not found
            $scriptContent | Should -Match 'Test-ChangelogVersion'
            $scriptContent | Should -Match 'exit 1'
        }
    }
    
    Context 'Version checking in dry run' {
        
        It 'Should check if version exists in PowerShell Gallery' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match 'Find-Module'
            $scriptContent | Should -Match 'RequiredVersion'
        }
        
        It 'Should contain warning message about existing version' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match 'already exists in PowerShell Gallery'
        }
        
        It 'Should fail dry run when version exists (simulated)' {
            # Create a test script that simulates finding an existing version
            $testScript = @'
$ErrorActionPreference = 'Stop'
$ModuleVersion = "99.99.99"

try {
    $existingModule = [PSCustomObject]@{
        Name = 'Glooko'
        Version = '99.99.99'
    }
    
    if ($existingModule) {
        Write-Warning "Version $ModuleVersion already exists in PowerShell Gallery!"
        Write-Warning "You must increment the version number before publishing."
        Write-Host "`nDRY RUN FAILED - Version already exists" -ForegroundColor Red
        exit 1
    }
    exit 0
} catch {
    Write-Error "Test failed: $($_.Exception.Message)"
    exit 1
}
'@
            $testScriptPath = Join-Path $TestDrive 'test-dryrun-version-check.ps1'
            Set-Content -Path $testScriptPath -Value $testScript
            
            # Run the test script
            $result = & pwsh -File $testScriptPath 2>&1
            $LASTEXITCODE | Should -Be 1
            $result -join "`n" | Should -Match 'already exists'
        }
        
        It 'Should pass when version does not exist' {
            # Run the actual dry run script with a non-existent version
            # This should succeed because version 99.99.99 should not exist in the gallery
            $result = & pwsh -File (Join-Path $script:TestDir 'Publish-ModuleDryRun.ps1') -ModuleVersion '99.99.99' 2>&1
            $LASTEXITCODE | Should -Be 0
            $result -join "`n" | Should -Match 'DRY RUN COMPLETE'
        }
    }
    
    Context 'Module manifest validation' {
        
        It 'Should test the module manifest' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match 'Test-ModuleManifest'
        }
        
        It 'Should display module information' {
            $result = & pwsh -File (Join-Path $script:TestDir 'Publish-ModuleDryRun.ps1') -ModuleVersion '99.99.99' 2>&1
            $output = $result -join "`n"
            
            $output | Should -Match 'Module Name:'
            $output | Should -Match 'Module Version:'
            $output | Should -Match 'Module Description:'
            $output | Should -Match 'Module Author:'
        }
    }
    
    Context 'Script structure' {
        
        It 'Should accept ModuleVersion parameter' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match '\[Parameter\(Mandatory\)\]'
            $scriptContent | Should -Match '\$ModuleVersion'
        }
        
        It 'Should reference the correct module path' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match 'BuildOutput/Glooko'
        }
        
        It 'Should indicate this is a dry run' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match 'DRY RUN'
        }
    }
    
    Context 'Error handling' {
        
        It 'Should have try-catch block' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match 'try \{'
            $scriptContent | Should -Match 'catch \{'
        }
        
        It 'Should exit with code 1 when version exists' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            # Should exit 1 when existing module is found
            $scriptContent | Should -Match 'exit 1'
        }
        
        It 'Should exit with code 0 on successful dry run' {
            $scriptContent = Get-Content $script:DryRunScript -Raw
            $scriptContent | Should -Match 'exit 0'
        }
        
        It 'Should fail gracefully when manifest is invalid' {
            # Corrupt the manifest
            Set-Content -Path './BuildOutput/Glooko/Glooko.psd1' -Value 'invalid manifest content'
            
            $result = & pwsh -File (Join-Path $script:TestDir 'Publish-ModuleDryRun.ps1') -ModuleVersion '99.99.99' 2>&1
            $LASTEXITCODE | Should -Be 1
        }
    }
    
    Context 'Output messages' {
        
        It 'Should output success message when dry run completes successfully' {
            $result = & pwsh -File (Join-Path $script:TestDir 'Publish-ModuleDryRun.ps1') -ModuleVersion '99.99.99' 2>&1
            $output = $result -join "`n"
            
            $output | Should -Match 'DRY RUN COMPLETE'
        }
        
        It 'Should indicate no actual publishing was performed' {
            $result = & pwsh -File (Join-Path $script:TestDir 'Publish-ModuleDryRun.ps1') -ModuleVersion '99.99.99' 2>&1
            $output = $result -join "`n"
            
            $output | Should -Match 'No actual publishing'
        }
    }
}
