# Setting Up CHANGELOG_PAT for Automated Changelog Updates

## Overview

The automated changelog update workflow requires a Personal Access Token (PAT) to create pull requests. This document provides step-by-step instructions for setting up the `CHANGELOG_PAT` secret.

## Why is CHANGELOG_PAT Required?

GitHub's default `GITHUB_TOKEN` has a security restriction that prevents it from creating or approving pull requests. This is to prevent infinite workflow loops where:
1. A workflow creates a PR
2. The PR triggers another workflow
3. That workflow creates another PR
4. And so on...

By using a Personal Access Token, we explicitly authorize the workflow to create PRs.

## Step-by-Step Setup Instructions

### Step 1: Create a Personal Access Token

Choose **one** of the following options:

#### Option A: Fine-Grained Personal Access Token (Recommended)

Fine-grained tokens provide more granular control and are the recommended approach.

1. Go to [GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens](https://github.com/settings/tokens?type=beta)
2. Click **"Generate new token"**
3. Configure the token:
   - **Token name**: `Glooko Changelog Automation`
   - **Expiration**: Choose an expiration period (90 days, 1 year, or custom)
   - **Description**: `Token for automated changelog PR creation`
   - **Resource owner**: Select your username (the repository owner)
   - **Repository access**: 
     - Select **"Only select repositories"**
     - Choose the `Glooko` repository
   - **Permissions**:
     - **Repository permissions**:
       - Contents: **Read and write**
       - Pull requests: **Read and write**
4. Click **"Generate token"**
5. **Important**: Copy the token immediately - you won't be able to see it again!

#### Option B: Classic Personal Access Token

If you prefer to use classic tokens:

1. Go to [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)
2. Click **"Generate new token (classic)"**
3. Configure the token:
   - **Note**: `Glooko Changelog Automation`
   - **Expiration**: Choose an expiration period
   - **Select scopes**:
     - Check **`repo`** (this gives full control of private repositories)
4. Click **"Generate token"**
5. **Important**: Copy the token immediately - you won't be able to see it again!

### Step 2: Add the Token as a Repository Secret

1. Navigate to the Glooko repository on GitHub
2. Go to **Settings** → **Secrets and variables** → **Actions**
3. Click **"New repository secret"**
4. Configure the secret:
   - **Name**: `CHANGELOG_PAT` (must be exactly this name)
   - **Secret**: Paste the token you created in Step 1
5. Click **"Add secret"**

### Step 3: Verify the Setup

After adding the secret:

1. Go to **Actions** → **Update Changelog**
2. Click **"Run workflow"**
3. Check the **"Perform a dry run without creating PR"** option
4. Click **"Run workflow"**
5. Wait for the workflow to complete
6. Check the logs to ensure there are no authentication errors

If the dry run succeeds, you can run the workflow again without dry run mode to create an actual PR.

## Security Best Practices

### Token Permissions

- **Use fine-grained tokens** when possible for better security
- Grant only the minimum required permissions
- Set an appropriate expiration period (not "No expiration")

### Token Storage

- **Never commit the token** to the repository
- Store the token only in GitHub Secrets
- Rotate the token periodically (before expiration)

### Token Expiration

When your token expires:

1. The workflow will fail with an authentication error
2. Create a new token following Step 1
3. Update the `CHANGELOG_PAT` secret following Step 2
4. No code changes are needed

## Troubleshooting

### Error: "GitHub Actions is not permitted to create or approve pull requests"

This means the `CHANGELOG_PAT` secret is either:
- Not configured
- Expired
- Has insufficient permissions

**Solution**: Follow the setup instructions above to create and configure a new token.

### Error: "Resource not accessible by integration"

This means the token doesn't have the required permissions.

**Solution**: 
- For fine-grained tokens: Ensure "Contents: Read and write" and "Pull requests: Read and write" are granted
- For classic tokens: Ensure the `repo` scope is selected

### Workflow succeeds but no PR is created

Check the workflow logs:
- If you see "No changes to CHANGELOG.md", there were no new builds to add
- If you see the error about permissions, set up the `CHANGELOG_PAT` secret
- If the branch is created but no PR, manually create the PR from the branch

## Alternative: Repository Settings

Instead of using a PAT, you can enable GitHub Actions to create PRs in the repository settings:

1. Go to **Settings** → **Actions** → **General**
2. Scroll to **Workflow permissions**
3. Check **"Allow GitHub Actions to create and approve pull requests"**

⚠️ **Note**: This setting may not be available in all repositories and may have security implications. Using a PAT is the recommended approach.

## Related Documentation

- [Automated Changelog Updates](automated-changelog.md)
- [GitHub: Creating a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [GitHub: Encrypted secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
