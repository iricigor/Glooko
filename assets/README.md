# Glooko Module Icon

This directory contains the module icon files.

## Files

- **icon.svg** - The source SVG file for the module icon. This is the source of truth and should be edited directly.
- **icon.png** - The PNG version of the icon, generated from the SVG. This file is referenced by the module manifest.
- **Generate-Icon.ps1** - PowerShell script to regenerate the PNG from the SVG source.

## Updating the Icon

To update the module icon:

1. Edit the `icon.svg` file with your desired changes
2. Run `./Generate-Icon.ps1` to regenerate the PNG file
3. The PNG will be automatically copied to the build output by `Build.ps1`

## Icon Design

The icon represents:
- **Blue circle background** - Professional, trustworthy appearance
- **White document** - CSV file representation
- **Horizontal lines with vertical separators** - CSV data with columns
- **Green graph overlay** - Data analytics and processing capabilities

The icon is designed to be simple, recognizable, and clearly represent the module's purpose of processing CSV data.

## Requirements

To regenerate the PNG icon, you need ImageMagick installed:

### Ubuntu/Debian
```bash
sudo apt-get install imagemagick
```

### macOS
```bash
brew install imagemagick
```

### Windows
Download and install from: https://imagemagick.org/script/download.php#windows
