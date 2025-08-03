# Homebrew Update Workflows

This directory contains GitHub Actions workflows that automatically update Homebrew casks when a new BOSS release is published.

## Workflows

### 1. `update-homebrew-tap.yml` (Recommended)
- **Purpose**: Automatically updates the BOSS cask in your custom tap (risa-labs-inc/homebrew)
- **Trigger**: When a new release is published (non-prerelease)
- **Requirements**: `HOMEBREW_TAP_TOKEN` secret

### 2. `update-homebrew.yml` (Advanced)
- **Purpose**: Updates custom tap AND creates a PR to official homebrew-cask
- **Trigger**: When a new release is published (non-prerelease)
- **Requirements**: `HOMEBREW_TAP_TOKEN` and `HOMEBREW_CASK_TOKEN` secrets

## Setup Instructions

### Setting up `HOMEBREW_TAP_TOKEN` (Secure Method)

**Recommended: Use Fine-grained Personal Access Token**

1. Go to https://github.com/settings/personal-access-tokens/new
2. Configure the token:
   - **Token name**: "BOSS Homebrew Tap Updater"
   - **Expiration**: 90 days (rotate regularly)
   - **Repository access**: Select only `risa-labs-inc/homebrew`
   - **Permissions**: 
     - Repository permissions → Contents: Write
     - Repository permissions → Metadata: Read (automatically selected)
3. Click "Generate token" and copy it
4. Add to BOSS-Releases:
   - Go to https://github.com/risa-labs-inc/BOSS-Releases/settings/secrets/actions
   - Click "New repository secret"
   - Name: `HOMEBREW_TAP_TOKEN`
   - Value: Paste the token
   - Click "Add secret"

**Security Notes**:
- This token can ONLY modify the homebrew repository
- It cannot access any other repositories
- Set a calendar reminder to rotate it before expiration
- The token is encrypted and never exposed in logs

### Setting up `HOMEBREW_CASK_TOKEN` (Optional, for official Homebrew PR)

1. Create another GitHub token with the same `repo` permission
2. Add it as a secret named `HOMEBREW_CASK_TOKEN`

## How It Works

When you publish a new release (e.g., v8.10.2):

1. The workflow extracts the version number from the tag
2. It checks out the homebrew repository
3. Updates the version in `Casks/boss.rb`
4. Commits and pushes the change automatically
5. Users can then update BOSS via `brew upgrade boss`

## Testing

To test without creating a release:
1. You can manually trigger the workflow from the Actions tab
2. Or create a test release and delete it afterward

## Choosing Which Workflow to Use

- **Start with `update-homebrew-tap.yml`**: This only updates your custom tap and is simpler
- **Use `update-homebrew.yml` later**: Once BOSS is in the official Homebrew, this will help keep both updated