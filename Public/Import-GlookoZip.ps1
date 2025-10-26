function Import-GlookoZip {
    <#
    .SYNOPSIS
        Imports data from a Glooko zip file by extracting and processing CSV files.
    
    .DESCRIPTION
        This advanced function extracts a Glooko zip file to a temporary folder,
        imports all CSV files using Import-GlookoFolder, and then cleans up the
        temporary folder. This automates the manual process of unzipping and importing.
    
    .PARAMETER Path
        The path to the zip file to import.
    
    .EXAMPLE
        Import-GlookoZip -Path "C:\data\export.zip"
        Extracts the zip file and imports all CSV files from within.
    
    .EXAMPLE
        "C:\data\export.zip" | Import-GlookoZip
        Imports the zip file via pipeline input.
    
    .OUTPUTS
        Array of PSCustomObject
        Returns an array of objects with Metadata and Data properties from Import-GlookoFolder.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Leaf) {
                if ($_ -match '\.zip$') {
                    $true
                } else {
                    throw "File must have .zip extension: $_"
                }
            } else {
                throw "File not found: $_"
            }
        })]
        [string]$Path
    )
    
    begin {
        Write-Verbose "Starting Import-GlookoZip function"
    }
    
    process {
        try {
            Write-Verbose "Processing zip file: $Path"
            
            # Resolve to absolute path
            $zipPath = Resolve-Path -Path $Path
            Write-Verbose "Resolved path: $zipPath"
            
            # Create temporary folder for extraction
            $tempFolder = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())
            New-Item -Path $tempFolder -ItemType Directory -Force | Out-Null
            Write-Verbose "Created temporary folder: $tempFolder"
            
            try {
                # Extract zip file to temporary folder
                Write-Verbose "Extracting zip file to temporary folder"
                Expand-Archive -Path $zipPath -DestinationPath $tempFolder -Force
                
                # Import all CSV files from the temporary folder
                Write-Verbose "Importing CSV files from extracted folder"
                $results = Import-GlookoFolder -Path $tempFolder
                
                Write-Verbose "Successfully imported data from zip file"
                return $results
            }
            finally {
                # Clean up temporary folder
                if (Test-Path $tempFolder) {
                    Write-Verbose "Cleaning up temporary folder: $tempFolder"
                    Remove-Item -Path $tempFolder -Recurse -Force
                }
            }
        }
        catch {
            Write-Error "Error processing zip file: $($_.Exception.Message)"
            throw
        }
    }
    
    end {
        Write-Verbose "Import-GlookoZip function completed"
    }
}

# Export the function if this script is being dot-sourced
Export-ModuleMember -Function Import-GlookoZip
