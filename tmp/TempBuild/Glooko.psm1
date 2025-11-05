#
# Module manifest for Glooko PowerShell module
#

# Get public and private function definition files
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
Foreach($import in @($Public + $Private))
{
    Try
    {
        Write-Verbose "Importing $($import.FullName)"
        . $import.FullName
    }
    Catch
    {
        Write-Error "Failed to import function $($import.FullName): $_"
    }
}

# Export public functions
Export-ModuleMember -Function $Public.BaseName

# Export aliases if any
# Export-ModuleMember -Alias *