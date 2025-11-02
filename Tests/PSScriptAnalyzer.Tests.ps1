# PSScriptAnalyzer Tests for Glooko Module

BeforeAll {
    $script:ModuleRoot = Split-Path $PSScriptRoot -Parent
    Import-Module (Join-Path $script:ModuleRoot 'Glooko.psd1') -Force
    
    # Check if PSScriptAnalyzer is available
    if (-not (Get-Module -ListAvailable -Name PSScriptAnalyzer)) {
        Install-Module -Name PSScriptAnalyzer -Force -SkipPublisherCheck -Scope CurrentUser
    }
    Import-Module PSScriptAnalyzer -Force
}

Describe 'PSScriptAnalyzer Tests' {
    
    BeforeAll {
        $script:SettingsPath = Join-Path $script:ModuleRoot 'PSScriptAnalyzerSettings.psd1'
        
        # Paths to analyze
        $script:PublicPath = Join-Path $script:ModuleRoot 'Public'
        $script:PrivatePath = Join-Path $script:ModuleRoot 'Private'
        $script:RootModulePath = Join-Path $script:ModuleRoot 'Glooko.psm1'
    }
    
    Context 'Public functions' {
        It 'Should not have critical errors in Public functions' {
            $results = Invoke-ScriptAnalyzer -Path $script:PublicPath -Settings $script:SettingsPath -Recurse -Severity Error
            $results | Should -BeNullOrEmpty -Because "Public functions should not have any errors"
        }
        
        It 'Should not have warnings in Public functions' {
            $results = Invoke-ScriptAnalyzer -Path $script:PublicPath -Settings $script:SettingsPath -Recurse -Severity Warning
            $results | Should -BeNullOrEmpty -Because "Public functions should not have any warnings"
        }
    }
    
    Context 'Private functions' {
        It 'Should not have critical errors in Private functions' {
            $results = Invoke-ScriptAnalyzer -Path $script:PrivatePath -Settings $script:SettingsPath -Recurse -Severity Error
            $results | Should -BeNullOrEmpty -Because "Private functions should not have any errors"
        }
        
        It 'Should not have warnings in Private functions' {
            $results = Invoke-ScriptAnalyzer -Path $script:PrivatePath -Settings $script:SettingsPath -Recurse -Severity Warning
            $results | Should -BeNullOrEmpty -Because "Private functions should not have any warnings"
        }
    }
    
    Context 'Root module' {
        It 'Should not have critical errors in root module' {
            $results = Invoke-ScriptAnalyzer -Path $script:RootModulePath -Settings $script:SettingsPath -Severity Error
            $results | Should -BeNullOrEmpty -Because "Root module should not have any errors"
        }
        
        It 'Should not have warnings in root module' {
            $results = Invoke-ScriptAnalyzer -Path $script:RootModulePath -Settings $script:SettingsPath -Severity Warning
            $results | Should -BeNullOrEmpty -Because "Root module should not have any warnings"
        }
    }
    
    Context 'Configuration file' {
        It 'Should have a PSScriptAnalyzer settings file' {
            $script:SettingsPath | Should -Exist -Because "PSScriptAnalyzer settings file should exist"
        }
        
        It 'Should have valid PSScriptAnalyzer settings' {
            { Import-PowerShellDataFile -Path $script:SettingsPath } | Should -Not -Throw
        }
    }
}
