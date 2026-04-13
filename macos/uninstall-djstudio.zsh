#!/bin/zsh

# ============================================================
#   DJ.Studio Uninstaller for macOS
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
SCRIPT_VERSION="1.1.0"

# ── Safety flags ─────────────────────────────────────────────
# NO_UNSET  : treat unset variables as errors
# PIPE_FAIL : a pipeline fails if any command in it fails
setopt NO_UNSET PIPE_FAIL

# ── macOS check ──────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  echo "ERROR: This script is for macOS only. Exiting." >&2
  exit 1
fi

# ── Colors & symbols ─────────────────────────────────────────
# Respect the NO_COLOR standard (https://no-color.org) and
# fall back gracefully when stdout is not a real terminal.
if [[ -z "${NO_COLOR:-}" && -t 1 ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[1;33m'
  BLUE='\033[0;34m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' BLUE='' CYAN='' BOLD='' RESET=''
fi

CHECKMARK="✅"
CROSS="❌"
SEARCH="🔍"
TRASH="🗑️ "
LOG_ICON="📋"
WARNING="⚠️ "
PARTY="🎉"
WAVE="👋"

# ── Log file setup ───────────────────────────────────────────
LOG_DIR="$HOME/Desktop"
LOG_FILE="$LOG_DIR/djstudio-uninstall-log.txt"
START_TIME=$(date "+%Y-%m-%d at %H:%M:%S")

log() {
  # Strip ANSI escape codes before writing to the log file
  echo "$1" | sed 's/\x1b\[[0-9;]*m//g' >> "$LOG_FILE"
}

header() {
  echo ""
  echo "${BOLD}${CYAN}$1${RESET}"
  log ""
  log "$1"
}

step()      { echo "  ${BLUE}▸${RESET} $1";                    log "  > $1"; }
found()     { echo "  ${GREEN}${CHECKMARK}  Found:${RESET} $1";  log "  [FOUND] $1"; }
not_found() { echo "  ${YELLOW}—  Not found:${RESET} $1";       log "  [NOT FOUND] $1"; }
deleted()   { echo "  ${RED}${TRASH} Deleted:${RESET} $1";      log "  [DELETED] $1"; }
skipped()   { echo "  ${YELLOW}${WARNING} Skipped:${RESET} $1"; log "  [SKIPPED] $1"; }

# ── Ctrl+C / interrupt trap ──────────────────────────────────
handle_interrupt() {
  echo ""
  echo ""
  echo "  ${WARNING} Uninstall was interrupted. No further changes will be made."
  log ""
  log "[INTERRUPTED] Script was cancelled by the user (Ctrl+C)."
  log "Uninstall did NOT complete successfully."
  echo ""
  echo "  ${LOG_ICON}  A partial log has been saved to: ${BOLD}$LOG_FILE${RESET}"
  echo ""
  exit 130  # 128 + SIGINT(2) — standard exit code for Ctrl+C
}
trap handle_interrupt INT TERM

# ── Initialise log file ──────────────────────────────────────
echo "DJ.Studio Uninstall Log — $START_TIME" > "$LOG_FILE"
echo "Script version: $SCRIPT_VERSION" >> "$LOG_FILE"
echo "============================================================" >> "$LOG_FILE"

# ── Safe trash helper ────────────────────────────────────────
# Escapes double-quotes in the path before passing to AppleScript,
# preventing injection if a folder name contains a quote character.
trash_item() {
  local item="$1"
  local safe_item="${item//\"/\\\"}"   # escape any " in the path
  osascript -e "tell application \"Finder\" to delete POSIX file \"$safe_item\"" &>/dev/null
}

# ============================================================
#   WELCOME SCREEN
# ============================================================
clear
echo ""
echo "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
echo "${BOLD}${CYAN}║        DJ.Studio Uninstaller for macOS  🎛️               ║${RESET}"
echo "${BOLD}${CYAN}║        Version $SCRIPT_VERSION                                     ║${RESET}"
echo "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo "  Hello! This script will ${BOLD}safely remove DJ.Studio${RESET} from your Mac."
echo "  Here's what it will do:"
echo ""
echo "  1. ${SEARCH}  Scan your Mac for the DJ.Studio app and support files"
echo "  2. ${LOG_ICON}  Show you exactly what it found"
echo "  3. ❓  Ask your permission before deleting anything"
echo "  4. ${TRASH} Remove only the files you approve"
echo "  5. ${LOG_ICON}  Save a log on your Desktop so you can review it later"
echo ""
echo "  ${YELLOW}${WARNING} Important:${RESET} This will ${BOLD}not${RESET} empty your Trash."
echo "  You'll do that yourself when you're ready — no rush!"
echo "  Your DJ.Studio database and saved mixes will be ${BOLD}left alone${RESET}."
echo ""
echo "  ${BLUE}——————————————————————————————————————————————————————${RESET}"
echo "  ${BOLD}MIT License${RESET} · Copyright © 2026 Adrian Dantas"
echo "  Free to use, share, and modify. No warranty provided."
echo "  ${BLUE}——————————————————————————————————————————————————————${RESET}"
echo ""

log "Welcome screen shown. Script version: $SCRIPT_VERSION"

# ── Ask to proceed ───────────────────────────────────────────
echo -n "  Ready to get started? Type ${BOLD}yes${RESET} and press Enter (or anything else to quit): "
read -r CONFIRM_START
echo ""

if [[ "$CONFIRM_START" != "yes" ]]; then
  echo "  ${WAVE}  No problem! Nothing was changed. See you next time."
  log "User chose not to proceed at welcome screen."
  exit 0
fi

log "User confirmed to proceed."

# ============================================================
#   STEP 1 — SCAN FOR FILES
# ============================================================
header "${SEARCH}  Step 1 of 3 — Scanning your Mac for DJ.Studio support files..."
echo ""

FOUND_ITEMS=()

check_path() {
  local path="$1"
  local label="$2"
  if [[ -e "$path" ]]; then
    found "$label  ($path)"
    FOUND_ITEMS+=("$path")
  else
    not_found "$label"
  fi
}

step "Checking Applications folder..."
check_path "/Applications/DJ.Studio.app"                              "DJ.Studio application"

step "Checking Application Support..."
check_path "$HOME/Library/Application Support/dj.studio.app"        "DJ.Studio app support data"

step "Checking Preferences..."
DJ_PREFS=("$HOME"/Library/Preferences/com.djstudio*.plist(N))
if [[ ${#DJ_PREFS[@]} -gt 0 ]]; then
  for pref in "${DJ_PREFS[@]}"; do
    found "Preference file  ($pref)"
    FOUND_ITEMS+=("$pref")
  done
else
  not_found "DJ.Studio preference files (com.djstudio*.plist)"
fi

step "Checking for Loopcloud leftovers..."
check_path "$HOME/Library/Application Support/.loopcloud-samples-v3" "Loopcloud samples cache"

echo ""

# ============================================================
#   STEP 2 — SHOW SUMMARY & ASK PERMISSION
# ============================================================
header "${LOG_ICON}  Step 2 of 3 — Here's what was found"
echo ""

if [[ ${#FOUND_ITEMS[@]} -eq 0 ]]; then
  echo "  ${PARTY}  Great news — no removable DJ.Studio files were found on this Mac!"
  echo "  It looks like the app and supported leftovers are already gone."
  echo ""
  echo "  ${LOG_ICON}  A log has been saved to: ${BOLD}$LOG_FILE${RESET}"
  log "No files found. Nothing to delete."
  exit 0
fi

echo "  The following ${#FOUND_ITEMS[@]} item(s) will be moved to the Trash:"
echo ""
for item in "${FOUND_ITEMS[@]}"; do
  echo "    ${RED}•${RESET}  $item"
done
echo ""
echo "  ${WARNING} ${YELLOW}Your DJ.Studio database, exports, and saved mixes"
echo "  will be left in place for safety. If you want to remove them too,"
echo "  you'll need to do that manually after this script finishes.${RESET}"
echo ""

echo -n "  Move all of the above to the Trash? Type ${BOLD}yes${RESET} to confirm: "
read -r CONFIRM_DELETE
echo ""
log "User typed: $CONFIRM_DELETE"

if [[ "$CONFIRM_DELETE" != "yes" ]]; then
  echo "  ${WAVE}  Got it — nothing was deleted. You're all good!"
  log "User chose not to delete files."
  exit 0
fi

# ============================================================
#   STEP 3 — DELETE FILES
# ============================================================
header "${TRASH} Step 3 of 3 — Moving files to Trash..."
echo ""

ALL_OK=true

for item in "${FOUND_ITEMS[@]}"; do
  if [[ -e "$item" ]]; then
    if trash_item "$item"; then
      deleted "$item"
    else
      echo "  ${RED}${CROSS}  Could not move to Trash:${RESET} $item"
      log "  [ERROR] Could not move to Trash: $item"
      ALL_OK=false
    fi
  else
    skipped "$item (already gone)"
  fi
done

echo ""

# ============================================================
#   DONE!
# ============================================================
END_TIME=$(date "+%H:%M:%S")
log ""
log "Uninstall completed at $END_TIME"

echo "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
if [[ "$ALL_OK" == "true" ]]; then
  echo "${BOLD}${CYAN}║   ${PARTY}  All done! DJ.Studio has been cleaned up.           ║${RESET}"
else
  echo "${BOLD}${CYAN}║   ${WARNING}  Done — some items could not be removed.            ║${RESET}"
fi
echo "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo "  ${CHECKMARK}  Files have been moved to your ${BOLD}Trash${RESET} (not permanently deleted yet)."
echo "  When you're ready, right-click the Trash in your Dock"
echo "  and choose ${BOLD}\"Empty Trash\"${RESET} to free up the disk space."
echo ""
echo "  Your DJ.Studio database and saved mixes were left untouched."
echo ""
echo "  ${LOG_ICON}  A full log of everything that happened has been saved to:"
echo "  ${BOLD}$LOG_FILE${RESET}"
echo ""
echo "  We recommend restarting your Mac to finish the clean-up. ${PARTY}"
echo ""
