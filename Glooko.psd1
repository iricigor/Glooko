@{
    # Script module or binary module file associated with this manifest.
    RootModule = 'Glooko.psm1'

    # Version number of this module.
    ModuleVersion = '1.0'

    # Supported PSEditions
    CompatiblePSEditions = @('Desktop', 'Core')

    # ID used to uniquely identify this module
    GUID = '02ff76d0-8773-4042-a1c6-343cc40deba5'

    # Author of this module
    Author = 'iricigor'

    # Company or vendor of this module
    CompanyName = 'Glooko'

    # Description of the functionality provided by this module
    Description = 'PowerShell module for Glooko CSV data processing utilities'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion = '5.1'

    # Functions to export from this module - uses wildcard to automatically export all public functions
    # The actual function list is controlled by Export-ModuleMember in Glooko.psm1
    FunctionsToExport = '*'

    # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry
    AliasesToExport = @()

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{
        PSData = @{
            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('CSV', 'Data', 'Import', 'Glooko', 'PowerShell')

            # A URL to the license for this module.
            LicenseUri = 'https://opensource.org/licenses/MIT'

            # A URL to the main website for this project.
            # ProjectUri = ''

            # A URL to an icon representing this module.
            # IconUri = ''

            # ReleaseNotes of this module
            ReleaseNotes = 'Version 1.0 - Updated to use major.minor version format. Initial release with Import-GlookoCSV function for CSV processing with first row skipping capability. Released under MIT license.'
        }
    }
}