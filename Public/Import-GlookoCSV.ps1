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
        System.Management.Automation.PSCustomObject[]
        Returns an array of custom objects representing the CSV data.
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
                return
            }
            
            # Skip the first line and use remaining lines
            $dataLines = $allLines[1..($allLines.Count - 1)]
            
            Write-Verbose "Skipped first line. Processing $($dataLines.Count) remaining lines."
            
            # Create temporary file content with remaining lines (second row becomes headers)
            $tempFile = [System.IO.Path]::GetTempFileName()
            
            try {
                $dataLines | Out-File -FilePath $tempFile -Encoding UTF8
                $result = Import-Csv -Path $tempFile
            }
            finally {
                if (Test-Path $tempFile) {
                    Remove-Item $tempFile -Force
                }
            }
            
            Write-Verbose "Successfully processed $($result.Count) data rows"
            return $result
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
