# GitHub Codespaces Configuration for Glooko PowerShell Module

This directory contains the configuration for GitHub Codespaces, providing a complete PowerShell development environment for the Glooko module.

## 🚀 Quick Start

1. **Open in Codespaces**: Click the "Code" button on GitHub and select "Create codespace on main"
2. **Wait for setup**: The environment will automatically install all dependencies
3. **Start developing**: The PowerShell terminal will open with the module pre-loaded

## 📦 What's Included

### Development Tools
- **PowerShell 7.4+**: Latest PowerShell Core
- **Pester 5.x**: Modern testing framework
- **PSScriptAnalyzer**: Code quality analysis
- **platyPS**: Documentation generation
- **PSReadLine**: Enhanced console experience

### VS Code Extensions
- **PowerShell Extension**: Syntax highlighting, IntelliSense, debugging
- **GitHub Integration**: Pull requests, Copilot, collaboration
- **Code Quality**: Markdown linting, spell checking
- **Development**: Live Share, Git integration

### Pre-configured Settings
- **Code Formatting**: OTBS style with consistent indentation
- **Script Analysis**: Comprehensive quality rules
- **Terminal**: PowerShell as default with optimized settings
- **Tasks**: Ready-to-use build, test, and analysis commands

## 🛠️ Available Commands

Once the Codespace is ready, you can use these convenient commands:

### Quick Commands
```powershell
# Test the module
Test-Module

# Test with coverage
Test-Module -Coverage

# Analyze code quality
Test-CodeQuality

# Complete build and test
Build-Module
```

### VS Code Tasks (Ctrl+Shift+P → "Tasks: Run Task")
- **Test: Run All Tests** - Execute all Pester tests
- **Test: Run Tests with Coverage** - Run tests with coverage analysis
- **Analyze: PSScriptAnalyzer** - Check code quality
- **Build: Import Module** - Import and verify the module
- **Build: Full Build and Test** - Complete CI/CD pipeline
- **Development: Watch Tests** - Continuously run tests during development

### Debug Configurations (F5)
- **PowerShell: Launch Current File** - Debug the current PS1 file
- **PowerShell: Debug Import-GlookoCSV Function** - Debug the main function
- **PowerShell: Run Pester Tests** - Debug test execution
- **PowerShell: Interactive Session** - Start with module pre-loaded

## 📁 File Structure

```
.devcontainer/
├── devcontainer.json    # Main Codespaces configuration
├── setup.ps1           # Post-creation setup script
└── README.md           # This documentation

.vscode/
├── settings.json       # VS Code workspace settings
├── tasks.json         # Build/test/analysis tasks
├── launch.json        # Debug configurations
├── extensions.json    # Recommended extensions
└── PSScriptAnalyzerSettings.psd1  # Code quality rules
```

## 🔧 Customization

### Modify Development Environment
Edit `.devcontainer/devcontainer.json` to:
- Change the base image
- Add new VS Code extensions
- Modify container settings
- Add additional tools

### Customize Code Analysis
Edit `.vscode/PSScriptAnalyzerSettings.psd1` to:
- Enable/disable specific rules
- Adjust severity levels
- Configure formatting preferences

### Add New Tasks
Edit `.vscode/tasks.json` to:
- Add custom build steps
- Create deployment tasks
- Add utility commands

## 🧪 Testing Workflow

The environment supports multiple testing approaches:

### Interactive Testing
```powershell
# Import the module
Import-Module ./Glooko.psd1 -Force

# Test individual functions
Import-GlookoCSV -Path "sample.csv" -Verbose
```

### Automated Testing
```powershell
# Run all tests
Invoke-Pester -Path ./Tests/ -Output Detailed

# Run with coverage
./Tests/PesterConfig.ps1

# Watch mode (continuous testing)
# Use VS Code Task: "Development: Watch Tests"
```

### Code Quality
```powershell
# Analyze all PowerShell files
Get-ChildItem -Path . -Filter "*.ps1" -Recurse | Invoke-ScriptAnalyzer

# Use custom settings
Invoke-ScriptAnalyzer -Path . -Settings .vscode/PSScriptAnalyzerSettings.psd1
```

## 🚀 Performance Tips

### Fast Startup
- The container uses a pre-built PowerShell image
- Dependencies are cached after first installation
- Profile loading is optimized for development

### Efficient Development
- Use the integrated terminal with PowerShell
- Leverage VS Code tasks for common operations
- Use the watch mode for continuous testing
- Debug directly in VS Code with F5

### Resource Management
- Container shuts down when not in use
- Mounts are optimized for performance
- Docker socket access for advanced scenarios

## 🔍 Troubleshooting

### Module Import Issues
```powershell
# Force reload the module
Import-Module ./Glooko.psd1 -Force

# Check module status
Get-Module Glooko -ListAvailable
```

### Test Failures
```powershell
# Run tests with verbose output
Invoke-Pester -Path ./Tests/ -Output Detailed -Verbose

# Check specific test file
Invoke-Pester -Path ./Tests/Import-GlookoCSV.Tests.ps1 -Output Detailed
```

### Extension Issues
- Reload VS Code window (Ctrl+Shift+P → "Developer: Reload Window")
- Check extension status in Extensions panel
- Verify PowerShell extension is active

### Performance Issues
- Check container resources in Codespaces dashboard
- Restart the Codespace if needed
- Monitor terminal output for errors

## 📚 Additional Resources

- [GitHub Codespaces Documentation](https://docs.github.com/en/codespaces)
- [PowerShell in VS Code](https://docs.microsoft.com/en-us/powershell/scripting/dev-cross-plat/vscode/using-vscode)
- [Pester Testing Framework](https://pester.dev/)
- [PSScriptAnalyzer Rules](https://github.com/PowerShell/PSScriptAnalyzer/tree/master/RuleDocumentation)

## 🤝 Contributing

When developing in Codespaces:

1. **Create a new branch** for your feature
2. **Use the build tasks** to ensure quality
3. **Run all tests** before committing
4. **Follow the code style** enforced by PSScriptAnalyzer
5. **Update documentation** as needed

The Codespaces environment ensures consistency across all contributors and provides the same high-quality development experience regardless of your local setup.