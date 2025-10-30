# Release Process

This document describes how to release the Glooko PowerShell module to the PowerShell Gallery.

## Prerequisites

Before releasing, ensure:

1. All tests are passing (check the [test workflow](../.github/workflows/test.yml))
2. The build workflow has successfully created a module artifact (check the [build workflow](../.github/workflows/build.yml))
3. You have the `PSGALLERY_KEY` secret configured in the repository settings
4. You are logged in as the repository owner (iricigor)

## Release Workflow

The release process is automated using the [Release to PowerShell Gallery workflow](../.github/workflows/release.yml).

### Triggering a Release

The release workflow can only be triggered manually by the repository owner (iricigor).

1. Navigate to the [Actions tab](https://github.com/iricigor/Glooko/actions)
2. Select the "Release to PowerShell Gallery" workflow
3. Click "Run workflow"
4. Configure the release options:
   - **Version**: Leave empty to publish the latest build artifact, or specify a version (e.g., `1.0.0`) to publish a specific artifact
   - **Dry run**: Check this to perform a test run without actually publishing to PowerShell Gallery

### Release Options

#### Publishing the Latest Build

To publish the most recent build artifact:

1. Leave the **Version** field empty
2. Uncheck **Dry run** (unless you want to test first)
3. Click "Run workflow"

The workflow will:
- Find the latest successful build workflow run
- Download the module artifact from that run
- Verify the module can be loaded
- Publish to PowerShell Gallery

#### Publishing a Specific Version

To publish a specific version:

1. Enter the version number in the **Version** field (e.g., `1.0.0`)
2. Uncheck **Dry run** (unless you want to test first)
3. Click "Run workflow"

The workflow will:
- Search recent build runs for an artifact with the specified version
- Download that specific artifact
- Verify the module can be loaded
- Publish to PowerShell Gallery

#### Dry Run

To test the release process without actually publishing:

1. Check the **Dry run** option
2. Configure version as needed
3. Click "Run workflow"

The workflow will perform all steps except the actual publishing to PowerShell Gallery.

### What Happens During Release

The release workflow:

1. **Downloads Build Artifact**: Retrieves the specified (or latest) build artifact from successful build workflow runs
2. **Verifies Module**: 
   - Checks that the module manifest exists
   - Validates the module can be loaded
   - Displays module version and exported functions
3. **Publishes to PowerShell Gallery** (unless dry run):
   - Uses the `PSGALLERY_KEY` secret for authentication
   - Publishes the module from the BuildOutput directory
   - Reports success or failure
4. **Creates Summary**: Generates a release summary with installation instructions

### Security

- The workflow is restricted to run only when triggered by the repository owner (iricigor)
- The `PSGALLERY_KEY` secret is never exposed in logs
- Build artifacts are verified before publishing

### Troubleshooting

#### No Build Artifacts Found

If the workflow reports "No Glooko-Module artifact found", ensure:
- The build workflow has run successfully on the main branch
- Build artifacts are still available (they expire after 90 days)
- You're searching for the correct version

#### Module Fails to Load

If the module verification step fails:
- Check the build workflow logs for any issues
- Ensure all required files are included in the build artifact
- Verify the module manifest is valid

#### Publishing Fails

If publishing to PowerShell Gallery fails:
- Verify the `PSGALLERY_KEY` secret is correctly configured
- Check that the module version doesn't already exist in the gallery
- Review the error message for specific issues
- Try a dry run first to validate the module

### After Release

Once published, users can install the module using:

```powershell
Install-Module -Name Glooko -RequiredVersion <version>
```

Or update to the latest version:

```powershell
Update-Module -Name Glooko
```

## Version Management

The module uses a major.minor.build version format:
- **Major.Minor** is specified in `Glooko.psd1`
- **Build number** is auto-incremented by the build script
- Example: `1.0.3` means major version 1, minor version 0, build 3

To release a new minor version:
1. Update the `ModuleVersion` in `Glooko.psd1` (e.g., from `1.0` to `1.1`)
2. Update the `ReleaseNotes` in `Glooko.psd1`
3. Commit and push to main
4. Wait for the build workflow to complete
5. Run the release workflow

## Best Practices

1. **Always test first**: Use the dry run option before publishing
2. **Review the build**: Check the build workflow logs before releasing
3. **Update release notes**: Ensure the module manifest has current release notes
4. **Communicate**: Update the README or create a GitHub release if needed
5. **Verify publication**: After releasing, verify the module appears in PowerShell Gallery
