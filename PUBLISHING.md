# Publishing Guide

This guide explains how to publish `gh-workflow-peek` as a GitHub CLI extension.

## Pre-Publishing Checklist

1. [ ] Replace all `<OWNER>` placeholders with your GitHub username/organization:
   - `README.md`
   - `gh-workflow-peek` (script header and help text)
   - `CHANGELOG.md`
   
2. [ ] Replace `<YOUR NAME>` in `LICENSE` with your actual name

3. [ ] Test the extension locally:
   ```bash
   # Run tests
   ./tests/test-simple.sh
   
   # Test with shellcheck
   shellcheck gh-workflow-peek
   ```

4. [ ] Ensure all dependencies are documented in README

## Publishing Steps

### 1. Create GitHub Repository

1. Create a new repository named `gh-workflow-peek` on GitHub
2. Make sure the repository is public

### 2. Push Code

```bash
# Initialize git if not already done
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit of gh-workflow-peek extension"

# Add remote (replace <OWNER> with your username)
git remote add origin https://github.com/<OWNER>/gh-workflow-peek.git

# Push to main branch
git push -u origin main
```

### 3. Set Up GitHub Actions (Optional)

Create `.github/workflows/test.yml` for automated testing:

```yaml
name: Test

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Install dependencies
      run: |
        sudo apt-get update
        sudo apt-get install -y jq shellcheck
    
    - name: Run shellcheck
      run: shellcheck gh-workflow-peek
    
    - name: Run tests
      run: ./tests/test-simple.sh

  test-multi-platform:
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    runs-on: ${{ matrix.os }}
    
    steps:
    - uses: actions/checkout@v4
    
    - name: Install dependencies (Ubuntu)
      if: matrix.os == 'ubuntu-latest'
      run: |
        sudo apt-get update
        sudo apt-get install -y jq
    
    - name: Install dependencies (macOS)
      if: matrix.os == 'macos-latest'
      run: |
        brew install jq
    
    - name: Test script structure
      run: |
        # Basic structural tests that don't require gh auth
        head -n 1 gh-workflow-peek | grep -q "#!/usr/bin/env bash"
        grep -q "VERSION=" gh-workflow-peek
        grep -q "check_dependencies" gh-workflow-peek
```

Create `.github/workflows/release.yml` for automated releases:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Run tests
        run: |
          sudo apt-get update
          sudo apt-get install -y jq shellcheck
          ./tests/test-simple.sh
      
      - name: Create Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body: |
            Release ${{ github.ref }}
            
            ## Installation
            ```bash
            gh extension install ${{ github.repository }}
            ```
            
            ## What's Changed
            Please see the commit history for changes.
          draft: false
          prerelease: false
```

### 4. Create Initial Release

1. Go to your repository on GitHub
2. Click on "Releases" → "Create a new release"
3. Tag version: `v1.0.0`
4. Release title: `v1.0.0 - Initial Release`
5. Description: Copy the content from CHANGELOG.md for v1.0.0
6. Click "Publish release"

### 5. Test Installation

Test that the extension can be installed:

```bash
gh extension install <OWNER>/gh-workflow-peek
```

### 6. Add Repository Topics

Add these topics to your repository for better discoverability:
- `gh-extension`
- `github-cli`
- `github-actions`
- `ci-cd`
- `debugging`
- `developer-tools`

### 7. Submit to Awesome Lists

Consider submitting your extension to:
- [awesome-gh-cli-extensions](https://github.com/kodepandai/awesome-gh-cli-extensions)
- Other relevant awesome lists

## Post-Publishing

### Maintenance

1. Monitor issues and pull requests
2. Keep dependencies up to date
3. Follow semantic versioning for releases
4. Update CHANGELOG.md for each release

### Marketing

1. Write a blog post about the extension
2. Share on social media (Twitter/X, LinkedIn, dev.to)
3. Post in relevant communities (Reddit r/github, Discord servers)
4. Create a demo GIF/video for the README

### Future Enhancements

Consider these features for future versions:
- Export logs to file
- Interactive mode with TUI
- Support for other CI platforms
- Integration with error tracking services
- Custom severity patterns via config file

## Troubleshooting

### Extension Not Found

If users report "extension not found" errors:
1. Ensure repository is public
2. Check repository name matches exactly `gh-workflow-peek`
3. Verify at least one release exists

### Installation Fails

Common issues:
- Missing executable permissions on script
- Script not in repository root
- Repository name doesn't start with `gh-`

## Support

For questions about publishing or maintaining the extension:
- GitHub CLI documentation: https://cli.github.com/manual/gh_extension
- GitHub Community: https://github.community/