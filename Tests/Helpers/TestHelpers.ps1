# Test data creation helpers for Import-GlookoCSV tests

# Import helper functions from the current folder
Get-ChildItem -Path $PSScriptRoot -Filter '*.ps1' | Where-Object { $_.Name -ne 'TestHelpers.ps1' } | ForEach-Object {
    . $_.FullName
}