@{
    # Severity levels to include
    Severity = @('Error', 'Warning', 'Information')
    
    # Include default rules
    IncludeDefaultRules = $true
    
    # Exclude specific rules that don't apply or are too strict
    ExcludeRules = @(
        'PSAvoidTrailingWhitespace',         # Too strict, can be handled by editor settings
        'PSUseSingularNouns',                # Plural nouns are intentional in this module (e.g., Merge-GlookoDatasets)
        'PSAvoidUsingWriteHost',             # Write-Host is acceptable for scripts (not module functions)
        'PSUseBOMForUnicodeEncodedFile',     # BOM is not required for UTF-8 files
        'PSAvoidUsingPositionalParameters',  # Positional parameters are acceptable in tests
        'PSUseDeclaredVarsMoreThanAssignments', # Variables in tests may be assigned for debugging
        'PSUseOutputTypeCorrectly'           # Output type detection may not be accurate for dynamic types
    )
    
    # Rules to run
    # IncludeRules = @()  # Use all default rules except those excluded
}
