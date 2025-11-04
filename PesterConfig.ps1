# Pester 5.x Configuration for Glooko Module - Core Tests (Module and Public/Private functions)

$PesterConfig = New-PesterConfiguration

# Test Discovery - Only core functionality tests
$PesterConfig.Run.Path = @(
    'Tests/PSScriptAnalyzer.Tests.ps1',
    'Tests/Import-GlookoCSV.Tests.ps1',
    'Tests/Import-GlookoFolder.Tests.ps1',
    'Tests/Import-GlookoZip.Tests.ps1',
    'Tests/Export-GlookoZipToXlsx.Tests.ps1',
    'Tests/Expand-GlookoMetadata.Tests.ps1',
    'Tests/Merge-GlookoDatasets.Tests.ps1',
    'Tests/Glooko.Dataset.Tests.ps1'
)
$PesterConfig.TestResult.Enabled = $true
$PesterConfig.TestResult.OutputPath = 'Tests/TestResults.xml'
$PesterConfig.TestResult.OutputFormat = 'JUnitXml'

# Code Coverage
$PesterConfig.CodeCoverage.Enabled = $true
# $PesterConfig.CodeCoverage.Path = @('Public/*.ps1', 'Private/*.ps1', 'Glooko.psm1')
$PesterConfig.CodeCoverage.Path = @('Public/*.ps1', 'Glooko.psm1')
$PesterConfig.CodeCoverage.OutputPath = 'Tests/CodeCoverage.xml'
$PesterConfig.CodeCoverage.OutputFormat = 'JaCoCo'

# Output settings
$PesterConfig.Output.Verbosity = 'Detailed'
$PesterConfig.Should.ErrorAction = 'Stop'

# Run the tests
Invoke-Pester -Configuration $PesterConfig