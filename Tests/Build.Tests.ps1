BeforeAll {
    # Store original location
    $script:OriginalLocation = Get-Location
    $script:RepoRoot = Split-Path -Parent $PSScriptRoot
    $script:BuildScript = Join-Path $script:RepoRoot 'Build.ps1'
}

AfterAll {
    # Restore original location
    Set-Location $script:OriginalLocation
}

Describe 'Build.ps1' {
    
    BeforeEach {
        # Create a temporary directory for testing using Pester's TestDrive
        # TestDrive provides automatic cleanup and isolation
        $script:TestDir = New-Item -Path (Join-Path $TestDrive ([System.Guid]::NewGuid())) -ItemType Directory
        
        # Create minimal module structure for testing
        New-Item -Path (Join-Path $script:TestDir 'Public') -ItemType Directory | Out-Null
        New-Item -Path (Join-Path $script:TestDir 'Private') -ItemType Directory | Out-Null
        
        # Create test files
        Set-Content -Path (Join-Path $script:TestDir 'Glooko.psm1') -Value '# Test module'
        Set-Content -Path (Join-Path $script:TestDir 'LICENSE') -Value 'MIT License'
        Set-Content -Path (Join-Path $script:TestDir 'Public/Test-Function.ps1') -Value 'function Test-Function { }'
        Set-Content -Path (Join-Path $script:TestDir 'Private/Test-Helper.ps1') -Value 'function Test-Helper { }'
        
        # Create a basic module manifest
        $manifestPath = Join-Path $script:TestDir 'Glooko.psd1'
        @"
@{
    RootModule = 'Glooko.psm1'
    ModuleVersion = '1.0'
    GUID = '02ff76d0-8773-4042-a1c6-343cc40deba5'
    Author = 'Test'
    Description = 'Test module'
    PowerShellVersion = '7.0'
    FunctionsToExport = '*'
}
"@ | Set-Content -Path $manifestPath
        
        # Copy the build script to test directory
        Copy-Item -Path $script:BuildScript -Destination $script:TestDir -Force
        
        # Change to test directory
        Set-Location $script:TestDir
    }
    
    AfterEach {
        # Clean up test directory
        Set-Location $script:OriginalLocation
        # TestDrive handles cleanup automatically, but we still need to restore location
    }
    
    Context 'First build' {
        
        It 'Should create BuildOutput directory' {
            ./Build.ps1
            
            Test-Path './BuildOutput' | Should -Be $true
        }
        
        It 'Should create version file' {
            ./Build.ps1
            
            Test-Path './.version' | Should -Be $true
        }
        
        It 'Should start with build number 0' {
            ./Build.ps1
            
            $version = Get-Content './.version' | ConvertFrom-Json
            $version.BuildNumber | Should -Be 0
            $version.Version | Should -Be '1.0.0'
        }
        
        It 'Should copy all runtime files' {
            ./Build.ps1
            
            Test-Path './BuildOutput/Glooko.psd1' | Should -Be $true
            Test-Path './BuildOutput/Glooko.psm1' | Should -Be $true
            Test-Path './BuildOutput/LICENSE' | Should -Be $true
            Test-Path './BuildOutput/Public/Test-Function.ps1' | Should -Be $true
            Test-Path './BuildOutput/Private/Test-Helper.ps1' | Should -Be $true
        }
        
        It 'Should update module manifest version' {
            ./Build.ps1
            
            $manifest = Import-PowerShellDataFile -Path './BuildOutput/Glooko.psd1'
            $manifest.ModuleVersion | Should -Be '1.0.0'
        }
        
        It 'Should create BuildInfo.json' {
            ./Build.ps1
            
            Test-Path './BuildOutput/BuildInfo.json' | Should -Be $true
            
            $buildInfo = Get-Content './BuildOutput/BuildInfo.json' | ConvertFrom-Json
            $buildInfo.Version | Should -Be '1.0.0'
            $buildInfo.MajorMinor | Should -Be '1.0'
            $buildInfo.BuildNumber | Should -Be 0
        }
    }
    
    Context 'Build number increment' {
        
        It 'Should increment build number on subsequent builds' {
            ./Build.ps1
            $version1 = Get-Content './.version' | ConvertFrom-Json
            
            ./Build.ps1
            $version2 = Get-Content './.version' | ConvertFrom-Json
            
            $version2.BuildNumber | Should -Be ($version1.BuildNumber + 1)
            $version2.Version | Should -Be '1.0.1'
        }
        
        It 'Should increment from existing build number' {
            # Simulate previous build with fixed timestamp for deterministic testing
            @{
                Version = '1.0.5'
                BuildDate = '2023-01-01T00:00:00.0000000Z'
                MajorMinor = '1.0'
                BuildNumber = 5
            } | ConvertTo-Json | Set-Content './.version'
            
            ./Build.ps1
            
            $version = Get-Content './.version' | ConvertFrom-Json
            $version.BuildNumber | Should -Be 6
            $version.Version | Should -Be '1.0.6'
        }
    }
    
    Context 'Version change handling' {
        
        It 'Should reset build number when major.minor changes' {
            # Simulate previous build with different version using fixed timestamp
            @{
                Version = '1.0.10'
                BuildDate = '2023-01-01T00:00:00.0000000Z'
                MajorMinor = '1.0'
                BuildNumber = 10
            } | ConvertTo-Json | Set-Content './.version'
            
            # Update module manifest to new version
            $manifestPath = Join-Path $script:TestDir 'Glooko.psd1'
            $content = Get-Content $manifestPath -Raw
            $content = $content -replace "ModuleVersion = '1.0'", "ModuleVersion = '1.1'"
            Set-Content -Path $manifestPath -Value $content
            
            ./Build.ps1
            
            $version = Get-Content './.version' | ConvertFrom-Json
            $version.BuildNumber | Should -Be 0
            $version.Version | Should -Be '1.1.0'
            $version.MajorMinor | Should -Be '1.1'
        }
    }
    
    Context 'Error handling' {
        
        It 'Should fail if module manifest is missing' {
            Remove-Item './Glooko.psd1' -Force
            
            { ./Build.ps1 -ErrorAction Stop } | Should -Throw '*Module manifest not found*'
        }
        
        It 'Should fail if module version is not in major.minor format' {
            # Update manifest with invalid version
            $manifestPath = Join-Path $script:TestDir 'Glooko.psd1'
            $content = Get-Content $manifestPath -Raw
            $content = $content -replace "ModuleVersion = '1.0'", "ModuleVersion = '1.0.0'"
            Set-Content -Path $manifestPath -Value $content
            
            { ./Build.ps1 -ErrorAction Stop } | Should -Throw '*major.minor format*'
        }
    }
    
    Context 'Custom output path' {
        
        It 'Should create artifact in custom output path' {
            ./Build.ps1 -OutputPath './CustomOutput'
            
            Test-Path './CustomOutput' | Should -Be $true
            Test-Path './CustomOutput/Glooko.psd1' | Should -Be $true
        }
    }
}
