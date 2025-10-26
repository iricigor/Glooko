# Alternative Import Methods

## Direct Import from Path

```powershell
# Import directly from path
Import-Module "C:\Path\To\Glooko\Glooko.psd1"

# Import with force to reload if already loaded
Import-Module .\Glooko.psd1 -Force

# Check available commands
Get-Command -Module Glooko
```

## Using Install-GitModule

If you have the [Install-GitModule](https://github.com/iricigor/Install-GitModule) PowerShell module installed, you can install and import the Glooko module directly from GitHub:

```powershell
# Install Install-GitModule if not already installed
Install-Module -Name Install-GitModule -Scope CurrentUser

# Install Glooko module from GitHub
Install-GitModule -ProjectUri 'https://github.com/iricigor/Glooko'

# Import the module
Import-Module Glooko

# Verify the module is loaded
Get-Module Glooko
```

### Benefits of Install-GitModule

- Automatically clones the repository to your PowerShell modules directory
- Handles versioning and updates
- Simplifies installation from GitHub repositories
- No need to manually manage the repository location

For more information about Install-GitModule, visit the [Install-GitModule repository](https://github.com/iricigor/Install-GitModule).
