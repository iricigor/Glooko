# Automated Changelog Updates

This document describes the automated changelog update feature for the Glooko PowerShell module.

## Overview

The "Update Changelog" workflow automatically generates changelog entries by:
1. Finding all build workflow runs since the last GitHub release
2. Extracting version information from build artifacts
3. Mapping builds to their associated pull requests
4. Generating formatted changelog entries with links

This ensures the CHANGELOG.md file stays up-to-date with minimal manual effort.

## Prerequisites

### Required Secret: CHANGELOG_PAT

The workflow requires a Personal Access Token (PAT) with permission to create pull requests. This is necessary because GitHub's default `GITHUB_TOKEN` doesn't have permission to create PRs (to prevent workflow loops).

**Setting up the CHANGELOG_PAT secret:**

1. **Create a Personal Access Token** (classic or fine-grained):
   - Go to [GitHub Settings → Developer settings → Personal access tokens](https://github.com/settings/tokens)
   - For **classic tokens**: Grant `repo` scope (full control of private repositories)
   - For **fine-grained tokens**: Grant `Contents: Read and write` and `Pull requests: Read and write` permissions
   
2. **Add the token as a repository secret**:
   - Go to the repository Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `CHANGELOG_PAT`
   - Value: Paste the token you created
   - Click "Add secret"

**Fallback behavior:**
- If `CHANGELOG_PAT` is not configured, the workflow will fall back to using `GITHUB_TOKEN`
- However, the PR creation step will fail with the error: "GitHub Actions is not permitted to create or approve pull requests"
- The workflow will still update the CHANGELOG.md and push the branch, but won't create the PR automatically

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
## [1.1.5] - 2024-11-03

### Added
- Add Import-GlookoFolder function ([#99](https://github.com/iricigor/Glooko/pull/99))
- Add new configuration option ([#100](https://github.com/iricigor/Glooko/pull/100))

### Fixed
- Fix error handling in Import-GlookoCSV ([#98](https://github.com/iricigor/Glooko/pull/98))

### Documentation
- Update README with new examples ([#101](https://github.com/iricigor/Glooko/pull/101))
```

### Automatic Categorization

Changelog entries are automatically categorized based on PR labels:

- **Added** - PRs with labels: `feature`, `enhancement`, `new-feature`
- **Changed** - PRs with labels: `breaking-change`, `breaking`, or no matching labels (default)
- **Fixed** - PRs with labels: `bug`, `fix`, `bugfix`
- **Security** - PRs with labels: `security`
- **Deprecated** - PRs with labels: `deprecated`
- **Removed** - PRs with labels: `removed`
- **Documentation** - PRs with labels: `documentation`, `docs`

**Label priority**: If a PR has multiple labels, the categorization follows this priority order:
1. Bug/Fix labels → Fixed
2. Feature/Enhancement labels → Added
3. Documentation labels → Documentation
4. Security labels → Security
5. Breaking change labels → Changed
6. Deprecated labels → Deprecated
7. Removed labels → Removed
8. No matching labels → Changed (default)

### Grouping by Version

- Entries are grouped by major.minor version
- Multiple builds with the same major.minor are listed together
- Versions are sorted in descending order (newest first)
- Within each version, entries are organized by category following the [Keep a Changelog](https://keepachangelog.com/) format

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
   - Extracts PR number, title, URL, and labels
5. **Categorizes entries**
   - Automatically categorizes based on PR labels
   - Applies priority rules when multiple labels exist
6. **Generates changelog entries**
   - Groups by major.minor version
   - Organizes entries by category within each version
   - Formats with date and PR links
   - Updates comparison links
7. **Creates a PR** with the changes (unless dry run)

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

### Using Labels for Categorization

To ensure your PRs are categorized correctly in the changelog:

1. **Add appropriate labels to your PRs** before merging
2. Use standard labels like `bug`, `feature`, `enhancement`, `documentation`, etc.
3. The changelog will automatically categorize entries based on these labels

**Best practices:**
- Use `bug` or `fix` for bug fixes
- Use `feature` or `enhancement` for new features
- Use `documentation` for documentation changes
- Use `security` for security-related changes
- Use `breaking-change` for breaking changes

### Manual Editing

After the PR is created, you can manually edit the CHANGELOG.md file in the PR to:
- Adjust entry descriptions
- Add more context
- Reorganize entries
- Move entries to different categories if needed

## Troubleshooting

### Error: "GitHub Actions is not permitted to create or approve pull requests"

**Cause:** The workflow is using the default `GITHUB_TOKEN` which doesn't have permission to create pull requests.

**Solution:** Configure the `CHANGELOG_PAT` secret as described in the [Prerequisites](#required-secret-changelog_pat) section above.

**Workaround:** If you cannot create a PAT immediately:
1. The workflow will still update CHANGELOG.md and push the branch
2. You can manually create a PR from the branch (e.g., `changelog-update-7`)
3. The branch will be visible in the repository after the workflow runs

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
- Categorization depends on PRs having appropriate labels

## Future Enhancements

Potential improvements for the future:
- Support for multiple PR associations per version
- Better handling of breaking changes with special formatting
- Integration with GitHub Releases notes
- More sophisticated label mapping and customization

## Related Documentation

- [Release Process](release-process.md) - Complete release workflow
- [Contributing Guide](../CONTRIBUTING.md) - General contribution guidelines
- [Keep a Changelog](https://keepachangelog.com/) - Changelog format standard
