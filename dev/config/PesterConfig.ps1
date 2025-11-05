# Pester 5.x Configuration for Glooko Module - Core Tests (Module and Public/Private functions)

$PesterConfig = New-PesterConfiguration

# Test Discovery - Only core functionality tests
$PesterConfig.Run.Path = @(
    'dev/tests/Import-GlookoCSV.Tests.ps1',
    'dev/tests/Import-GlookoFolder.Tests.ps1',
    'dev/tests/Import-GlookoZip.Tests.ps1',
    'dev/tests/Export-GlookoZipToXlsx.Tests.ps1',
    'dev/tests/Expand-GlookoMetadata.Tests.ps1',
    'dev/tests/Merge-GlookoDatasets.Tests.ps1',
    'dev/tests/Glooko.Dataset.Tests.ps1'
)
$PesterConfig.TestResult.Enabled = $true
$PesterConfig.TestResult.OutputPath = 'dev/tests/TestResults.xml'
$PesterConfig.TestResult.OutputFormat = 'JUnitXml'

# Code Coverage
$PesterConfig.CodeCoverage.Enabled = $true
# $PesterConfig.CodeCoverage.Path = @('Public/*.ps1', 'Private/*.ps1', 'Glooko.psm1')
$PesterConfig.CodeCoverage.Path = @('Public/*.ps1', 'Glooko.psm1')
$PesterConfig.CodeCoverage.OutputPath = 'dev/tests/CodeCoverage.xml'
$PesterConfig.CodeCoverage.OutputFormat = 'JaCoCo'

# Output settings
$PesterConfig.Output.Verbosity = 'Detailed'
$PesterConfig.Should.ErrorAction = 'Stop'

# Run the tests
Invoke-Pester -Configuration $PesterConfig