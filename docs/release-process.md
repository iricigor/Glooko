# Release Process

This document describes how to release the Glooko PowerShell module to the PowerShell Gallery.

## Quick Reference: Correct Release Order

⚠️ **CRITICAL: Follow this exact order to keep changelog and releases synchronized**

1. **Prepare Changelog**: Run "Update Changelog" workflow → Review PR → **DO NOT MERGE YET**
2. **Release Module**: Run "Release to PowerShell Gallery" workflow → Publishes to PS Gallery
3. **Merge Changelog**: After successful release, merge the changelog PR to main

**Why this specific order?**
- Every merge to main triggers a build that **auto-increments the version number**
- If you merge the changelog PR first, a new build is created (e.g., 1.0.16)
- The changelog only documents up to 1.0.15
- When you release, you'd be releasing 1.0.16, which is NOT documented in the changelog
- By releasing BEFORE merging, you release the version that's documented in the changelog PR

**Example scenario:**
- Latest release: 1.0.10, Latest build artifact: 1.0.15
- Update Changelog workflow creates PR documenting 1.0.11 - 1.0.15
- **DO NOT MERGE** - Release workflow publishes 1.0.15 to PS Gallery
- **AFTER** release succeeds, merge changelog PR (this creates build 1.0.16 for next release)

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

### Three-Stage Release Process

The recommended release process has three stages:

#### Stage 1: Prepare Changelog (DO NOT MERGE)

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

**⚠️ IMPORTANT: Review the PR but DO NOT MERGE IT YET.** Note the highest version number documented in the changelog PR - this is the version you will release in Stage 2.

#### Stage 2: Release to PowerShell Gallery

After reviewing the changelog PR (but NOT merging it), proceed with the release workflow as described below.

### Triggering a Release

The release workflow can only be triggered manually by the repository owner (iricigor).

1. Navigate to the [Actions tab](https://github.com/iricigor/Glooko/actions)
2. Select the "Release to PowerShell Gallery" workflow
3. Click "Run workflow"
4. Configure the release options:
   - **Version**: Leave empty to publish the latest build artifact, or specify a version (e.g., `1.0.0`) to publish a specific artifact
   - **Dry run**: Check this to perform a test run without actually publishing to PowerShell Gallery
   - **Force release**: Check this to bypass checksum verification (see [Checksum Verification](#checksum-verification) below)

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

1. **Verifies Changelog**: 
   - Checks that CHANGELOG.md contains an entry for the version being released
   - Ensures the changelog has been updated before publishing
   - Exits with an error if the version is not found in the changelog
2. **Downloads Build Artifact**: Retrieves the specified (or latest) build artifact from successful build workflow runs
3. **Verifies Module**: 
   - Checks that the module manifest exists
   - Validates the module can be loaded
   - Displays module version and exported functions
4. **Checks PowerShell Gallery**: Verifies the version doesn't already exist in PowerShell Gallery
5. **Publishes to PowerShell Gallery** (unless dry run):
   - Uses the `PSGALLERY_KEY` secret for authentication
   - Publishes the module from the BuildOutput directory
   - Reports success or failure
6. **Creates GitHub Release**: Creates a GitHub release with the version tag
7. **Creates Summary**: Generates a release summary with installation instructions

#### Stage 3: Merge Changelog PR

**After the release to PowerShell Gallery succeeds**, merge the changelog PR to main:

1. Navigate to the changelog PR created in Stage 1
2. Verify the release workflow completed successfully
3. Merge the changelog PR to main

**What happens when you merge:**
- The build workflow runs automatically
- A new build artifact is created with an incremented version number
- This new version will be included in the changelog for the **next** release

**Important:** The GitHub release created in Stage 2 will reference the CHANGELOG.md from main at the time of release. Since the changelog PR hasn't been merged yet, the GitHub release won't include the full changelog content. However, once you merge the changelog PR, the changelog on the main branch will be updated for future reference.

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

#### Checksum Verification Fails

If the checksum verification step fails with "CHECKSUM MATCH FOUND":
- **Review the changes**: Verify that you actually made code changes to the module runtime files
- **Check what changed**: Compare your changes to the published version to understand what (if anything) is different
- **If code hasn't changed**: Consider whether a new release is necessary
- **If only version changed**: This is expected - the checksum prevents duplicate releases with only version bumps
- **If metadata changed**: Use the **Force release** option to publish the new metadata
- **If you need to override**: Use the **Force release** option, but ensure you understand why the checksum matched

To use Force release:
1. Re-run the workflow
2. Check the **Force release** checkbox
3. Complete the release as normal

#### Publishing Fails

If publishing to PowerShell Gallery fails:
- Verify the `PSGALLERY_KEY` secret is correctly configured
- Ensure the changelog has been updated with the version being released
- Check that the module version doesn't already exist in the gallery
- Review the error message for specific issues
- Try a dry run first to validate the module and changelog

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
4. Review the generated PR but **DO NOT MERGE until after the release** (see [Release Workflow](#release-workflow))

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

## Understanding the Build-Changelog-Release Cycle

**Key Concept:** Every merge to main triggers a build that auto-increments the version number.

**Why the order matters:**

1. **Current state**: Latest release is 1.0.10, latest build artifact is 1.0.15
2. **Update Changelog workflow**: Creates PR documenting versions 1.0.11 through 1.0.15
3. **If you merge the changelog PR now**:
   - Build workflow runs automatically
   - New artifact 1.0.16 is created
   - Changelog only documents up to 1.0.15
   - **Problem**: If you release now, you'll publish 1.0.16 which isn't in the changelog!
4. **Correct approach - Release BEFORE merging**:
   - Release workflow publishes artifact 1.0.15 (which IS documented in the changelog PR)
   - After successful release, merge the changelog PR
   - This creates artifact 1.0.16, which will be documented in the **next** release

**This ensures:**
- ✅ Released versions are always documented in the changelog
- ✅ PowerShell Gallery and changelog stay synchronized
- ✅ GitHub releases reference the correct version information
- ✅ Changelog verification prevents accidental release of undocumented versions

## Best Practices

1. **Always test first**: Use the dry run option before publishing
2. **Review the build**: Check the build workflow logs before releasing
3. **Follow the three-stage process**: 
   - Stage 1: Prepare changelog PR (do not merge)
   - Stage 2: Release to PowerShell Gallery
   - Stage 3: Merge changelog PR after successful release
4. **Note the version**: When reviewing the changelog PR, note the highest version - that's what will be released
5. **Communicate**: Update the README or provide release notes if needed
6. **Verify publication**: After releasing, verify the module appears in PowerShell Gallery
