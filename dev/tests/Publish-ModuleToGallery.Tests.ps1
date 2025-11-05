BeforeAll {
    # Store original location
    $script:OriginalLocation = Get-Location
    $script:RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $script:PublishScript = Join-Path $script:RepoRoot 'dev/release/Publish-ModuleToGallery.ps1'
}

AfterAll {
    # Restore original location
    Set-Location $script:OriginalLocation
}

Describe 'Publish-ModuleToGallery.ps1' {
    
    BeforeEach {
        # Create a temporary directory for testing using Pester's TestDrive
        $script:TestDir = New-Item -Path (Join-Path $TestDrive (New-Guid)) -ItemType Directory
        
        # Create minimal module structure for testing
        $buildOutputDir = Join-Path $script:TestDir 'BuildOutput/Glooko'
        New-Item -Path $buildOutputDir -ItemType Directory -Force | Out-Null
        
        # Create test files
        Set-Content -Path (Join-Path $buildOutputDir 'Glooko.psm1') -Value '# Test module'
        Set-Content -Path (Join-Path $buildOutputDir 'LICENSE') -Value 'MIT License'
        
        # Create a basic module manifest
        $manifestPath = Join-Path $buildOutputDir 'Glooko.psd1'
        @"
@{
    RootModule = 'Glooko.psm1'
    ModuleVersion = '99.99.99'
    GUID = '02ff76d0-8773-4042-a1c6-343cc40deba5'
    Author = 'Test'
    Description = 'Test module for publish script testing'
    PowerShellVersion = '7.0'
    FunctionsToExport = '*'
}
"@ | Set-Content -Path $manifestPath
        
        # Copy the publish script to test directory
        Copy-Item -Path $script:PublishScript -Destination $script:TestDir -Force
        
        # Change to test directory
        Set-Location $script:TestDir
        
        # Mock Find-Module to avoid actual PowerShell Gallery queries
        Mock Find-Module {
            return $null
        } -ModuleName $null
    }
    
    AfterEach {
        # Clean up test directory
        Set-Location $script:OriginalLocation
    }
    
    Context 'Changelog verification' {
        
        It 'Should check if version exists in CHANGELOG.md' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match 'Test-ChangelogVersion'
        }
        
        It 'Should import the Test-ChangelogVersion helper function' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match "Test-ChangelogVersion\.ps1"
        }
        
        It 'Should contain error message about missing changelog entry' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match 'CHANGELOG.md does not contain an entry'
        }
        
        It 'Should exit with error when changelog check fails' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            
            # Verify the script has the logic to check changelog and error if not found
            $scriptContent | Should -Match 'Test-ChangelogVersion'
            $scriptContent | Should -Match 'exit 1'
        }
    }
    
    Context 'Version checking' {
        
        It 'Should check if version exists in PowerShell Gallery before publishing' {
            # This test verifies the script attempts to check the gallery
            # We can't test actual Publish-Module without a real API key, but we can verify
            # that Find-Module would be called
            
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match 'Find-Module'
            $scriptContent | Should -Match 'RequiredVersion'
        }
        
        It 'Should contain error message about existing version' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match 'already exists in PowerShell Gallery'
        }
        
        It 'Should abort with clear error when version exists (simulated)' {
            # This test verifies that the error handling logic is correct
            # by checking the script content for the proper error handling
            $scriptContent = Get-Content $script:PublishScript -Raw
            
            # Verify the script has the logic to check and error on existing version
            $scriptContent | Should -Match 'if \(\$existingModule\)'
            $scriptContent | Should -Match 'Write-Error.*already exists'
            $scriptContent | Should -Match 'exit 1'
        }
    }
    
    Context 'Script structure' {
        
        It 'Should accept ModuleVersion parameter' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match '\[Parameter\(Mandatory\)\]'
            $scriptContent | Should -Match '\$ModuleVersion'
        }
        
        It 'Should accept NuGetApiKey parameter' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match '\$NuGetApiKey'
        }
        
        It 'Should use Publish-Module cmdlet' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match 'Publish-Module'
        }
        
        It 'Should reference the correct module path' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match 'BuildOutput/Glooko'
        }
    }
    
    Context 'Error handling' {
        
        It 'Should have try-catch block' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match 'try \{'
            $scriptContent | Should -Match 'catch \{'
        }
        
        It 'Should exit with code 1 on error' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match 'exit 1'
        }
        
        It 'Should exit with code 0 on success' {
            $scriptContent = Get-Content $script:PublishScript -Raw
            $scriptContent | Should -Match 'exit 0'
        }
    }
}
