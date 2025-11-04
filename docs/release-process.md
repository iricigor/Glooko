# Release Process

This document describes how to release the Glooko PowerShell module to the PowerShell Gallery.

## Quick Reference: Correct Release Order

⚠️ **Important: Follow this order to avoid changelog synchronization issues**

1. **Update Changelog**: Run "Update Changelog" workflow → Review PR → **Merge to main**
2. **Release Module**: Run "Release to PowerShell Gallery" workflow → Creates GitHub release with changelog

**Why this order?** The Release workflow creates a GitHub release that references the CHANGELOG.md from main. Merging the changelog PR first ensures the GitHub release includes the changelog content. See [Alternative Workflow Considerations](#alternative-workflow-considerations) for details.

## Prerequisites

Before releasing, ensure:

1. All tests are passing (check the [test workflow](../.github/workflows/test.yml))
2. The build workflow has successfully created a module artifact (check the [build workflow](../.github/workflows/build.yml))
3. You have the `PSGALLERY_KEY` secret configured in the repository settings
4. You are logged in as the repository owner (iricigor)

## Release Workflow

The release process is automated using two workflows:

1. [Update Changelog workflow](../.github/workflows/update-changelog.yml) - Automatically generates changelog entries from builds
2. [Release to PowerShell Gallery workflow](../.github/workflows/release.yml) - Publishes the module

### Two-Stage Release Process

The recommended release process has two stages:

#### Stage 1: Update Changelog (Automated)

Before releasing, run the "Update Changelog" workflow to automatically generate changelog entries:

1. Navigate to the [Actions tab](https://github.com/iricigor/Glooko/actions)
2. Select the "Update Changelog" workflow
3. Click "Run workflow"
4. Choose whether to do a dry run:
   - **Dry run checked**: Shows what would be added without creating a PR
   - **Dry run unchecked**: Creates a PR with changelog updates

The workflow will:
- Query GitHub API for the latest release
- Find all build workflow runs with SemVer changes after that release
- Map each build to its associated pull request
- Extract PR titles for changelog entries
- Generate changelog entries in the format: "version - change"
- Create a pull request with the updated CHANGELOG.md

**⚠️ IMPORTANT: Review and merge the changelog PR BEFORE proceeding to Stage 2.**

**Why this order matters:**
- The Release workflow (Stage 2) creates a GitHub release that references the CHANGELOG.md content from the main branch
- If you release before merging the changelog PR, the GitHub release will not include the changelog entries
- This creates a synchronization issue where PS Gallery has the new version but the GitHub release lacks proper changelog documentation
- Future improvement: Issue [#115](https://github.com/iricigor/Glooko/issues/115) proposes adding validation to prevent releasing without an updated changelog

#### Stage 2: Release to PowerShell Gallery

After the changelog PR is merged to main, proceed with the release workflow as described below.

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
1. Update the `CHANGELOG.md` file:
   - Move items from `[Unreleased]` section to a new version section
   - Add the release date
   - Update version comparison links at the bottom
2. Update the `ModuleVersion` in `Glooko.psd1` (e.g., from `1.0` to `1.1`)
3. Commit and push to main
4. Wait for the build workflow to complete
5. Run the release workflow

## Maintaining the Changelog

The project uses [CHANGELOG.md](../CHANGELOG.md) following the [Keep a Changelog](https://keepachangelog.com/) format to track all notable changes.

### Automated Changelog Updates (Recommended)

The "Update Changelog" workflow can automatically generate changelog entries from build workflow runs and their associated pull requests.

**When to use:**
- Before creating a new release
- When you want to quickly catch up on changes since the last release

**How it works:**
1. Queries GitHub API for the latest release
2. Finds all successful build workflow runs since that release
3. Extracts version information from build artifacts
4. Maps builds to their associated pull requests
5. Generates changelog entries with PR titles and links
6. Groups entries by major.minor version
7. Creates a pull request with the updated CHANGELOG.md

**To use:**
1. Navigate to Actions → "Update Changelog" workflow
2. Click "Run workflow"
3. Choose dry run if you want to preview changes first
4. Review the generated PR and merge it

### Manual Changelog Updates

When making changes to the codebase:

1. Add your changes under the `[Unreleased]` section in the appropriate category:
   - **Added** for new features
   - **Changed** for changes in existing functionality
   - **Deprecated** for soon-to-be removed features
   - **Removed** for now removed features
   - **Fixed** for any bug fixes
   - **Security** for security-related changes

2. Use clear, concise descriptions that help users understand the impact
3. Include function names when relevant (e.g., "`Import-GlookoCSV` now supports...")

### When Releasing

Before creating a release:

1. Review all items in the `[Unreleased]` section
2. Create a new version section with the version number and date
3. Move all unreleased items to the new version section
4. Update the comparison links at the bottom of the file
5. Leave the `[Unreleased]` section empty but ready for future changes

## Alternative Workflow Considerations

### Why Not: Prepare Changelog → Release → Merge Changelog?

You might consider this alternative workflow:
1. Prepare changelog update (create PR but don't merge)
2. Release the module to PS Gallery
3. Merge the changelog PR

**This workflow is NOT recommended** because:

- **GitHub Release Synchronization**: The Release workflow creates a GitHub release that references the CHANGELOG.md from the main branch. If the changelog PR isn't merged first, the GitHub release will be created without the changelog content, creating a documentation gap.
- **Release Artifacts**: The GitHub release artifact and PowerShell Gallery package would be published before the changelog documents them, creating a timing mismatch.
- **Rollback Complexity**: If the release fails, you'd need to decide whether to merge or close the changelog PR, creating additional coordination overhead.

**Recommended Workflow Instead:**
1. Run "Update Changelog" workflow to create PR
2. Review and merge the changelog PR to main
3. Run "Release to PowerShell Gallery" workflow
4. The release workflow will create a GitHub release that includes the merged changelog content

This ensures that:
- ✅ PS Gallery publication and GitHub release happen together
- ✅ GitHub release references the correct changelog content
- ✅ All documentation is synchronized at release time
- ✅ Future validation (issue #115) can verify changelog is ready

### Future Improvements

**Issue [#115](https://github.com/iricigor/Glooko/issues/115)** proposes adding validation to the Release workflow to check that CHANGELOG.md contains a header for the version being released. This would:
- Prevent accidental releases without updated changelog
- Provide early feedback if changelog update was forgotten
- Reduce the risk of synchronization issues

Once implemented, this validation will make the recommended workflow even more robust.

## Best Practices

1. **Always test first**: Use the dry run option before publishing
2. **Review the build**: Check the build workflow logs before releasing
3. **Update the changelog FIRST**: Always merge changelog updates before releasing
4. **Follow the two-stage process**: Use the "Update Changelog" workflow, merge the PR, then use the "Release" workflow
5. **Communicate**: Update the README or create a GitHub release if needed
6. **Verify publication**: After releasing, verify the module appears in PowerShell Gallery
