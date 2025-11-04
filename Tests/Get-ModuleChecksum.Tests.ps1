BeforeAll {
    # Import test helpers
    . (Join-Path $PSScriptRoot 'Helpers' 'TestHelpers.ps1')
    
    # Path to the script being tested
    $Script:GetChecksumScript = Join-Path $PSScriptRoot '..' 'Release' 'Get-ModuleChecksum.ps1'
}

Describe 'Get-ModuleChecksum' {
    
    Context 'Basic functionality' {
        
        It 'Should calculate checksum for module source files' {
            $result = & $Script:GetChecksumScript -ModulePath (Join-Path $PSScriptRoot '..')
            
            $result | Should -Not -BeNullOrEmpty
            $result.Checksum | Should -Not -BeNullOrEmpty
            $result.Checksum | Should -Match '^[0-9A-F]{64}$'
            $result.FileCount | Should -BeGreaterThan 0
            $result.Files | Should -Not -BeNullOrEmpty
        }
        
        It 'Should produce consistent checksums for the same files' {
            $result1 = & $Script:GetChecksumScript -ModulePath (Join-Path $PSScriptRoot '..')
            $result2 = & $Script:GetChecksumScript -ModulePath (Join-Path $PSScriptRoot '..')
            
            $result1.Checksum | Should -Be $result2.Checksum
        }
        
        It 'Should include correct runtime files in checksum' {
            $result = & $Script:GetChecksumScript -ModulePath (Join-Path $PSScriptRoot '..')
            
            $filePaths = $result.Files | ForEach-Object { $_.Path }
            
            # Should include module manifest
            $filePaths | Should -Contain 'Glooko.psd1'
            
            # Should include module file
            $filePaths | Should -Contain 'Glooko.psm1'
            
            # Should include format files
            $filePaths | Should -Contain 'Glooko.Types.ps1xml'
            $filePaths | Should -Contain 'Glooko.Format.ps1xml'
            
            # Should include Public functions
            $publicFiles = $filePaths | Where-Object { $_ -like 'Public/*.ps1' }
            $publicFiles | Should -Not -BeNullOrEmpty
            
            # Should include Private functions
            $privateFiles = $filePaths | Where-Object { $_ -like 'Private/*.ps1' }
            $privateFiles | Should -Not -BeNullOrEmpty
        }
    }
    
    Context 'Version stripping' {
        
        BeforeEach {
            # Create a test module structure in TestDrive
            $testModulePath = Join-Path $TestDrive 'TestModule'
            New-Item -Path $testModulePath -ItemType Directory -Force | Out-Null
            New-Item -Path "$testModulePath/Public" -ItemType Directory -Force | Out-Null
            New-Item -Path "$testModulePath/Private" -ItemType Directory -Force | Out-Null
            
            # Create minimal module files
            Set-Content -Path "$testModulePath/Glooko.psm1" -Value "# Module file"
            Set-Content -Path "$testModulePath/Glooko.Types.ps1xml" -Value "<Types></Types>"
            Set-Content -Path "$testModulePath/Glooko.Format.ps1xml" -Value "<Format></Format>"
            Set-Content -Path "$testModulePath/Public/Test-Function.ps1" -Value "function Test-Function { 'test' }"
            Set-Content -Path "$testModulePath/Private/Test-Private.ps1" -Value "function Test-Private { 'private' }"
            
            # Create module manifest with version 1.0.0
            $manifest1 = @"
@{
    ModuleVersion = '1.0.0'
    RootModule = 'Glooko.psm1'
}
"@
            Set-Content -Path "$testModulePath/Glooko.psd1" -Value $manifest1
            
            $Script:TestModulePath1 = $testModulePath
        }
        
        It 'Should produce same checksum regardless of version in manifest' {
            # Calculate checksum with version 1.0.0
            $checksum1 = & $Script:GetChecksumScript -ModulePath $Script:TestModulePath1
            
            # Update manifest to version 2.5.3
            $manifest2 = @"
@{
    ModuleVersion = '2.5.3'
    RootModule = 'Glooko.psm1'
}
"@
            Set-Content -Path "$Script:TestModulePath1/Glooko.psd1" -Value $manifest2
            
            # Calculate checksum with version 2.5.3
            $checksum2 = & $Script:GetChecksumScript -ModulePath $Script:TestModulePath1
            
            # Checksums should be identical
            $checksum1.Checksum | Should -Be $checksum2.Checksum
        }
        
        It 'Should produce different checksum when code changes' {
            # Calculate initial checksum
            $checksum1 = & $Script:GetChecksumScript -ModulePath $Script:TestModulePath1
            
            # Modify a Public function
            Set-Content -Path "$Script:TestModulePath1/Public/Test-Function.ps1" -Value "function Test-Function { 'modified' }"
            
            # Calculate new checksum
            $checksum2 = & $Script:GetChecksumScript -ModulePath $Script:TestModulePath1
            
            # Checksums should be different
            $checksum1.Checksum | Should -Not -Be $checksum2.Checksum
        }
    }
    
    Context 'Error handling' {
        
        It 'Should error for non-existent path' {
            { & $Script:GetChecksumScript -ModulePath 'C:\NonExistent\Path' -ErrorAction Stop } | Should -Throw
        }
        
        It 'Should error when no runtime files found' {
            $emptyDir = Join-Path $TestDrive 'EmptyModule'
            New-Item -Path $emptyDir -ItemType Directory -Force | Out-Null
            
            { & $Script:GetChecksumScript -ModulePath $emptyDir -ErrorAction Stop } | Should -Throw
        }
    }
}
