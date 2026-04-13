# DJ.Studio Uninstaller

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform: macOS](https://img.shields.io/badge/platform-macOS-lightgrey)](macos/)
[![Platform: Windows](https://img.shields.io/badge/platform-Windows-blue)](windows/)
[![Release](https://img.shields.io/github/v/release/adriandantas/djstudio-uninstaller)](https://github.com/adriandantas/djstudio-uninstaller/releases)

Community-maintained uninstaller scripts for [DJ.Studio](https://dj.studio). Removes the application and safe leftover support files left behind after a standard uninstall, while preserving your database and saved mixes.

---

## Quick Start

Pick one path:

- **Fastest path**: download-and-run command (still review first)
- **Safest path**: clone repo, inspect script, run locally

Before running any script from the internet, review source first:

- [`macos/uninstall-djstudio.zsh`](macos/uninstall-djstudio.zsh)
- [`windows/uninstall-djstudio.ps1`](windows/uninstall-djstudio.ps1)

For remote download commands, pin to a release tag or commit SHA. Avoid `main` for reproducible runs.

### Fast Path (Pinned Reference)

Set a pinned Git ref (tag or commit SHA), then run:

### macOS

Open **Terminal** and paste:

```zsh
REF="v1.1.0"  # use a release tag or full commit SHA
curl -fsSL "https://raw.githubusercontent.com/adriandantas/djstudio-uninstaller/$REF/macos/uninstall-djstudio.zsh" -o /tmp/uninstall-djstudio.zsh
less /tmp/uninstall-djstudio.zsh
zsh /tmp/uninstall-djstudio.zsh
```

### Windows

Open **PowerShell** and paste:

```powershell
$ref = "v1.1.0"  # use a release tag or full commit SHA
$tmp = "$env:TEMP\uninstall-djstudio.ps1"
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/adriandantas/djstudio-uninstaller/$ref/windows/uninstall-djstudio.ps1" -OutFile $tmp
Get-Content $tmp
& $tmp
```

---

## Why this exists

DJ.Studio stores its support files, preferences, caches, exports, and database across several locations on your system. Removing the app alone does not remove all of the safe-to-clean leftovers. These scripts walk users through removing the app and supported leftover files — safely, with confirmation at every step, and a log saved to the Desktop when done. Your database and saved mixes are preserved by design.

---

## Platform support

| Platform | Script | Status |
|----------|--------|--------|
| macOS | [`macos/uninstall-djstudio.zsh`](macos/uninstall-djstudio.zsh) | ✅ Available |
| Windows | [`windows/uninstall-djstudio.ps1`](windows/uninstall-djstudio.ps1) | ✅ Available |

---

## macOS

### Requirements

- macOS 10.15 (Catalina) or later
- zsh (default shell since macOS Catalina)
- No additional dependencies

### Usage

Open **Terminal**, then run:

```zsh
zsh macos/uninstall-djstudio.zsh
```

The script will:

1. Scan your system for the DJ.Studio app and support files
2. Show you exactly what it found
3. Ask for confirmation before moving anything to the Trash
4. Save a timestamped log to your Desktop

Nothing is permanently deleted. All removals go to the Trash, which you empty at your own discretion.

### What gets removed

| Location | Contents |
|----------|----------|
| `/Applications/DJ.Studio.app` | The application |
| `~/Library/Application Support/dj.studio.app/` | Application support data |
| `~/Library/Preferences/com.djstudio*.plist` | Preference files |
| `~/Library/Application Support/.loopcloud-samples-v3/` | Loopcloud cache (if present) |

> **Note:** This script does **not** remove your DJ.Studio database, exports, or saved mixes. That data may be shared with DJ.Studio Next and may contain projects you still want to keep. If you want to remove the database too, you must do that manually, whether it is in the default `~/Music/DJ.Studio/` location or a custom location set via **Settings > Folders > Database folder**.

---

## Windows

### Requirements

- Windows 10 or later
- PowerShell 5.1 or later (included with Windows 10 by default)
- No additional dependencies

### Usage

Right-click the script file and select **Run with PowerShell**. Or open **PowerShell** and run:

```powershell
.\windows\uninstall-djstudio.ps1
```

If PowerShell blocks script execution, prefer a temporary process-only policy:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\windows\uninstall-djstudio.ps1
```

If you need a persistent change for your user profile, use:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
```

To revert later:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted
```

The script will:

1. Check whether DJ.Studio is installed via the Windows registry
2. Scan for leftover support files
3. Show you exactly what it found
4. Ask for confirmation before changing anything
5. Run the official DJ.Studio uninstaller for the application
6. Move leftover data folders to the Recycle Bin
7. Save a timestamped log to your Desktop

Nothing is permanently deleted. All removals go to the Recycle Bin, which you empty at your own discretion.

### What gets removed

| Location | Contents |
|----------|----------|
| Installed application | Removed via the official DJ.Studio uninstaller |
| `%APPDATA%\dj.studio.app\` | Config files and installed extensions |

> **Note:** This script does **not** remove your DJ.Studio database, exports, or saved mixes. If you want to remove that data too, you must do it manually, whether it is in the default `%USERPROFILE%\Music\DJ.Studio\` location or a custom location set via **Settings > Folders > Database folder**.

---

## Database folder

As of `v1.1.0`, these uninstallers intentionally leave the DJ.Studio database folder alone.

That folder can contain your saved mixes, exports, cached stems, and older project audio copies. Because deleting it may remove work you still care about, this repository now limits itself to the application and supported leftover files.

If you decide you want to delete the database too, do it manually after reviewing what is inside your `Music/DJ.Studio/` folder or your custom database location from **Settings > Folders > Database folder**.

---

## Log file

A log is saved to your Desktop (`djstudio-uninstall-log.txt`) every time either script runs. It records the script version, every file found or skipped, every deletion, and whether the run completed successfully.

---

## Contributing

Bug reports and pull requests are welcome. If you find a file location these scripts miss, please open an issue with the path and a brief description of what it contains.

If you are a DJ.Studio team member and would like to adopt or adapt these scripts for official distribution, feel free to do so under the terms of the MIT License.

---

## Acknowledgements

Thank you to the support team at **DJ.Studio B.V.** for the product feedback that informed the safety-focused changes in `v1.1.0`.

---

## Project policy

- **Compatibility target**: macOS 10.15+ and Windows 10+.
- **Versioning**: scripts include an internal `1.x.y` version string; prefer running pinned release tags.
- **Support scope**: the app, app support files, preferences, and documented caches are maintained; database and mix removal is manual by design.
- **Security reporting**: for sensitive security concerns, avoid public issue details and contact repository maintainer directly.

---

## Sources

File paths and removal steps are based on the official DJ.Studio help documentation:

- [Uninstalling / Deleting DJ.Studio](https://help.dj.studio/en/articles/8118556-uninstalling-deleting-dj-studio)
- [File Storage and Database Management in DJ.Studio](https://help.dj.studio/en/articles/12315405-file-storage-and-database-management-in-dj-studio)

---

## License

MIT License — Copyright © 2026 Adrian Dantas. See [LICENSE](LICENSE) for full terms.
