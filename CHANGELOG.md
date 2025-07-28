# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2025-01-28

### Added
- Initial release of gh-workflow-peek
- Intelligent error prioritization by severity (fatal → error → warn → fail → assert → exception)
- Auto-detection of failed PR checks and recent workflow runs
- Flexible job selection by index, ID, or name pattern
- Configurable context lines around matches
- Custom pattern matching with highest priority
- Line range filtering for large logs
- Accurate count display of remaining unshown matches
- Comprehensive dependency checking
- Support for both PR and push workflows
- Cross-platform compatibility (Linux, macOS)

### Features
- Automatic repository detection from current directory
- Sensible defaults for quick analysis (--max 20 for auto-peek)
- Color-coded output for different severity levels
- Clean, informative output format
- Detailed help documentation

[1.0.0]: https://github.com/<OWNER>/gh-workflow-peek/releases/tag/v1.0.0