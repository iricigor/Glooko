# Pester 5.x Configuration for Glooko Module - Other Tests (Build, Publishing, Utilities)

$PesterConfig = New-PesterConfiguration

# Test Discovery - Only other functionality tests
$PesterConfig.Run.Path = @(
    'Tests/Build.Tests.ps1',
    'Tests/Publish-ModuleDryRun.Tests.ps1',
    'Tests/Publish-ModuleToGallery.Tests.ps1',
    'Tests/Update-Changelog.Tests.ps1',
    'Tests/Test-ChangelogVersion.Tests.ps1'
)

$PesterConfig.TestResult.Enabled = $true
$PesterConfig.TestResult.OutputPath = 'Tests/TestResults.xml'
$PesterConfig.TestResult.OutputFormat = 'JUnitXml'

# Code Coverage - Not needed for build/utility tests
$PesterConfig.CodeCoverage.Enabled = $false

# Output settings
$PesterConfig.Output.Verbosity = 'Detailed'
$PesterConfig.Should.ErrorAction = 'Stop'

# Run the tests
Invoke-Pester -Configuration $PesterConfig
