#Requires -Version 5.1

# ============================================================
#   DJ.Studio Uninstaller for Windows
#   Safe, friendly, and step-by-step — no tech skills needed!
# ============================================================
#
# MIT License
#
# Copyright (c) 2026 Adrian Dantas
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
# ============================================================

# ── Version ─────────────────────────────────────────────────
$ScriptVersion = "1.1.0"

# ── Safety flags ─────────────────────────────────────────────
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Windows check ────────────────────────────────────────────
# PowerShell 5.1 does not define $IsWindows. Under StrictMode,
# touching an undefined variable throws, so branch by PS major first.
$IsWindowsHost = $true
if ($PSVersionTable.PSVersion.Major -ge 6) {
    $IsWindowsHost = $IsWindows
} else {
    $IsWindowsHost = ($env:OS -eq 'Windows_NT')
}

if (-not $IsWindowsHost) {
    Write-Error "This script is for Windows only. Exiting."
    exit 1
}

# ── Color support ────────────────────────────────────────────
# Respect NO_COLOR (https://no-color.org) and non-interactive sessions.
$UseColor = (-not [Console]::IsOutputRedirected) -and (-not $env:NO_COLOR)

function Write-Color {
    param(
        [string]$Text,
        [System.ConsoleColor]$Color = [Console]::ForegroundColor,
        [switch]$NoNewline
    )
    if ($UseColor) {
        if ($NoNewline) { Write-Host $Text -ForegroundColor $Color -NoNewline }
        else            { Write-Host $Text -ForegroundColor $Color }
    } else {
        if ($NoNewline) { Write-Host $Text -NoNewline }
        else            { Write-Host $Text }
    }
}

# ── Logging ───────────────────────────────────────────────────
$LogFile  = "$env:USERPROFILE\Desktop\djstudio-uninstall-log.txt"
$StartTime = Get-Date -Format "yyyy-MM-dd 'at' HH:mm:ss"

function Write-Log {
    param([string]$Message)
    Add-Content -Path $LogFile -Value $Message
}

function Write-Header {
    param([string]$Text)
    Write-Host ""
    Write-Color $Text Cyan
    Write-Log ""
    Write-Log $Text
}

function Write-Step      { param([string]$T) Write-Color "  > $T" Blue;    Write-Log "  > $T" }
function Write-Found     { param([string]$T) Write-Color "  [FOUND]     $T" Green;   Write-Log "  [FOUND] $T" }
function Write-NotFound  { param([string]$T) Write-Color "  [NOT FOUND] $T" Yellow;  Write-Log "  [NOT FOUND] $T" }
function Write-Deleted   { param([string]$T) Write-Color "  [REMOVED]   $T" Red;     Write-Log "  [DELETED] $T" }
function Write-Skipped   { param([string]$T) Write-Color "  [SKIPPED]   $T" Yellow;  Write-Log "  [SKIPPED] $T" }
function Write-Err       { param([string]$T) Write-Color "  [ERROR]     $T" Red;     Write-Log "  [ERROR] $T" }

# ── Recycle Bin helper ────────────────────────────────────────
# Uses the Microsoft.VisualBasic assembly to move items to the
# Recycle Bin rather than permanently deleting them.
Add-Type -AssemblyName Microsoft.VisualBasic

function Send-ToRecycleBin {
    param([string]$Path)
    $ui      = [Microsoft.VisualBasic.FileIO.UIOption]::OnlyErrorDialogs
    $recycle = [Microsoft.VisualBasic.FileIO.RecycleOption]::SendToRecycleBin
    if (Test-Path $Path -PathType Container) {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteDirectory($Path, $ui, $recycle)
    } elseif (Test-Path $Path -PathType Leaf) {
        [Microsoft.VisualBasic.FileIO.FileSystem]::DeleteFile($Path, $ui, $recycle)
    }
}

# ── Registry app lookup ───────────────────────────────────────
function Find-InstalledApp {
    param([string]$Name)
    $regPaths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
    foreach ($path in $regPaths) {
        $match = Get-ItemProperty $path -ErrorAction SilentlyContinue |
                 Where-Object { $_.DisplayName -like "*$Name*" } |
                 Select-Object -First 1
        if ($match) { return $match }
    }
    return $null
}

# ── Ctrl+C / interrupt handling ───────────────────────────────
trap {
    Write-Host ""
    Write-Host ""
    Write-Color "  WARNING: Uninstall was interrupted. No further changes will be made." Yellow
    Write-Log ""
    Write-Log "[INTERRUPTED] Script was cancelled by the user (Ctrl+C)."
    Write-Log "Uninstall did NOT complete successfully."
    Write-Host ""
    Write-Color "  A partial log has been saved to: $LogFile" Cyan
    Write-Host ""
    exit 130
}

