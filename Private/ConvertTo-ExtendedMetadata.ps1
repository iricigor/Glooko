# Private helper functions for metadata parsing

function ConvertTo-ExtendedMetadata {
    <#
    .SYNOPSIS
        Converts filename and first line content into extended metadata object.
    
    .DESCRIPTION
        Parses filename for dataset/order information and first line for name/date range information.
        Creates a structured metadata object with all parsed fields.
    
    .PARAMETER FileName
        The filename of the CSV file being processed.
    
    .PARAMETER FirstLine
        The first line content from the CSV file.
    
    .OUTPUTS
        PSCustomObject with extended metadata properties.
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FileName,
        
        [Parameter(Mandatory = $true)]
        [AllowEmptyString()]
        [string]$FirstLine
    )
    
    Write-Verbose "Converting to extended metadata for filename: $FileName"
    Write-Verbose "First line content: '$FirstLine'"
    
    # Extract just the filename without path for parsing and output
    $fileNameOnly = Split-Path -Path $FileName -Leaf
    # Write-Verbose ("Function result: " + [System.IO.Path]::GetFileName($FileName))
    Write-Verbose "Processing filename: '$fileNameOnly'"
    
    # Parse filename for dataset and order information
    $fileNameParsed = $null
    if ($fileNameOnly -match '^(.+)_data_(\d+)\.csv$') {
        $fileNameParsed = @{
            dataset = $matches[1]
            order = [int]$matches[2]
        }
        Write-Verbose "Filename parsed - Dataset: '$($fileNameParsed.dataset)', Order: $($fileNameParsed.order)"
    } else {
        Write-Verbose "Filename does not match expected pattern"
    }
    
    # Parse first line for name and date range
    $firstLineParsed = $null
    Write-Verbose "Attempting to parse first line: '$FirstLine'"
    if ($FirstLine -match '^Name:(.+?),\s*Date Range:(.+)$') {
        $name = $matches[1].Trim()
        $dateRange = $matches[2].Trim()
        
        Write-Verbose "First line parsed - Name: '$name', DateRange: '$dateRange'"
        
        # Try to parse date range
        $startDate = $null
        $endDate = $null
        if ($dateRange -match '^(\d{4}-\d{2}-\d{2})\s*-\s*(\d{4}-\d{2}-\d{2})$') {
            $startDate = $matches[1]
            $endDate = $matches[2]
            Write-Verbose "Date range parsed - StartDate: '$startDate', EndDate: '$endDate'"
        } else {
            Write-Verbose "Date range does not match expected format"
        }
        
        $firstLineParsed = @{
            Name = $name
            DateRange = $dateRange
            StartDate = $startDate
            EndDate = $endDate
        }
    } else {
        Write-Verbose "First line does not match expected format"
    }
    
    # Create extended metadata object
    $metadata = [PSCustomObject]@{
        FullName = $fileNameOnly
        Dataset = if ($fileNameParsed) { $fileNameParsed.dataset } else { $null }
        Order = if ($fileNameParsed) { $fileNameParsed.order } else { $null }
        Name = if ($firstLineParsed) { $firstLineParsed.Name } else { $null }
        DateRange = if ($firstLineParsed) { $firstLineParsed.DateRange } else { $null }
        StartDate = if ($firstLineParsed) { $firstLineParsed.StartDate } else { $null }
        EndDate = if ($firstLineParsed) { $firstLineParsed.EndDate } else { $null }
        OriginalFirstLine = $FirstLine
    }
    
    Write-Verbose "Extended metadata created successfully"
    return $metadata
}