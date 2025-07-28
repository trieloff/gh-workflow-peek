# Contributing to gh-workflow-peek

First off, thank you for considering contributing to gh-workflow-peek! It's people like you that make this tool better for everyone.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code. Please be respectful and considerate in all interactions.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues as you might find out that you don't need to create one. When you are creating a bug report, please include as many details as possible:

* **Use a clear and descriptive title** for the issue to identify the problem
* **Describe the exact steps which reproduce the problem** in as many details as possible
* **Provide specific examples to demonstrate the steps**
* **Describe the behavior you observed after following the steps** and point out what exactly is the problem with that behavior
* **Explain which behavior you expected to see instead and why**
* **Include details about your configuration and environment**:
  - OS and version
  - GitHub CLI version (`gh --version`)
  - Shell version (`bash --version`)
  - Output of dependency checks (`jq --version`, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

* **Use a clear and descriptive title** for the issue to identify the suggestion
* **Provide a step-by-step description of the suggested enhancement** in as many details as possible
* **Provide specific examples to demonstrate the steps**
* **Describe the current behavior** and **explain which behavior you expected to see instead** and why
* **Explain why this enhancement would be useful** to most gh-workflow-peek users

### Pull Requests

1. Fork the repo and create your branch from `main`
2. Make your changes
3. Ensure the script passes shellcheck: `shellcheck gh-workflow-peek`
4. Test your changes thoroughly with different scenarios
5. Update the README.md with details of changes if applicable
6. Issue that pull request!

## Development Process

### Setting Up Your Development Environment

1. Fork and clone the repository:
   ```bash
   gh repo fork yourusername/gh-workflow-peek --clone
   cd gh-workflow-peek
   ```

2. Make sure you have all dependencies installed:
   - GitHub CLI (`gh`)
   - `jq`
   - `column`
   - `shellcheck` (for development)

### Testing Your Changes

Test the extension with various scenarios:

1. **No arguments** - Should auto-detect failed runs:
   ```bash
   ./gh-workflow-peek
   ```

2. **Specific run ID**:
   ```bash
   ./gh-workflow-peek 12345678
   ```

3. **Different job selection methods**:
   ```bash
   ./gh-workflow-peek 12345678 --job 1
   ./gh-workflow-peek 12345678 --job 98765432
   ./gh-workflow-peek 12345678 --job "test name"
   ```

4. **Pattern matching with context**:
   ```bash
   ./gh-workflow-peek 12345678 --match "error" --context 5
   ```

5. **Edge cases**:
   - Very large logs
   - Workflows with many failed jobs
   - Runs with no failures
   - Different terminal widths

### Code Style Guidelines

* Follow bash best practices
* Use meaningful variable names
* Add comments for complex logic
* Maintain consistent indentation (2 spaces)
* Quote variables properly to handle spaces and special characters
* Use `set -euo pipefail` for error handling
* Check scripts with shellcheck before committing

### Commit Message Guidelines

* Use the present tense ("Add feature" not "Added feature")
* Use the imperative mood ("Move cursor to..." not "Moves cursor to...")
* Limit the first line to 72 characters or less
* Reference issues and pull requests liberally after the first line

Examples:
```
Add support for GitLab CI log parsing

- Extend pattern matching to recognize GitLab-specific error formats
- Add --platform flag to specify CI platform
- Update documentation with GitLab examples

Fixes #123
```

## Testing Checklist

Before submitting a PR, ensure you've tested:

- [ ] Script runs without errors on a clean system
- [ ] All command-line options work as documented
- [ ] Error messages are helpful and actionable
- [ ] Script handles missing dependencies gracefully
- [ ] Works with both small and large log files
- [ ] Handles edge cases (no failures, missing auth, etc.)
- [ ] Documentation is updated if needed
- [ ] Code passes shellcheck

## Questions?

Feel free to open an issue with your question or reach out to the maintainers.

Thank you for contributing!