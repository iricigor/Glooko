---
external help file: Glooko-help.xml
Module Name: Glooko
online version:
schema: 2.0.0
---

# Export-GlookoZipToXlsx

## SYNOPSIS
Converts a Glooko zip file to an Excel (XLSX) file with each dataset in a separate worksheet.

## SYNTAX

```
Export-GlookoZipToXlsx [-Path] <String> [-OutputPath <String>] [-Force] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This advanced function imports data from a Glooko zip file using Import-GlookoZip and exports
it to an Excel file.
A Summary worksheet is created as the first tab, containing an overview
of all datasets with their name, record count, and date range information.
Each dataset is then
placed in a separate worksheet, with the worksheet name corresponding to the dataset value from
the metadata.
The XLSX file is created with the same name and location as the ZIP file (unless
a custom output path is specified).

This function requires the ImportExcel module to be installed.
If not installed, it will
provide instructions on how to install it.

## EXAMPLES

### EXAMPLE 1
```
Export-GlookoZipToXlsx -Path "C:\data\export.zip"
Converts the zip file to C:\data\export.xlsx with a Summary worksheet as the first tab,
followed by each dataset in a separate worksheet.
```

### EXAMPLE 2
```
Export-GlookoZipToXlsx -Path "C:\data\export.zip" -Force
Converts the zip file to C:\data\export.xlsx, overwriting if it exists.
```

### EXAMPLE 3
```
Export-GlookoZipToXlsx -Path "C:\data\export.zip" -OutputPath "C:\output\mydata.xlsx"
Converts the zip file to the specified output path.
```

### EXAMPLE 4
```
"C:\data\export.zip" | Export-GlookoZipToXlsx
Converts the zip file via pipeline input.
```

## PARAMETERS

### -Path
The path to the zip file to convert.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -OutputPath
Optional.
The full path for the output XLSX file.
If not specified, the XLSX file will be
created in the same folder as the ZIP file with the same name but .xlsx extension.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force
Optional.
If specified, overwrites the existing XLSX file if it exists.
If not specified and
the file exists, a timestamp will be appended to the filename (e.g., export_311225_143022.xlsx).

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.IO.FileInfo
### Returns the FileInfo object for the created XLSX file.
## NOTES

## RELATED LINKS
