# Changelog

All notable changes to this project will be documented in this file.

This project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-04-13

### Changed
- Preserved the shared DJ.Studio database and saved mixes on both platforms instead of removing the `Music/DJ.Studio` folder.
- Updated macOS and Windows uninstall flows to explain clearly that database cleanup is manual by design.
- Revised completion messaging so the uninstallers describe the narrower safety-focused cleanup accurately.

### Documentation
- Updated the README for `v1.1.0`, including pinned command examples, support-scope language, and manual database removal guidance.
- Added an acknowledgement for the DJ.Studio B.V. support team feedback that informed the `v1.1.0` changes.

## [1.0.0] - 2026-04-12

### Added
- Initial public release of DJ.Studio uninstall scripts for macOS and Windows.
- Guided uninstall flow with confirmation prompts and desktop log output.
- README quick-start paths with pinned reference guidance for reproducible runs.

### Fixed
- Windows PowerShell 5.1 startup compatibility under strict mode.
- Windows uninstall invocation for quoted `UninstallString` command lines.
- Windows Ctrl+C interrupt handling and interrupt exit-code behavior.
