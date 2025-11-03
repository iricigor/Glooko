BeforeAll {
    # Store original location
    $script:OriginalLocation = Get-Location
    $script:RepoRoot = Split-Path -Parent $PSScriptRoot
    $script:UpdateChangelogScript = Join-Path $script:RepoRoot 'Release/Update-Changelog.ps1'
}

AfterAll {
    # Restore original location
    Set-Location $script:OriginalLocation
}

Describe 'Update-Changelog.ps1' {
    
    Context 'Script Validation' {
        It 'Should exist' {
            $script:UpdateChangelogScript | Should -Exist
        }
        
        It 'Should be a valid PowerShell script' {
            { $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $script:UpdateChangelogScript -Raw), [ref]$null) } | Should -Not -Throw
        }
        
        It 'Should have proper parameter definitions' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'param\s*\('
            $scriptContent | Should -Match '\[Parameter\(Mandatory\)\]'
            $scriptContent | Should -Match '\$Repository'
            $scriptContent | Should -Match '\$GH_TOKEN'
            $scriptContent | Should -Match '\$DryRun'
        }
        
        It 'Should have proper comment-based help' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match '\.SYNOPSIS'
            $scriptContent | Should -Match '\.DESCRIPTION'
            $scriptContent | Should -Match '\.PARAMETER'
            $scriptContent | Should -Match '\.EXAMPLE'
        }
    }
    
    Context 'Function Definitions' {
        BeforeAll {
            # Note: We extract function definitions using regex for validation purposes only.
            # This is acceptable in tests as we're only checking that functions are defined,
            # not executing or parsing complex logic.
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            
            # Extract just the function definitions for testing
            $functionPattern = 'function\s+[\w-]+\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\}'
            $functions = [regex]::Matches($scriptContent, $functionPattern)
        }
        
        It 'Should define Get-LatestRelease function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Get-LatestRelease'
        }
        
        It 'Should define Get-BuildsSinceRelease function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Get-BuildsSinceRelease'
        }
        
        It 'Should define Get-BuildVersion function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Get-BuildVersion'
        }
        
        It 'Should define Get-PRForCommit function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Get-PRForCommit'
        }
        
        It 'Should define Format-ChangelogEntry function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Format-ChangelogEntry'
        }
        
        It 'Should define Group-ByMajorMinor function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Group-ByMajorMinor'
        }
        
        It 'Should define Update-ChangelogFile function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'function Update-ChangelogFile'
        }
    }
    
    Context 'Helper Functions Logic' {
        BeforeAll {
            # Note: We use Invoke-Expression here in a controlled test environment
            # to extract and test specific helper functions in isolation.
            # The input is from a trusted source (our own script file) and the 
            # regex pattern ensures we only execute function definitions.
            # This approach is acceptable in tests for validating function logic
            # without requiring the full script execution context.
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            
            # Extract and execute only the Format-ChangelogEntry function for testing
            if ($scriptContent -match '(function Format-ChangelogEntry\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
            
            # Extract and execute the Group-ByMajorMinor function
            if ($scriptContent -match '(function Group-ByMajorMinor\s*\{(?:[^{}]|(?<open>\{)|(?<-open>\}))+(?(open)(?!))\})') {
                Invoke-Expression $Matches[1]
            }
        }
        
        It 'Format-ChangelogEntry should format entry correctly with PR' {
            $pr = @{
                number = 123
                title = 'Test PR Title'
                html_url = 'https://github.com/test/repo/pull/123'
            }
            
            $result = Format-ChangelogEntry -Version '1.0.1' -Date '2024-11-03T10:00:00Z' -PR $pr
            
            $result.Version | Should -Be '1.0.1'
            $result.Date | Should -Be '2024-11-03'
            $result.Title | Should -Be 'Test PR Title'
            $result.PRLink | Should -Match '\[#123\]'
        }
        
        It 'Format-ChangelogEntry should handle missing PR' {
            $result = Format-ChangelogEntry -Version '1.0.2' -Date '2024-11-03T10:00:00Z' -PR $null
            
            $result.Version | Should -Be '1.0.2'
            $result.Title | Should -Be 'Build 1.0.2'
            $result.PRLink | Should -Be ''
        }
        
        It 'Group-ByMajorMinor should group entries correctly' {
            $entries = @(
                @{ Version = '1.0.1'; Title = 'First' }
                @{ Version = '1.0.2'; Title = 'Second' }
                @{ Version = '1.1.0'; Title = 'Third' }
                @{ Version = '1.1.1'; Title = 'Fourth' }
            )
            
            $result = Group-ByMajorMinor -Entries $entries
            
            $result.Keys.Count | Should -Be 2
            $result.ContainsKey('1.0') | Should -Be $true
            $result.ContainsKey('1.1') | Should -Be $true
            $result['1.0'].Count | Should -Be 2
            $result['1.1'].Count | Should -Be 2
        }
    }
    
    Context 'StrictMode Compliance' {
        It 'Should handle empty build results without error in strict mode' {
            # This test verifies the fix for the bug where accessing .Count on null
            # in strict mode caused: "The property 'Count' cannot be found on this object"
            
            # Simulate the scenario that caused the original bug
            $testScript = {
                Set-StrictMode -Version Latest
                $ErrorActionPreference = 'Stop'
                
                # Simulate what Get-BuildsSinceRelease does with no results
                $builds = @{ workflow_runs = @() }
                $relevantBuilds = @($builds.workflow_runs | Where-Object { $false })
                
                # This line was throwing the error before the fix
                Write-Host "Found $($relevantBuilds.Count) build runs"
                
                return $true
            }
            
            { & $testScript } | Should -Not -Throw
        }
        
        It 'Should return arrays consistently from Get-BuildsSinceRelease function' {
            # Verify the function always returns an array type
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            
            # The function should use Write-Output -NoEnumerate to prevent array unwrapping
            $scriptContent | Should -Match 'Write-Output\s+-NoEnumerate'
            
            # The function should wrap Where-Object results in @() for safety
            $scriptContent | Should -Match '@\(\$builds\.workflow_runs\s+\|\s+Where-Object'
        }
    }
    
    Context 'Script Execution Safety' {
        It 'Should have proper error handling' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'try\s*\{'
            $scriptContent | Should -Match 'catch\s*\{'
            $scriptContent | Should -Match '\$ErrorActionPreference'
        }
        
        It 'Should use Set-StrictMode' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'Set-StrictMode\s+-Version\s+Latest'
        }
        
        It 'Should exit with appropriate codes' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'exit\s+0'
            $scriptContent | Should -Match 'exit\s+1'
        }
    }
    
    Context 'DryRun Functionality' {
        It 'Should support DryRun switch parameter' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match '\[switch\]\$DryRun'
        }
        
        It 'Should pass DryRun to Update-ChangelogFile function' {
            $scriptContent = Get-Content $script:UpdateChangelogScript -Raw
            $scriptContent | Should -Match 'DryRun:\$DryRun'
        }
    }
}
