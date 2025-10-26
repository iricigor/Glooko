function Import-GlookoCSV {
    <#
    .SYNOPSIS
        Imports data from a CSV file while skipping the first row.
    
    .DESCRIPTION
        This advanced function imports CSV data from a file and skips the first row,
        which is useful when the first row contains metadata or unwanted headers
        that differ from the actual column headers. Uses comma as delimiter and UTF8 encoding.
    
    .PARAMETER Path
        The path to the CSV file to import.
    
    .EXAMPLE
        Import-GlookoCSV -Path "C:\data\file.csv"
        Imports the CSV file and skips the first row, using the second row as headers.
    
    .EXAMPLE
        "C:\data\file.csv" | Import-GlookoCSV
        Imports the CSV file via pipeline input.
    
    .OUTPUTS
        PSCustomObject
        Returns an object with Metadata (extended metadata object with parsed filename and first row info) and Data (array of CSV objects) properties.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({
            if (Test-Path $_ -PathType Leaf) {
                $true
            } else {
                throw "File not found: $_"
            }
        })]
        [string]$Path
    )
    
    begin {
        Write-Verbose "Starting Import-GlookoCSV function"
    }
    
    process {
        try {
            Write-Verbose "Reading file: $Path"
            
            # Read all lines from the file
            $allLines = Get-Content -Path $Path -Encoding UTF8
            
            if ($allLines.Count -lt 2) {
                Write-Warning "File contains fewer than 2 lines. At least 2 lines are required (one to skip, one for data)."
                $firstLine = if ($allLines) { $allLines | Select-Object -First 1 } else { '' }
                $fileName = Split-Path -Path $Path -Leaf
                
                return [PSCustomObject]@{
                    Metadata = ConvertTo-ExtendedMetadata -FileName $fileName -FirstLine $firstLine
                    Data     = @()
                }
            }
            
            # Capture metadata (first line) and data lines
            $firstLine = $allLines[0]
            $dataLines = $allLines[1..($allLines.Count - 1)]
            
            Write-Verbose "Captured first line: $firstLine"
            Write-Verbose "Processing $($dataLines.Count) remaining lines."
            
            # Create extended metadata using helper function
            $fileName = Split-Path -Path $Path -Leaf
            $metadata = ConvertTo-ExtendedMetadata -FileName $fileName -FirstLine $firstLine
            
            # Create temporary file content with remaining lines (second row becomes headers)
            $tempFile = [System.IO.Path]::GetTempFileName()
            
            try {
                $dataLines | Out-File -FilePath $tempFile -Encoding UTF8
                $data = Import-Csv -Path $tempFile
            }
            finally {
                if (Test-Path $tempFile) {
                    Remove-Item $tempFile -Force
                }
            }
            
            Write-Verbose "Successfully processed $($data.Count) data rows"
            
            # Return structured object
            return [PSCustomObject]@{
                Metadata = $metadata
                Data     = $data
            }
        }
        catch {
            Write-Error "Error processing CSV file: $($_.Exception.Message)"
            throw
        }
    }
    
    end {
        Write-Verbose "Import-GlookoCSV function completed"
    }
}

# Export the function if this script is being dot-sourced
Export-ModuleMember -Function Import-GlookoCSV
