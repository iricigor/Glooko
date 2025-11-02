#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Installs a PowerShell module with verbose output if not already installed.

.DESCRIPTION
    This function checks if a PowerShell module is installed (optionally with a minimum version)
    and installs it if not already present. It provides verbose output during the process.

.PARAMETER Name
    The name of the module to install (mandatory).

.PARAMETER MinimumVersion
    Optional minimum version required for the module.

.EXAMPLE
    Install-ModuleVerbose -Name 'Pester' -MinimumVersion '5.0.0'
    Installs Pester 5.0.0 or higher if not already installed.

.EXAMPLE
    Install-ModuleVerbose -Name 'PSScriptAnalyzer'
    Installs PSScriptAnalyzer if not already installed.
#>

function Install-ModuleVerbose {
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
