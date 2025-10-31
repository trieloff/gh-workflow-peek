# gh-workflow-peek

[![98% Vibe_Coded](https://img.shields.io/badge/98%25-Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

[![Vibe_Coded](https://img.shields.io/badge/Vibe_Coded-ff69b4?style=for-the-badge&logo=claude&logoColor=white)](https://github.com/trieloff/vibe-coded-badge-action)

A GitHub CLI extension to intelligently filter and highlight errors in GitHub Actions workflow logs by severity, exhausting higher-priority issues before showing lower ones. Perfect for developers and AI coding agents working with limited context windows.

![a_sleek_modern_di_image](https://github.com/user-attachments/assets/451a28c1-ccb5-4bae-bb16-b94b45f9cebf)

## Features

- **Smart Error Prioritization**: Automatically categorizes and prioritizes errors by severity (fatal → error → warn → fail → assert → exception)
- **Auto-Detection**: When no run ID is specified, automatically detects and analyzes:
  - Failed PR checks (if in a PR context)
  - Recent failed workflow runs
- **Flexible Job Selection**: Select jobs by index, ID, or name pattern
- **Context Control**: Show configurable lines of context around matches
- **Custom Pattern Matching**: Search for specific patterns with highest priority
- **Line Range Filtering**: Focus on specific portions of large logs
- **Clean Output**: Shows accurate counts of remaining unshown matches by severity

## Installation

Install the extension using the GitHub CLI:

```bash
gh extension install trieloff/gh-workflow-peek
```

## Usage

### Quick Start

```bash
# Auto-detect and analyze failed PR checks or recent failures
gh workflow-peek

# Analyze a specific workflow run
gh workflow-peek 16566617599

# Select a specific job by index
gh workflow-peek 16566617599 --job 3

# Search for specific patterns
gh workflow-peek 16566617599 --match 'connection refused' --context 5
```

### Command Reference

```
gh workflow-peek [RUN_ID] [OPTIONS]

OPTIONS:
  [RUN_ID]             GitHub Actions run ID (optional)
  --id RUN_ID          Alternative way to specify run ID
  --job, -j JOB        Select job by:
                       - Index: 3
                       - ID: 32141145124
                       - Name: "Python on Windows"
  --context, -c NUM    Lines of context around matches (default: 0)
  --max, -m NUM        Maximum lines to show (default: 100)
  --from, -f NUM       Start from line NUM (default: 0 = beginning)
  --upto, -u NUM       End at line NUM (default: 0 = end)
  --match, -p PATTERN  Custom pattern to search (highest priority)
  --repo, -r REPO      Repository (default: current directory's repo)
  --version, -v        Show version information
  --help, -h           Show this help message
```

### Severity Levels

The extension prioritizes errors in the following order:

1. **Custom match** (--match) - blue
2. **fatal** - red
3. **error** - orange
4. **warn/warning** - yellow
5. **fail/failed** - yellow
6. **assert** - magenta
7. **exception/traceback** - cyan

Higher severity issues are exhausted before showing lower severity ones, ensuring you see the most critical problems first.

## Usage with AI Coding Assistants

This extension is particularly useful for AI coding assistants that need to efficiently analyze CI failures within limited context windows:

```bash
# Get a quick overview of the most critical errors
gh workflow-peek --max 20

# Focus on specific error types
gh workflow-peek --match 'TypeError|ImportError' --max 50

# Analyze test failures with context
gh workflow-peek --match 'FAILED|AssertionError' --context 3
```

### Integration Tips for AI Agents

1. **Start with Auto-Detection**: Let the extension automatically find and analyze the most relevant failed run
2. **Use Small --max Values**: Start with `--max 20` to get a quick overview without consuming too much context
3. **Iterate with Specific Patterns**: Once you identify the issue type, use `--match` to focus on specific errors
4. **Leverage Job Selection**: If multiple jobs failed, analyze them one by one using `--job`

## Examples

### Auto-detect and analyze failures
```bash
gh workflow-peek
```
This will:
- Check for failed PR checks first
- Fall back to recent failed workflow runs
- Auto-analyze the top failed run with sensible defaults

### Analyze specific workflow run
```bash
gh workflow-peek 16566617599
```

### Select specific job by index
```bash
gh workflow-peek 16566617599 --job 2
```

### Select job by name pattern
```bash
gh workflow-peek 16566617599 --job "Python 3.11"
```

### Search for database errors with context
```bash
gh workflow-peek 16566617599 --match 'connection|database|timeout' --context 5
```

### Focus on test failures in a specific line range
```bash
gh workflow-peek 16566617599 --from 1000 --upto 2000 --match 'FAILED|ERROR' --max 30
```

### Combine multiple filters for precise analysis
```bash
gh workflow-peek 16566617599 --job "backend-tests" --match 'AssertionError' --context 3 --max 25
```

## Requirements

- GitHub CLI (`gh`) - authenticated with `gh auth login`
- `jq` - for JSON parsing
- `column` - for formatting output (usually part of util-linux)
- `awk` - for text processing (standard on most systems)
- Bash 4.0 or higher

## Troubleshooting

### Authentication Issues
If you see "Error: GitHub CLI is not authenticated", run:
```bash
gh auth login
```

### Missing Dependencies
The extension will check for required dependencies and provide installation instructions if any are missing.

### No Failed Jobs Found
If the extension reports "No failed jobs found", the workflow run might:
- Still be in progress
- Have been cancelled rather than failed
- Have all jobs succeeded

### Repository Detection
If running outside a git repository, specify the repository explicitly:
```bash
gh workflow-peek 16566617599 --repo owner/repo
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

### Development

1. Clone the repository
2. Make your changes
3. Run `shellcheck gh-workflow-peek` to check for issues
4. Test your changes with various workflow scenarios
5. Submit a pull request

## License

[Apache-2.0](LICENSE)

## Related Projects

Part of the **[AI Ecoverse](https://github.com/trieloff/ai-ecoverse)** - a comprehensive ecosystem of tools for AI-assisted development:

- **[yolo](https://github.com/trieloff/yolo)** - AI CLI launcher with worktree isolation
- **[ai-aligned-git](https://github.com/trieloff/ai-aligned-git)** - Git wrapper for safe AI commit practices
- **[ai-aligned-gh](https://github.com/trieloff/ai-aligned-gh)** - GitHub CLI wrapper for proper AI attribution
- **[vibe-coded-badge-action](https://github.com/trieloff/vibe-coded-badge-action)** - Badge showing AI-generated code percentage
- **[upskill](https://github.com/trieloff/upskill)** - Install Claude/Agent skills from other repositories
- **[as-a-bot](https://github.com/trieloff/as-a-bot)** - GitHub App token broker for proper AI attribution

## Development

### Quality Controls

This project uses automated quality controls to ensure code reliability:

- **ShellCheck**: All shell scripts are automatically checked for syntax errors and best practices
  - Runs on every pull request and push to main
  - Configuration in `.shellcheckrc`
  - Local pre-commit hooks available via `.pre-commit-config.yaml`

### Running Tests Locally

```bash
# Run shellcheck
shellcheck gh-workflow-peek

# Run test suite
./tests/test-simple.sh

# Install pre-commit hooks (optional)
pre-commit install
```

## Acknowledgments

This extension was designed with AI coding assistants in mind, recognizing the need for efficient log analysis within limited context windows. Special thanks to the GitHub CLI team for making extensions possible.
