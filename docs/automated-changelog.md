# Automated Changelog Updates

This document describes the automated changelog update feature for the Glooko PowerShell module.

## Overview

The "Update Changelog" workflow automatically generates changelog entries by:
1. Finding all build workflow runs since the last GitHub release
2. Extracting version information from build artifacts
3. Mapping builds to their associated pull requests
4. Generating formatted changelog entries with links

This ensures the CHANGELOG.md file stays up-to-date with minimal manual effort.

## When to Use

Run the "Update Changelog" workflow:
- **Before creating a new release** - Ensures all changes since the last release are documented
- **Periodically** - To keep the changelog current with recent development
- **After multiple PRs are merged** - To consolidate all changes

## How to Use

### Running the Workflow

1. Navigate to [Actions → Update Changelog](https://github.com/iricigor/Glooko/actions/workflows/update-changelog.yml)
2. Click **"Run workflow"**
3. Choose options:
   - **Dry run**: Check to preview changes without creating a PR
   - Leave unchecked to create an actual PR with changelog updates
4. Click **"Run workflow"**

### Dry Run Mode

**Recommended for first-time use** to see what will be generated:

1. Check the "Dry run" option
2. Run the workflow
3. Review the workflow logs to see proposed changelog entries
4. If satisfied, run again without dry run to create the PR

### Creating the PR

When not in dry run mode:

1. The workflow will create a new branch named `changelog-update-{run-number}`
2. It will commit the updated CHANGELOG.md
3. A pull request will be created with:
   - Title: "Update CHANGELOG.md with recent releases"
   - Labels: `documentation`, `automated`
   - Description explaining the automated process

### Review and Merge

After the PR is created:

1. **Review the changes** in the PR
2. **Verify accuracy** of the generated entries
3. **Edit if needed** - You can manually adjust entries in the PR
4. **Merge the PR** when satisfied

## What Gets Generated

### Entry Format

Each version gets an entry like:

```markdown
## [1.0] - 2024-11-03

### Changed
- Add Import-GlookoFolder function ([#99](https://github.com/iricigor/Glooko/pull/99))
- Fix error handling in Import-GlookoCSV ([#98](https://github.com/iricigor/Glooko/pull/98))
```

### Grouping by Version

- Entries are grouped by major.minor version
- Multiple builds with the same major.minor are listed together
- Versions are sorted in descending order (newest first)

### Links

The workflow automatically:
- Links to the associated pull request (if available)
- Creates version comparison links at the bottom of CHANGELOG.md
- Updates the [Unreleased] comparison link

## How It Works

### Technical Details

The workflow:

1. **Queries GitHub API** for the latest release
   - If no release exists, goes back 90 days
2. **Finds build workflow runs** since that release
   - Only successful builds are considered
   - Filters by creation date after the release
3. **Extracts version information** from build artifacts
   - Looks for artifacts named `Glooko-Module-{version}`
   - Parses the version number from the artifact name
4. **Maps commits to PRs**
   - Uses GitHub API to find PRs associated with each commit
   - Extracts PR number, title, and URL
5. **Generates changelog entries**
   - Groups by major.minor version
   - Formats with date and PR links
   - Updates comparison links
6. **Creates a PR** with the changes (unless dry run)

### Version Detection

The script looks for build artifacts with version numbers in the format:
- `major.minor.build` (e.g., `1.0.5`)

Only builds with **new** version numbers (not seen before) are included.

### PR Mapping

The workflow tries to find the PR associated with each build by:
- Looking at the commit SHA from the build run
- Querying GitHub API for PRs that include that commit
- Using the first matching PR (typically the merge commit)

If no PR is found, the entry will still be created but without a PR link.

## Customization

### Manual Editing

After the PR is created, you can manually edit the CHANGELOG.md file in the PR to:
- Adjust entry descriptions
- Add more context
- Reorganize entries
- Add sections (Added, Fixed, Security, etc.)

### Categorization

By default, all entries go under "### Changed". You may want to manually categorize them:

- **Added** - New features
- **Changed** - Changes in existing functionality
- **Fixed** - Bug fixes
- **Security** - Security-related changes
- **Deprecated** - Soon-to-be removed features
- **Removed** - Removed features

## Troubleshooting

### No Changes Generated

If the workflow completes but reports "No changes":
- Verify there are build workflow runs since the last release
- Check that the builds have version artifacts
- Ensure the version numbers have changed

### Missing PR Links

If some entries don't have PR links:
- The commit may not be associated with a PR
- The build may have been triggered by a direct push
- This is normal for some entries

### Duplicate Entries

The workflow avoids duplicates by:
- Only taking the first build for each version number
- Skipping subsequent builds with the same version

If you see duplicates, it may indicate:
- A version number was reused
- Manual entries exist in the changelog

## Best Practices

1. **Run before releases** - Always update the changelog before creating a new release
2. **Use dry run first** - Preview changes before creating a PR
3. **Review carefully** - The automation is helpful but not perfect
4. **Edit as needed** - Manual adjustments are encouraged
5. **Merge promptly** - Don't let changelog PRs linger too long

## Integration with Release Process

The recommended release workflow:

1. **Update Changelog** (this workflow)
   - Run "Update Changelog" workflow
   - Review and merge the PR
2. **Release to PowerShell Gallery**
   - Run the "Release to PowerShell Gallery" workflow
   - This will create a GitHub release and publish to PS Gallery

See [Release Process](release-process.md) for complete details.

## Limitations

- Only processes builds from the last 100 workflow runs
- Requires builds to have properly named artifacts
- PR mapping depends on commits being associated with PRs
- Does not automatically categorize changes (all go under "Changed")

## Future Enhancements

Potential improvements for the future:
- Automatic categorization based on PR labels
- Support for multiple PR associations per version
- Better handling of breaking changes
- Integration with GitHub Releases notes

## Related Documentation

- [Release Process](release-process.md) - Complete release workflow
- [Contributing Guide](../CONTRIBUTING.md) - General contribution guidelines
- [Keep a Changelog](https://keepachangelog.com/) - Changelog format standard
