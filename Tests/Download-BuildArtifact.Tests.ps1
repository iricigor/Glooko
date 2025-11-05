BeforeAll {
    # Store the path to the script
    $script:ScriptPath = "$PSScriptRoot/../Release/Download-BuildArtifact.ps1"
}

Describe 'Download-BuildArtifact.ps1' {
    Context 'Script structure' {
        It 'Should exist' {
            $script:ScriptPath | Should -Exist
        }

        It 'Should have proper parameter definitions' {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match 'param\s*\('
            $scriptContent | Should -Match '\[Parameter.*\]\s*\[string\]\$Version'
            $scriptContent | Should -Match '\[Parameter\(Mandatory\)\]\s*\[string\]\$Repository'
            $scriptContent | Should -Match '\[Parameter\(Mandatory\)\]\s*\[string\]\$GH_TOKEN'
        }

        It 'Should import Get-LatestChangelogVersion helper function' {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match 'Get-LatestChangelogVersion\.ps1'
        }

        It 'Should have strict mode and error handling' {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match 'Set-StrictMode -Version Latest'
            $scriptContent | Should -Match '\$ErrorActionPreference\s*=\s*[''"]Stop[''"]'
            $scriptContent | Should -Match 'try\s*\{'
            $scriptContent | Should -Match 'catch\s*\{'
        }
    }

    Context 'Version parameter handling' {
        It 'Should accept a specific version parameter' {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match 'if\s*\(\$Version\)'
            $scriptContent | Should -Match 'Downloading specific version'
        }

        It 'Should use CHANGELOG version when version not specified' {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match 'Get-LatestChangelogVersion'
            $scriptContent | Should -Match 'Latest version in CHANGELOG\.md'
        }

        It 'Should fall back to latest build if CHANGELOG version not found' {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match 'Falling back to latest build artifact'
        }
    }

    Context 'Artifact naming' {
        It 'Should construct correct artifact name with version' {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match '\$artifactName\s*=\s*"Glooko-Module-\$'
        }
    }

    Context 'Output structure' {
        It 'Should create BuildOutput/Glooko directory structure' {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match '\./BuildOutput/Glooko'
        }
    }

    Context 'Help documentation' {
        It 'Should have comment-based help' {
            $scriptContent = Get-Content $script:ScriptPath -Raw
            $scriptContent | Should -Match '\.SYNOPSIS'
            $scriptContent | Should -Match '\.DESCRIPTION'
            $scriptContent | Should -Match '\.PARAMETER'
            $scriptContent | Should -Match '\.EXAMPLE'
        }
    }
}
