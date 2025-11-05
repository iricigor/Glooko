function Get-GlookoDataset {
    <#
    .SYNOPSIS
        Filters Glooko datasets by name and returns their data.
    
    .DESCRIPTION
        This function takes an array of Glooko.Dataset objects (from Import-GlookoFolder,
        Import-GlookoZip, or Import-GlookoCSV) and filters them by dataset name.
        It returns only the Data property from matching datasets, making it easy to
        work with specific dataset types like 'cgm', 'alarms', 'insulin', etc.
        
        Uses exact matching (case-insensitive) to find the specified dataset.
    
    .PARAMETER InputObject
        Array of Glooko.Dataset objects to filter. Accepts pipeline input.
    
    .PARAMETER Name
        The name of the dataset to retrieve. Uses exact matching (case-insensitive).
        Matches against the Dataset property in Metadata (e.g., 'cgm', 'alarms').
        If Dataset is not available, matches against FullName (filename).
    
    .EXAMPLE
        Import-GlookoFolder -Path "C:\data\exports" | Get-GlookoDataset -Name "cgm"
        Imports all CSV files and returns only the data from the 'cgm' dataset.
    
    .EXAMPLE
        $datasets = Import-GlookoZip -Path "C:\data\export.zip"
        $cgmData = Get-GlookoDataset -InputObject $datasets -Name "cgm"
        Imports a zip file and extracts only the CGM data.
    
    .EXAMPLE
        $datasets = Import-GlookoFolder -Path "C:\data"
        $alarmData = Get-GlookoDataset -InputObject $datasets -Name "alarms"
        Gets data from the 'alarms' dataset using exact name matching.
    
    .OUTPUTS
        Array of CSV data objects from matching datasets.
        Returns all data records from matched dataset(s).
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [AllowEmptyCollection()]
        [array]$InputObject,
        
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name
    )
    
    begin {
        Write-Verbose "Starting Get-GlookoDataset function"
        Write-Verbose "Searching for dataset: $Name"
        $allDatasets = @()
    }
    
    process {
        # Collect all input objects
        foreach ($item in $InputObject) {
            $allDatasets += $item
        }
    }
    
    end {
        try {
            if ($allDatasets.Count -eq 0) {
                Write-Warning "No datasets provided to filter"
                return @()
            }
            
            Write-Verbose "Processing $($allDatasets.Count) dataset(s)"
            
            # Filter datasets by name (using Dataset or FullName) with exact match
            $matchedDatasets = $allDatasets | Where-Object {
                $datasetName = if ($_.Metadata.Dataset) {
                    $_.Metadata.Dataset
                } elseif ($_.Metadata.FullName) {
                    $_.Metadata.FullName
                } else {
                    'Unknown'
                }
                
                Write-Verbose "Checking dataset: $datasetName"
                $datasetName -eq $Name
            }
            
            if (-not $matchedDatasets) {
                Write-Warning "No datasets found matching: $Name"
                return @()
            }
            
            Write-Verbose "Found $(@($matchedDatasets).Count) matching dataset(s)"
            
            # Return only the Data property from matched datasets
            $allData = @()
            foreach ($dataset in $matchedDatasets) {
                $datasetName = if ($dataset.Metadata.Dataset) { $dataset.Metadata.Dataset } else { $dataset.Metadata.FullName }
                Write-Verbose "Extracting $($dataset.Data.Count) record(s) from dataset: $datasetName"
                $allData += $dataset.Data
            }
            
            Write-Verbose "Returning total of $($allData.Count) record(s)"
            return $allData
        }
        catch {
            Write-Error "Error filtering datasets: $($_.Exception.Message)"
            throw
        }
        finally {
            Write-Verbose "Get-GlookoDataset function completed"
        }
    }
}

# Export the function if this script is being dot-sourced
Export-ModuleMember -Function Get-GlookoDataset
