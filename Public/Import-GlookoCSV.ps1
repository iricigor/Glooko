function Import-GlookoCSV {
    <#
    .SYNOPSIS
        Imports data from a CSV file while skipping the first row.
    
    .DESCRIPTION
        This advanced function imports CSV data from a file and skips the first row,
        which is useful when the first row contains metadata or unwanted headers
        that differ from the actual column headers.
    
    .PARAMETER Path
        The path to the CSV file to import.
    
    .PARAMETER Delimiter
        The delimiter used in the CSV file. Default is comma (,).
    
    .PARAMETER Encoding
        The encoding of the CSV file. Default is UTF8.
    
    .PARAMETER Header
        Custom header names to use for the columns. If not specified,
        the second row will be treated as headers.
    
    .EXAMPLE
        Import-GlookoCSV -Path "C:\data\file.csv"
        Imports the CSV file and skips the first row, using the second row as headers.
    
    .EXAMPLE
        Import-GlookoCSV -Path "C:\data\file.csv" -Header "Name","Age","City"
        Imports the CSV file, skips the first row, and uses custom headers.
    
    .EXAMPLE
        Import-GlookoCSV -Path "C:\data\file.csv" -Delimiter ";" -Encoding UTF8
        Imports a semicolon-delimited CSV file with UTF8 encoding, skipping the first row.
    
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
        [string]$Path,
        
        [Parameter(Mandatory = $false)]
        [string]$Delimiter = ",",
        
        [Parameter(Mandatory = $false)]
        [string]$Encoding = "UTF8",
        
        [Parameter(Mandatory = $false)]
        [string[]]$Header
    )
    
    begin {
        Write-Verbose "Starting Import-GlookoCSV function"
    }
    
    process {
        try {
            Write-Verbose "Reading file: $Path"
            
            # Read all lines from the file
            $allLines = Get-Content -Path $Path -Encoding $Encoding
            
            if ($allLines.Count -lt 2) {
                Write-Warning "File contains fewer than 2 lines. At least 2 lines are required (one to skip, one for data)."
                return
            }
            
            # Skip the first line
            $dataLines = $allLines[1..($allLines.Count - 1)]
            
            Write-Verbose "Skipped first line. Processing $($dataLines.Count) remaining lines."
            
            if ($Header) {
                # Use custom headers
                Write-Verbose "Using custom headers: $($Header -join ', ')"
                
                # Create temporary file content with custom headers
                $tempContent = @($Header -join $Delimiter) + $dataLines
                $tempFile = [System.IO.Path]::GetTempFileName()
                
                try {
                    $tempContent | Out-File -FilePath $tempFile -Encoding $Encoding
                    $result = Import-Csv -Path $tempFile -Delimiter $Delimiter
                }
                finally {
                    if (Test-Path $tempFile) {
                        Remove-Item $tempFile -Force
                    }
                }
            }
            else {
                # Use the second line as headers (first line after skipping)
                if ($dataLines.Count -lt 1) {
                    Write-Warning "No data lines available after skipping the first row."
                    return
                }
                
                Write-Verbose "Using second line as headers"
                
                # Create temporary file content with remaining lines
                $tempFile = [System.IO.Path]::GetTempFileName()
                
                try {
                    $dataLines | Out-File -FilePath $tempFile -Encoding $Encoding
                    $result = Import-Csv -Path $tempFile -Delimiter $Delimiter
                }
                finally {
                    if (Test-Path $tempFile) {
                        Remove-Item $tempFile -Force
                    }
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
