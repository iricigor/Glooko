# Pester 5.x Configuration for Glooko Module Tests

$PesterConfig = New-PesterConfiguration

# Test Discovery
$PesterConfig.Run.Path = @('Tests')
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