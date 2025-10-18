#!/usr/bin/env pwsh

# GitHub Codespaces PowerShell Development Environment Setup
# This script configures the development environment for the Glooko PowerShell module

Write-Host "🚀 Setting up PowerShell development environment for Glooko..." -ForegroundColor Green

# Update PowerShell modules to latest versions
Write-Host "📦 Updating PowerShell modules..." -ForegroundColor Yellow
try {
    # Install/Update PowerShellGet and PackageManagement first
    Install-Module -Name PowerShellGet -Force -AllowClobber -Scope CurrentUser -Repository PSGallery
    Install-Module -Name PackageManagement -Force -AllowClobber -Scope CurrentUser -Repository PSGallery
    
    # Install Pester for testing
    Write-Host "🧪 Installing Pester testing framework..." -ForegroundColor Yellow
    Install-Module -Name Pester -MinimumVersion 5.0.0 -Force -SkipPublisherCheck -Scope CurrentUser
    
    # Install PSScriptAnalyzer for code analysis
    Write-Host "🔍 Installing PSScriptAnalyzer for code quality..." -ForegroundColor Yellow
    Install-Module -Name PSScriptAnalyzer -Force -Scope CurrentUser
    
    # Install platyPS for help documentation
    Write-Host "📚 Installing platyPS for documentation..." -ForegroundColor Yellow
    Install-Module -Name platyPS -Force -Scope CurrentUser
    
    # Install PSReadLine for better console experience
    Write-Host "⌨️  Installing PSReadLine for enhanced console..." -ForegroundColor Yellow
    Install-Module -Name PSReadLine -Force -Scope CurrentUser -AllowPrerelease
    
    Write-Host "✅ PowerShell modules installed successfully!" -ForegroundColor Green
} catch {
    Write-Warning "⚠️  Some modules might have failed to install: $($_.Exception.Message)"
}

# Set up PowerShell execution policy
Write-Host "🔒 Configuring PowerShell execution policy..." -ForegroundColor Yellow
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Create PowerShell profile for enhanced development experience
Write-Host "👤 Setting up PowerShell profile..." -ForegroundColor Yellow
$profilePath = $PROFILE.CurrentUserAllHosts
$profileDir = Split-Path $profilePath -Parent

if (-not (Test-Path $profileDir)) {
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Create a development-friendly PowerShell profile
@'
# GitHub Codespaces PowerShell Development Profile for Glooko

# Import the current module for testing
if (Test-Path "./Glooko.psd1") {
    Import-Module "./Glooko.psd1" -Force
    Write-Host "📦 Glooko module loaded!" -ForegroundColor Green
}

# Set up useful aliases for development
Set-Alias -Name "test" -Value "Invoke-Pester"
Set-Alias -Name "analyze" -Value "Invoke-ScriptAnalyzer"

# Function to run all tests
function Test-Module {
    [CmdletBinding()]
    param(
        [switch]$Coverage
    )
    
    if ($Coverage) {
        ./Tests/PesterConfig.ps1
    } else {
        Invoke-Pester -Path ./Tests/ -Output Detailed
    }
}

# Function to analyze all PowerShell files
function Test-CodeQuality {
    Get-ChildItem -Path . -Filter "*.ps1" -Recurse | Invoke-ScriptAnalyzer
}

# Function to build and test the module
function Build-Module {
    Write-Host "🔨 Building and testing Glooko module..." -ForegroundColor Yellow
    
    # Import the module
    Import-Module "./Glooko.psd1" -Force
    
    # Run code analysis
    Write-Host "🔍 Running code analysis..." -ForegroundColor Yellow
    Test-CodeQuality
    
    # Run tests
    Write-Host "🧪 Running tests..." -ForegroundColor Yellow
    Test-Module
    
    Write-Host "✅ Build complete!" -ForegroundColor Green
}

# Welcome message
Write-Host "" 
Write-Host "🎉 Welcome to Glooko PowerShell Development Environment!" -ForegroundColor Cyan
Write-Host "" 
Write-Host "Available commands:" -ForegroundColor Yellow
Write-Host "  • Test-Module [-Coverage]  - Run Pester tests" -ForegroundColor White
Write-Host "  • Test-CodeQuality        - Run PSScriptAnalyzer" -ForegroundColor White
Write-Host "  • Build-Module            - Build and test everything" -ForegroundColor White
Write-Host "  • test                    - Alias for Invoke-Pester" -ForegroundColor White
Write-Host "  • analyze                 - Alias for Invoke-ScriptAnalyzer" -ForegroundColor White
Write-Host "" 
'@ | Set-Content -Path $profilePath -Encoding UTF8

# Display installed module versions
Write-Host "📋 Installed PowerShell modules:" -ForegroundColor Yellow
@('Pester', 'PSScriptAnalyzer', 'platyPS', 'PSReadLine') | ForEach-Object {
    $module = Get-Module -Name $_ -ListAvailable | Select-Object -First 1
    if ($module) {
        Write-Host "  ✅ $($module.Name) v$($module.Version)" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $_ - Not installed" -ForegroundColor Red
    }
}

# Test if we can import the Glooko module
Write-Host "🧪 Testing Glooko module import..." -ForegroundColor Yellow
try {
    Import-Module "./Glooko.psd1" -Force
    $functions = Get-Command -Module Glooko
    Write-Host "✅ Glooko module imported successfully!" -ForegroundColor Green
    Write-Host "📦 Available functions: $($functions.Name -join ', ')" -ForegroundColor Green
} catch {
    Write-Warning "⚠️  Could not import Glooko module: $($_.Exception.Message)"
}

Write-Host "" 
Write-Host "🎯 Setup complete! Your PowerShell development environment is ready." -ForegroundColor Green
Write-Host "💡 Use 'Build-Module' to run all quality checks and tests." -ForegroundColor Cyan
Write-Host ""