# ── Initialise log ────────────────────────────────────────────
Set-Content -Path $LogFile -Value "DJ.Studio Uninstall Log — $StartTime"
Add-Content -Path $LogFile -Value "Script version: $ScriptVersion"
Add-Content -Path $LogFile -Value "============================================================"

# ============================================================
#   WELCOME SCREEN
# ============================================================
Clear-Host
Write-Host ""
Write-Color "╔══════════════════════════════════════════════════════════╗" Cyan
Write-Color "║        DJ.Studio Uninstaller for Windows  🎛️             ║" Cyan
Write-Color "║        Version $ScriptVersion                                     ║" Cyan
Write-Color "╚══════════════════════════════════════════════════════════╝" Cyan
Write-Host ""
Write-Host "  Hello! This script will safely remove DJ.Studio from your PC."
Write-Host "  Here's what it will do:"
Write-Host ""
Write-Host "  1.  Scan your PC for the DJ.Studio application and support files"
Write-Host "  2.  Show you exactly what it found"
Write-Host "  3.  Ask your permission before changing anything"
Write-Host "  4.  Run the official DJ.Studio uninstaller (if the app is installed)"
Write-Host "  5.  Move leftover data folders to the Recycle Bin"
Write-Host "  6.  Save a log to your Desktop so you can review it later"
Write-Host ""
Write-Color "  WARNING: This will NOT empty your Recycle Bin." Yellow
Write-Host "  You will do that yourself when you are ready — no rush!"
Write-Host "  Your DJ.Studio database and saved mixes will be left alone."
Write-Host ""
Write-Color "  ——————————————————————————————————————————————————————" Blue
Write-Host  "  MIT License · Copyright © 2026 Adrian Dantas"
Write-Host  "  Free to use, share, and modify. No warranty provided."
Write-Color "  ——————————————————————————————————————————————————————" Blue
Write-Host ""

Write-Log "Welcome screen shown. Script version: $ScriptVersion"

# ── Ask to proceed ────────────────────────────────────────────
Write-Color "  Ready to get started? Type " -NoNewline
Write-Color "yes" White -NoNewline
Write-Color " and press Enter (or anything else to quit): " -NoNewline
$ConfirmStart = Read-Host
Write-Host ""

if ($ConfirmStart -ne "yes") {
    Write-Host "  No problem! Nothing was changed. See you next time."
    Write-Log "User chose not to proceed at welcome screen."
    exit 0
}

Write-Log "User confirmed to proceed."

# ============================================================
#   STEP 1 — SCAN
# ============================================================
Write-Header "  Step 1 of 3 — Scanning your PC for DJ.Studio support files..."
Write-Host ""

$FoundItems   = [System.Collections.Generic.List[hashtable]]::new()
$InstalledApp = $null

# ── Check for installed application ──────────────────────────
Write-Step "Checking installed applications..."
$InstalledApp = Find-InstalledApp -Name "DJ.Studio"
if ($InstalledApp) {
    Write-Found "DJ.Studio application  (installed via $($InstalledApp.DisplayVersion))"
    Write-Log   "  [APP FOUND] $($InstalledApp.DisplayName) $($InstalledApp.DisplayVersion)"
} else {
    Write-NotFound "DJ.Studio application (not found in installed programs)"
}

# ── Check data folders ────────────────────────────────────────
function Check-Path {
    param([string]$Path, [string]$Label)
    if (Test-Path $Path) {
        Write-Found "$Label  ($Path)"
        $FoundItems.Add(@{ Path = $Path; Label = $Label })
    } else {
        Write-NotFound $Label
    }
}

Write-Step "Checking AppData folder..."
Check-Path "$env:APPDATA\dj.studio.app" "DJ.Studio config and extensions"

Write-Host ""

# ============================================================
#   STEP 2 — SUMMARY & CONFIRMATION
# ============================================================
Write-Header "  Step 2 of 3 — Here's what was found"
Write-Host ""

$NothingFound = (-not $InstalledApp) -and ($FoundItems.Count -eq 0)

if ($NothingFound) {
    Write-Host "  Great news — no removable DJ.Studio files were found on this PC!"
    Write-Host "  It looks like the app and supported leftovers are already gone."
    Write-Host ""
    Write-Color "  A log has been saved to: $LogFile" Cyan
    Write-Log "No files found. Nothing to delete."
    exit 0
}

if ($InstalledApp) {
    Write-Host "  The following application will be uninstalled:"
    Write-Color "    * $($InstalledApp.DisplayName) $($InstalledApp.DisplayVersion)" Red
    Write-Host ""
}

