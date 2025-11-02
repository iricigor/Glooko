# PSScriptAnalyzer Tests for Glooko Module

BeforeAll {
    $ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module (Join-Path $ModuleRoot 'Glooko.psd1') -Force
    
    # Check if PSScriptAnalyzer is available
    if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
        Install-Module -Name PSScriptAnalyzer -Force -SkipPublisherCheck -Scope CurrentUser
    }
    Import-Module PSScriptAnalyzer -Force
}

Describe 'PSScriptAnalyzer Tests' {
    
    BeforeAll {
        $SettingsPath = Join-Path $ModuleRoot 'PSScriptAnalyzerSettings.psd1'
        
        # Paths to analyze
        $PublicPath = Join-Path $ModuleRoot 'Public'
        $PrivatePath = Join-Path $ModuleRoot 'Private'
        $RootModulePath = Join-Path $ModuleRoot 'Glooko.psm1'
    }
    
    Context 'Public functions' {
        It 'Should not have critical errors in Public functions' {
            $results = Invoke-ScriptAnalyzer -Path $PublicPath -Settings $SettingsPath -Recurse -Severity Error
            $results | Should -BeNullOrEmpty -Because "Public functions should not have any errors"
        }
        
        It 'Should not have warnings in Public functions' {
            $results = Invoke-ScriptAnalyzer -Path $PublicPath -Settings $SettingsPath -Recurse -Severity Warning
            $results | Should -BeNullOrEmpty -Because "Public functions should not have any warnings"
        }
    }
    
    Context 'Private functions' {
        It 'Should not have critical errors in Private functions' {
            $results = Invoke-ScriptAnalyzer -Path $PrivatePath -Settings $SettingsPath -Recurse -Severity Error
            $results | Should -BeNullOrEmpty -Because "Private functions should not have any errors"
        }
        
        It 'Should not have warnings in Private functions' {
            $results = Invoke-ScriptAnalyzer -Path $PrivatePath -Settings $SettingsPath -Recurse -Severity Warning
            $results | Should -BeNullOrEmpty -Because "Private functions should not have any warnings"
        }
    }
    
    Context 'Root module' {
        It 'Should not have critical errors in root module' {
            $results = Invoke-ScriptAnalyzer -Path $RootModulePath -Settings $SettingsPath -Severity Error
            $results | Should -BeNullOrEmpty -Because "Root module should not have any errors"
        }
        
        It 'Should not have warnings in root module' {
            $results = Invoke-ScriptAnalyzer -Path $RootModulePath -Settings $SettingsPath -Severity Warning
            $results | Should -BeNullOrEmpty -Because "Root module should not have any warnings"
        }
    }
    
    Context 'Configuration file' {
        It 'Should have a PSScriptAnalyzer settings file' {
            $SettingsPath | Should -Exist -Because "PSScriptAnalyzer settings file should exist"
        }
        
        It 'Should have valid PSScriptAnalyzer settings' {
            { Import-PowerShellDataFile -Path $SettingsPath } | Should -Not -Throw
        }
    }
}
