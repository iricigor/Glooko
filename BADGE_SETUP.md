# Badge Setup Guide

This guide explains how to set up the dynamic test count badges for the Glooko repository.

## Prerequisites

You only need to create a GitHub Personal Access Token (PAT) for updating the badge Gist.

### 1. Verify the Gist Exists

The badge data is stored in this public Gist: https://gist.github.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207

This Gist should contain two files that will be auto-created by the workflow:
- `glooko-linux-tests.json`
- `glooko-windows-tests.json`

### 2. Create a Personal Access Token (PAT)

1. Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name like "Glooko Badge Token"
4. Select the **`gist`** scope only
5. Click "Generate token"
6. Copy the token (you won't be able to see it again!)

### 3. Add Secret to Repository

1. Go to your repository Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Add one secret:
   - Name: `GIST_TOKEN`, Value: the PAT you created

That's it! The Gist ID is already configured in the workflow and README files.

## How It Works

1. When tests run on the main branch, the workflow extracts test statistics from JUnit XML
2. The `dynamic-badges-action` updates JSON files in the Gist using the token
3. Shields.io reads from these JSON files to display the badges
4. The badges update automatically within a few minutes

## Badge URLs

The badges are available at:
- Linux: `https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-linux-tests.json`
- Windows: `https://gist.githubusercontent.com/iricigor/7d87b86e6e187d46c3d1da7b851e3207/raw/glooko-windows-tests.json`

## Benefits Over Previous Implementation

✅ **No separate badges branch** - Uses a simple Gist instead
✅ **Simpler workflow** - Just one step per platform instead of a whole job
✅ **Industry standard** - Uses widely-adopted `dynamic-badges-action`
✅ **Less maintenance** - No complex git operations
✅ **Faster updates** - Badge data updates immediately after tests complete
✅ **Only one secret needed** - Gist ID is public and hardcoded in the workflow
