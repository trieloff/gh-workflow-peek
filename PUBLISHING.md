# Publishing Guide

This guide explains how to publish `gh-workflow-peek` as a GitHub CLI extension.

## Pre-Publishing Checklist

✅ All pre-publishing tasks completed:
- Placeholders replaced with actual values
- Tests pass successfully
- Dependencies documented in README

## Publishing Steps

✅ **Repository Created and Code Pushed** - Repository is public and code is on GitHub

✅ **GitHub Actions Already Set Up** - Test and release workflows are configured in `.github/workflows/`

### 1. Create Initial Release

1. Go to your repository on GitHub
2. Click on "Releases" → "Create a new release"
3. Tag version: `v1.0.0`
4. Release title: `v1.0.0 - Initial Release`
5. Description: Copy the content from CHANGELOG.md for v1.0.0
6. Click "Publish release"

### 2. Test Installation

Test that the extension can be installed:

```bash
gh extension install trieloff/gh-workflow-peek
```

✅ **Repository Topics Added** - All recommended topics have been added for discoverability

### 3. Submit to Awesome Lists

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