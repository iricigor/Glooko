function Merge-GlookoDatasets {
    <#
    .SYNOPSIS
        Merges multiple dataset objects with the same Dataset and OriginalFirstLine.
    
    .DESCRIPTION
        Consolidates datasets that have matching Dataset and OriginalFirstLine values in their Metadata.
        Merges their data based on ascending Order and uses metadata from the object with the lowest order.
    
    .PARAMETER ImportedData
        Array of imported objects from Import-GlookoCSV, each with Metadata and Data properties.
    
    .OUTPUTS
        Array of PSCustomObject with consolidated datasets.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [AllowEmptyCollection()]
        [array]$ImportedData
    )
    
    Write-Verbose "Starting Merge-GlookoDatasets with $($ImportedData.Count) input objects"
    
    if ($ImportedData.Count -eq 0) {
        Write-Verbose "No data to merge, returning empty array"
        return @()
    }
    
    # Group by Dataset and OriginalFirstLine
    $grouped = $ImportedData | Group-Object -Property {
        "$($_.Metadata.Dataset)|$($_.Metadata.OriginalFirstLine)"
    }
    
    Write-Verbose "Grouped into $($grouped.Count) distinct groups"
    
    $results = foreach ($group in $grouped) {
        $items = $group.Group
        
        if ($items.Count -eq 1) {
            Write-Verbose "Group has single item, no merge needed"
            $items[0]
        } else {
            Write-Verbose "Merging $($items.Count) items in group"
            
            # Sort by Order (ascending) - items without Order will have $null and sort first
            $sortedItems = $items | Sort-Object { $_.Metadata.Order }
            
            # Use metadata from the first item (lowest order)
            $baseMetadata = $sortedItems[0].Metadata
            
            # Merge all data arrays in order
            $mergedData = @()
            foreach ($item in $sortedItems) {
                Write-Verbose "Adding $($item.Data.Count) rows from Order=$($item.Metadata.Order)"
                $mergedData += $item.Data
            }
            
            Write-Verbose "Merged total of $($mergedData.Count) data rows"
            
            # Return consolidated object
            [PSCustomObject]@{
                Metadata = $baseMetadata
                Data     = $mergedData
            }
        }
    }
    
    Write-Verbose "Merge-GlookoDatasets completed, returning $($results.Count) objects"
    return $results
}
