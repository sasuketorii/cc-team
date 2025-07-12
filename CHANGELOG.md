# Changelog

All notable changes to CCTeam will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.14] - 2025-01-12

### Added
- Test infrastructure with Jest configuration
- Basic unit and integration tests
- `auto-auth-claude.sh` - Automatic authentication for Claude agents
- Comprehensive implementation plan in `plans/CCTeam-v0.1.14-Implementation-Plan.md`
- CHANGELOG.md for tracking version history

### Changed
- Improved `agent-send.sh` with authentication state checking
- Enhanced `quality-gate.sh` to handle missing test infrastructure gracefully
- Updated `launch-ccteam-v3.sh` with authentication guidance

### Fixed
- Enter key issue in tmux send-keys (C-m works correctly)
- `enhanced_agent_send.sh` duplication (now symlinked to `agent-send.sh`)
- Authentication workflow for Bypassing Permissions screen

### Removed
- Gemini references from `setup-v2.sh` and documentation
- Duplicate code in `enhanced_agent_send.sh`

## [0.1.13] - 2025-01-12

### Added
- `auto-rollcall.sh` - Automatic agent roll call system
- `install.sh` - Global command installer
- Relative path support for better portability

### Changed
- Improved agent communication system
- Updated documentation paths to use relative references

### Fixed
- Agent initialization issues
- Path dependency problems

## [0.1.12] - 2025-01-11

### Added
- Worktree auto-management system
- Enhanced logging with structured logger
- Memory system integration

### Changed
- Project structure optimization
- Improved error handling

## [0.1.11] - 2025-01-10

### Fixed
- GitHub Actions Exit Code 128 error

## [0.1.10] - 2025-01-09

### Added
- Basic CCTeam functionality
- Boss-Worker architecture
- TMux session management

---

For detailed commit history, see the [GitHub repository](https://github.com/sasuketorii/cc-team)