#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs required PowerShell modules for testing.

.DESCRIPTION
    This script installs the required PowerShell modules for running tests:
    - Pester 5.x for testing
    - ImportExcel for Export-GlookoZipToXlsx tests
    - PSScriptAnalyzer for code quality checks

.EXAMPLE
    ./.github/scripts/Install-TestModules.ps1
    Installs all required modules
#>

[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Install-ModuleVerbose {
    <#
    .SYNOPSIS
        Installs a PowerShell module with verbose output if not already installed.
    
    .PARAMETER Name
        The name of the module to install.
    
    .PARAMETER MinimumVersion
        Optional minimum version required for the module.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter()]
        [string]$MinimumVersion
    )
    
    $installed = Get-Module -ListAvailable -Name $Name
    
    if ($MinimumVersion) {
        $installed = $installed | Where-Object { $_.Version -ge $MinimumVersion }
    }
    
    if ($installed) {
        Write-Host "$Name is already installed"
    } else {
        $installParams = @{
            Name = $Name
            Force = $true
            SkipPublisherCheck = $true
            Scope = 'CurrentUser'
        }
        
        if ($MinimumVersion) {
            Write-Host "Installing $Name $MinimumVersion"
            $installParams['MinimumVersion'] = $MinimumVersion
        } else {
            Write-Host "Installing $Name"
        }
        
        Install-Module @installParams
    }
}

# Install required modules
Install-ModuleVerbose -Name 'Pester' -MinimumVersion '5.0.0'
Install-ModuleVerbose -Name 'ImportExcel'
Install-ModuleVerbose -Name 'PSScriptAnalyzer'

# Import modules
Import-Module Pester -Force
Import-Module ImportExcel -Force
Import-Module PSScriptAnalyzer -Force

# Display module versions
Write-Host "`nInstalled module versions:"
Get-Module Pester, ImportExcel, PSScriptAnalyzer | Select-Object Name, Version | Format-Table -AutoSize