if ($FoundItems.Count -gt 0) {
    Write-Host "  The following $($FoundItems.Count) data folder(s) will be moved to the Recycle Bin:"
    Write-Host ""
    foreach ($item in $FoundItems) {
        Write-Color "    *  $($item.Path)" Red
    }
    Write-Host ""
}

Write-Color "  WARNING: Your DJ.Studio database, exports, and saved mixes" Yellow
Write-Color "  will be left in place for safety. If you want to remove them too," Yellow
Write-Color "  you will need to delete them manually after this script finishes." Yellow
Write-Host ""
Write-Color "  NOTE: This applies to both the default database location and any" Yellow
Write-Color "  custom location you configured via Settings > Folders > Database folder." Yellow
Write-Host ""

Write-Color "  Proceed with removal? Type " -NoNewline
Write-Color "yes" White -NoNewline
Write-Color " to confirm: " -NoNewline
$ConfirmDelete = Read-Host
Write-Host ""
Write-Log "User typed: $ConfirmDelete"

if ($ConfirmDelete -ne "yes") {
    Write-Host "  Got it — nothing was deleted. You're all good!"
    Write-Log "User chose not to delete files."
    exit 0
}

# ============================================================
#   STEP 3 — REMOVE
# ============================================================
Write-Header "  Step 3 of 3 — Removing DJ.Studio..."
Write-Host ""

$AllOk = $true

# ── Run the official uninstaller ──────────────────────────────
if ($InstalledApp) {
    Write-Step "Running the DJ.Studio uninstaller..."
    $UninstallCommand = if ($InstalledApp.QuietUninstallString) {
        $InstalledApp.QuietUninstallString
    } else {
        $InstalledApp.UninstallString
    }
    Write-Log  "  Running uninstaller: $UninstallCommand"
    try {
        if ([string]::IsNullOrWhiteSpace($UninstallCommand)) {
            throw "Installed app entry does not contain an uninstall command."
        }

        # Parse MSI vs custom uninstaller
        if ($UninstallCommand -match "MsiExec") {
            $productCode = $null
            if ($InstalledApp.PSChildName -match '^\{[0-9A-Fa-f-]+\}$') {
                $productCode = $InstalledApp.PSChildName
            } elseif ($UninstallCommand -match '(\{[0-9A-Fa-f-]+\})') {
                $productCode = $matches[1]
            }

            if (-not $productCode) {
                throw "Could not determine MSI product code from uninstall command."
            }
            Start-Process "msiexec.exe" -ArgumentList "/X $productCode /qb" -Wait
        } else {
            # Execute registry command line as-is so quoted paths + args work.
            Start-Process "cmd.exe" -ArgumentList "/d", "/s", "/c", $UninstallCommand -Wait
        }
        Write-Deleted "DJ.Studio application"
    } catch {
        Write-Err "Could not run the uninstaller: $_"
        Write-Host ""
        Write-Color "  You can uninstall DJ.Studio manually via:" Yellow
        Write-Color "  Start Menu > Settings > Apps > DJ.Studio > Uninstall" Yellow
        $AllOk = $false
    }
    Write-Host ""
}

# ── Move data folders to Recycle Bin ─────────────────────────
foreach ($item in $FoundItems) {
    if (Test-Path $item.Path) {
        try {
            Send-ToRecycleBin -Path $item.Path
            Write-Deleted $item.Path
        } catch {
            Write-Err "Could not move to Recycle Bin: $($item.Path)"
            Write-Err "Error: $_"
            $AllOk = $false
        }
    } else {
        Write-Skipped "$($item.Path) (already gone)"
    }
}

Write-Host ""

# ============================================================
#   DONE
# ============================================================
$EndTime = Get-Date -Format "HH:mm:ss"
Write-Log ""
Write-Log "Uninstall completed at $EndTime"

Write-Color "╔══════════════════════════════════════════════════════════╗" Cyan
if ($AllOk) {
    Write-Color "║   All done! DJ.Studio has been cleaned up.               ║" Cyan
} else {
    Write-Color "║   Done — some items could not be removed automatically.  ║" Cyan
}
Write-Color "╚══════════════════════════════════════════════════════════╝" Cyan
Write-Host ""
if ($FoundItems.Count -gt 0) {
    Write-Host "  Data folders have been moved to your Recycle Bin."
    Write-Host "  Right-click the Recycle Bin on your Desktop and choose"
    Write-Host "  ""Empty Recycle Bin"" when you are ready to free up disk space."
    Write-Host ""
}
Write-Host "  Your DJ.Studio database and saved mixes were left untouched."
Write-Host ""
Write-Color "  A full log has been saved to:" Cyan
Write-Color "  $LogFile" White
Write-Host ""
Write-Host "  We recommend restarting your PC to finish the clean-up."
Write-Host ""
