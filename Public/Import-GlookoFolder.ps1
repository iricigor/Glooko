function Import-GlookoFolder {
    <#
    .SYNOPSIS
        Imports all CSV files from a specified folder.
    
    .DESCRIPTION
        This function imports all CSV files from a folder using Import-GlookoCSV,
        returning an array of imported objects with metadata and data from each file.
    
    .PARAMETER Path
        The path to the folder containing CSV files to import.
    
    .EXAMPLE
        Import-GlookoFolder -Path "C:\data\exports"
        Imports all CSV files from the specified folder.
    
    .EXAMPLE
        "C:\data\exports" | Import-GlookoFolder
        Imports all CSV files via pipeline input.
    
    .OUTPUTS
        Array of PSCustomObject
        Returns an array of objects, each with Metadata and Data properties from Import-GlookoCSV.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Container) {
                $true
            } else {
                throw "Folder not found: $_"
            }
        })]
        [string]$Path
    )
    
    begin {
        Write-Verbose "Starting Import-GlookoFolder function"
    }
    
    process {
        try {
            Write-Verbose "Processing folder: $Path"
            
            # Get all CSV files in the folder
            $csvFiles = Get-ChildItem -Path $Path -Filter "*.csv" -File
            
            if ($csvFiles.Count -eq 0) {
                Write-Warning "No CSV files found in folder: $Path"
                return @()
            }
            
            Write-Verbose "Found $($csvFiles.Count) CSV file(s) in folder"
            
            # Import each CSV file using Import-GlookoCSV
            $results = @()
            foreach ($file in $csvFiles) {
                Write-Verbose "Importing file: $($file.Name)"
                $result = Import-GlookoCSV -Path $file.FullName
                $results += $result
            }
            
            Write-Verbose "Successfully imported $($results.Count) file(s)"
            
            return $results
        }
        catch {
            Write-Error "Error processing folder: $($_.Exception.Message)"
            throw
        }
    }
    
    end {
        Write-Verbose "Import-GlookoFolder function completed"
    }
}

# Export the function if this script is being dot-sourced
Export-ModuleMember -Function Import-GlookoFolder
