BeforeAll {
    # Import test helpers
    . (Join-Path $PSScriptRoot 'Helpers' 'TestHelpers.ps1')
    
    # Path to the scripts being tested
    $Script:VerifyChecksumScript = Join-Path $PSScriptRoot '..' 'Release' 'Verify-ModuleChecksum.ps1'
    $Script:GetChecksumScript = Join-Path $PSScriptRoot '..' 'Release' 'Get-ModuleChecksum.ps1'
}

Describe 'Verify-ModuleChecksum' {
    
    Context 'Force flag behavior' {
        
        It 'Should skip verification when Force flag is used' {
            # This should always pass with -Force, regardless of checksum
            $result = & $Script:VerifyChecksumScript -ModulePath (Join-Path $PSScriptRoot '..') -Force -ErrorAction Stop
            $LASTEXITCODE | Should -Be 0
        }
    }
    
    Context 'Mock verification (unit tests)' {
        
        BeforeEach {
            # Create a test module structure in TestDrive
            $testModulePath = Join-Path $TestDrive 'BuildOutput'
            New-Item -Path $testModulePath -ItemType Directory -Force | Out-Null
            New-Item -Path "$testModulePath/Public" -ItemType Directory -Force | Out-Null
            New-Item -Path "$testModulePath/Private" -ItemType Directory -Force | Out-Null
            
            # Create minimal module files
            Set-Content -Path "$testModulePath/Glooko.psm1" -Value "# Module file`nfunction Test { 'test' }"
            Set-Content -Path "$testModulePath/Glooko.Types.ps1xml" -Value "<Types></Types>"
            Set-Content -Path "$testModulePath/Glooko.Format.ps1xml" -Value "<Format></Format>"
            Set-Content -Path "$testModulePath/Public/Test-Function.ps1" -Value "function Test-Function { 'test' }"
            Set-Content -Path "$testModulePath/Private/Test-Private.ps1" -Value "function Test-Private { 'private' }"
            
            # Create module manifest
            $manifest = @"
@{
    ModuleVersion = '1.0.0'
    RootModule = 'Glooko.psm1'
}
"@
            Set-Content -Path "$testModulePath/Glooko.psd1" -Value $manifest
            
            $Script:TestBuildPath = $testModulePath
        }
        
        It 'Should calculate checksum for BuildOutput module' {
            # Just verify that checksum can be calculated
            $checksum = & $Script:GetChecksumScript -ModulePath $Script:TestBuildPath
            
            $checksum | Should -Not -BeNullOrEmpty
            $checksum.Checksum | Should -Match '^[0-9A-F]{64}$'
        }
        
        It 'Should handle empty PowerShell Gallery gracefully' {
            # This test verifies the script doesn't fail when no versions are found
            # In real execution, Find-Module might return null for a non-existent module
            # We can't easily mock this in a script-based test, so this is a basic structure test
            
            # Verify the script exists and has proper structure
            Test-Path $Script:VerifyChecksumScript | Should -Be $true
            
            # Check that script contains error handling for empty gallery
            $scriptContent = Get-Content $Script:VerifyChecksumScript -Raw
            $scriptContent | Should -Match 'publishedVersions'
            $scriptContent | Should -Match 'if.*not.*publishedVersions'
        }
    }
    
    Context 'Script structure validation' {
        
        It 'Should accept Force parameter' {
            $scriptContent = Get-Content $Script:VerifyChecksumScript -Raw
            $scriptContent | Should -Match '\[switch\]\$Force'
        }
        
        It 'Should accept ModulePath parameter' {
            $scriptContent = Get-Content $Script:VerifyChecksumScript -Raw
            $scriptContent | Should -Match '\[string\]\$ModulePath'
        }
        
        It 'Should call Get-ModuleChecksum script' {
            $scriptContent = Get-Content $Script:VerifyChecksumScript -Raw
            $scriptContent | Should -Match 'Get-ModuleChecksum\.ps1'
        }
        
        It 'Should check PowerShell Gallery for published versions' {
            $scriptContent = Get-Content $Script:VerifyChecksumScript -Raw
            $scriptContent | Should -Match 'Find-Module'
            $scriptContent | Should -Match 'Save-Module'
        }
        
        It 'Should provide clear error messages for checksum match' {
            $scriptContent = Get-Content $Script:VerifyChecksumScript -Raw
            $scriptContent | Should -Match 'CHECKSUM MATCH'
            $scriptContent | Should -Match 'identical'
        }
        
        It 'Should suggest using Force flag when checksum matches' {
            $scriptContent = Get-Content $Script:VerifyChecksumScript -Raw
            $scriptContent | Should -Match '-Force'
            $scriptContent | Should -Match 'bypass'
        }
    }
}
