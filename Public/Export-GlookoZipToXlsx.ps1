function Export-GlookoZipToXlsx {
    <#
    .SYNOPSIS
        Converts a Glooko zip file to an Excel (XLSX) file with each dataset in a separate worksheet.
    
    .DESCRIPTION
        This advanced function imports data from a Glooko zip file using Import-GlookoZip and exports
        it to an Excel file. A Summary worksheet is created as the first tab, containing an overview
        of all datasets with their name, record count, and date range information. Each dataset is then
        placed in a separate worksheet, with the worksheet name corresponding to the dataset value from
        the metadata. The XLSX file is created with the same name and location as the ZIP file (unless
        a custom output path is specified).
        
        This function requires the ImportExcel module to be installed. If not installed, it will
        provide instructions on how to install it.
    
    .PARAMETER Path
        The path to the zip file to convert.
    
    .PARAMETER OutputPath
        Optional. The full path for the output XLSX file. If not specified, the XLSX file will be
        created in the same folder as the ZIP file with the same name but .xlsx extension.
    
    .EXAMPLE
        Export-GlookoZipToXlsx -Path "C:\data\export.zip"
        Converts the zip file to C:\data\export.xlsx with a Summary worksheet as the first tab,
        followed by each dataset in a separate worksheet.
    
    .EXAMPLE
        Export-GlookoZipToXlsx -Path "C:\data\export.zip" -OutputPath "C:\output\mydata.xlsx"
        Converts the zip file to the specified output path.
    
    .EXAMPLE
        "C:\data\export.zip" | Export-GlookoZipToXlsx
        Converts the zip file via pipeline input.
    
    .OUTPUTS
        System.IO.FileInfo
        Returns the FileInfo object for the created XLSX file.
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
        [string]$Path,
        
        [Parameter(Mandatory = $false)]
        [string]$OutputPath
    )
    
    begin {
        Write-Verbose "Starting Export-GlookoZipToXlsx function"
        
        # Check if ImportExcel module is available (either already loaded or can be loaded)
        $importExcelLoaded = $null -ne (Get-Module -Name ImportExcel)
        $importExcelAvailable = $null -ne (Get-Module -ListAvailable -Name ImportExcel)
        
        if (-not $importExcelLoaded -and -not $importExcelAvailable) {
            $errorMessage = @"
The ImportExcel module is required but not installed.

To install it, run one of the following commands:
  Install-Module -Name ImportExcel -Scope CurrentUser
  
Or clone it from GitHub:
  git clone https://github.com/dfinke/ImportExcel.git
  Import-Module ./ImportExcel/ImportExcel.psd1

For more information, visit: https://github.com/dfinke/ImportExcel
"@
            Write-Error $errorMessage
            throw "ImportExcel module not found"
        }
        
        # Import the ImportExcel module if not already loaded
        if (-not $importExcelLoaded) {
            Import-Module ImportExcel -ErrorAction Stop
            Write-Verbose "ImportExcel module loaded successfully"
        } else {
            Write-Verbose "ImportExcel module already loaded"
        }
    }
    
    process {
        try {
            Write-Verbose "Processing zip file: $Path"
            
            # Resolve to absolute path
            $zipPath = Resolve-Path -Path $Path
            Write-Verbose "Resolved zip path: $zipPath"
            
            # Determine output path
            if (-not $OutputPath) {
                $zipDirectory = Split-Path -Path $zipPath -Parent
                $zipBaseName = [System.IO.Path]::GetFileNameWithoutExtension($zipPath)
                $OutputPath = Join-Path -Path $zipDirectory -ChildPath "$zipBaseName.xlsx"
                Write-Verbose "Using default output path: $OutputPath"
            } else {
                $OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
                Write-Verbose "Using specified output path: $OutputPath"
            }
            
            # Import data from zip file
            Write-Verbose "Importing data from zip file"
            $datasets = Import-GlookoZip -Path $zipPath
            
            if (-not $datasets -or $datasets.Count -eq 0) {
                Write-Warning "No data found in zip file: $zipPath"
                return
            }
            
            Write-Verbose "Found $($datasets.Count) dataset(s) to export"
            
            # Remove existing file if it exists
            if (Test-Path $OutputPath) {
                Write-Verbose "Removing existing file: $OutputPath"
                Remove-Item -Path $OutputPath -Force
            }
            
            # Create summary data for all datasets
            Write-Verbose "Creating summary data for $($datasets.Count) dataset(s)"
            $summaryData = @()
            foreach ($dataset in $datasets) {
                $datasetName = if ($dataset.Metadata.Dataset) {
                    $dataset.Metadata.Dataset
                } else {
                    'Unknown'
                }
                
                $summaryData += [PSCustomObject]@{
                    Dataset = $datasetName
                    Records = $dataset.Data.Count
                    Name = $dataset.Metadata.Name
                    StartDate = $dataset.Metadata.StartDate
                    EndDate = $dataset.Metadata.EndDate
                }
            }
            
            # Export summary worksheet first
            if ($summaryData.Count -gt 0) {
                Write-Verbose "Exporting Summary worksheet with $($summaryData.Count) dataset(s)"
                $summaryData | Export-Excel -Path $OutputPath -WorksheetName 'Summary' -AutoSize -TableName 'Summary' -TableStyle Medium2
            }
            
            # Export each dataset to a separate worksheet
            $sheetCounter = 1
            foreach ($dataset in $datasets) {
                $worksheetName = if ($dataset.Metadata.Dataset) {
                    $dataset.Metadata.Dataset
                } else {
                    # If no dataset name, use a generic name
                    "Sheet$sheetCounter"
                }
                
                # Excel worksheet names must be 31 characters or less and cannot contain: \ / ? * [ ] :
                $worksheetName = $worksheetName -replace '[\\\/\?\*\[\]:]', '_'
                if ($worksheetName.Length -gt 31) {
                    $worksheetName = $worksheetName.Substring(0, 31)
                }
                
                Write-Verbose "Exporting dataset '$worksheetName' with $($dataset.Data.Count) rows"
                
                if ($dataset.Data -and $dataset.Data.Count -gt 0) {
                    $dataset.Data | Export-Excel -Path $OutputPath -WorksheetName $worksheetName -AutoSize -TableName $worksheetName -TableStyle Medium2
                } else {
                    Write-Warning "Dataset '$worksheetName' has no data, skipping"
                }
                
                $sheetCounter++
            }
            
            Write-Verbose "Successfully created Excel file: $OutputPath"
            
            # Return the file info
            return Get-Item -Path $OutputPath
        }
        catch {
            Write-Error "Error converting zip to XLSX: $($_.Exception.Message)"
            throw
        }
    }
    
    end {
        Write-Verbose "Export-GlookoZipToXlsx function completed"
    }
}

# Export the function if this script is being dot-sourced
Export-ModuleMember -Function Export-GlookoZipToXlsx
