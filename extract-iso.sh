#!/usr/bin/env bash
# =============================================================================
# extract-iso.sh — Extract ISO files using 7zip
#
# Usage:
#   ./extract-iso.sh [OPTIONS] [DIRECTORY]
#
# Options:
#   -d, --debug      Debug mode: print commands without executing them
#   -r, --recursive  Recursive mode: scan subdirectories for ISO files
#   -h, --help       Show this help message
#
# Arguments:
#   DIRECTORY        Target directory to scan (default: current directory)
#
# Examples:
#   ./extract-iso.sh                    # Extract ISOs in current directory
#   ./extract-iso.sh -d                 # Debug: show what would run
#   ./extract-iso.sh -r /mnt/isos       # Recursively extract in /mnt/isos
#   ./extract-iso.sh -d -r              # Debug + recursive
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Defaults
# ---------------------------------------------------------------------------
DEBUG=false
RECURSIVE=false
SCAN_DIR="."

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()    { echo -e "${CYAN}[INFO]${RESET}  $*"; }
success() { echo -e "${GREEN}[OK]${RESET}    $*"; }
warn()    { echo -e "${YELLOW}[WARN]${RESET}  $*"; }
error()   { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
debug_cmd() {
    # Print the command that *would* run, prefixed with a marker
    echo -e "${YELLOW}[DRY-RUN]${RESET} $*"
}

usage() {
    sed -n '/^# Usage:/,/^# =====/p' "$0" | grep '^#' | sed 's/^# \{0,1\}//'
    exit 0
}

# ---------------------------------------------------------------------------
# Run or simulate a command
#   run_cmd CMD [ARGS...]
# ---------------------------------------------------------------------------
run_cmd() {
    if $DEBUG; then
        debug_cmd "$*"
    else
        "$@"
    fi
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--debug)
            DEBUG=true
            shift
            ;;
        -r|--recursive)
            RECURSIVE=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        -*)
            error "Unknown option: $1"
            usage
            ;;
        *)
            SCAN_DIR="$1"
            shift
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Sanity checks
# ---------------------------------------------------------------------------
if ! command -v 7z &>/dev/null; then
    error "7zip (7z) is not installed or not on PATH."
    error "Install it with:  sudo apt install p7zip-full   (Debian/Ubuntu)"
    error "                   sudo dnf install p7zip p7zip-plugins  (Fedora)"
    error "                   brew install p7zip            (macOS)"
    exit 1
fi

if [[ ! -d "$SCAN_DIR" ]]; then
    error "Directory not found: $SCAN_DIR"
    exit 1
fi

# Resolve to an absolute path so messages are unambiguous
SCAN_DIR="$(realpath "$SCAN_DIR")"

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
echo -e "${BOLD}==============================${RESET}"
echo -e "${BOLD} ISO Extractor${RESET}"
echo -e "${BOLD}==============================${RESET}"
echo -e "  Scan dir  : ${CYAN}${SCAN_DIR}${RESET}"
echo -e "  Recursive : ${CYAN}${RECURSIVE}${RESET}"
echo -e "  Debug     : ${CYAN}${DEBUG}${RESET}"
$DEBUG && warn "DEBUG MODE — no commands will actually be executed."
echo ""

# ---------------------------------------------------------------------------
# Build the list of ISO files
# ---------------------------------------------------------------------------
mapfile -d '' ISO_FILES < <(
    if $RECURSIVE; then
        find "$SCAN_DIR" -type f -iname "*.iso" -print0
    else
        find "$SCAN_DIR" -maxdepth 1 -type f -iname "*.iso" -print0
    fi
)

if [[ ${#ISO_FILES[@]} -eq 0 ]]; then
    warn "No ISO files found in ${SCAN_DIR}$(${RECURSIVE} && echo ' (recursive)' || true)."
    exit 0
fi

info "Found ${#ISO_FILES[@]} ISO file(s)."
echo ""

# ---------------------------------------------------------------------------
# Process each ISO
# ---------------------------------------------------------------------------
SUCCESS_COUNT=0
SKIP_COUNT=0
FAIL_COUNT=0

for ISO_PATH in "${ISO_FILES[@]}"; do
    ISO_DIR="$(dirname  "$ISO_PATH")"   # directory that contains the ISO
    ISO_BASENAME="$(basename "$ISO_PATH")"              # e.g. ubuntu-22.iso
    # Strip the .iso extension (case-insensitive) to form the output dir name
    DEST_NAME="${ISO_BASENAME%.[Ii][Ss][Oo]}"
    DEST_DIR="${ISO_DIR}/${DEST_NAME}"

    echo -e "${BOLD}---${RESET}"
    info "ISO     : ${ISO_PATH}"
    info "Extract → ${DEST_DIR}"

    # Create the destination directory
    if [[ -d "$DEST_DIR" ]]; then
        error "Destination already exists, treating as failure: ${DEST_DIR}"
        (( FAIL_COUNT++ )) || true
        echo ""
        continue
    else
        run_cmd mkdir -p "$DEST_DIR"
        $DEBUG || info "Created directory: ${DEST_DIR}"
    fi

    # Extract with 7z
    #   x  = extract with full paths
    #   -o = output directory (no space between -o and path)
    #   -y = assume Yes on all queries
    run_cmd 7z x "$ISO_PATH" -o"$DEST_DIR" -y

    EXIT_CODE=$?
    if ! $DEBUG; then
        if [[ $EXIT_CODE -eq 0 ]]; then
            if run_cmd rm -f "$ISO_PATH"; then
                success "Extracted and removed ISO: ${ISO_BASENAME}"
                (( SUCCESS_COUNT++ )) || true
            else
                error "Extracted but failed to delete ISO: ${ISO_BASENAME}"
                (( FAIL_COUNT++ )) || true
            fi
        else
            error "7z exited with code ${EXIT_CODE} for: ${ISO_BASENAME}"
            (( FAIL_COUNT++ )) || true
        fi
    else
        (( SKIP_COUNT++ )) || true
    fi

    echo ""
done

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
echo -e "${BOLD}==============================${RESET}"
echo -e "${BOLD} Summary${RESET}"
echo -e "${BOLD}==============================${RESET}"
if $DEBUG; then
    echo -e "  ${YELLOW}Simulated${RESET} : ${SKIP_COUNT} ISO(s) — no files were changed."
else
    echo -e "  ${GREEN}Success${RESET}   : ${SUCCESS_COUNT}"
    echo -e "  ${RED}Failed${RESET}    : ${FAIL_COUNT}"
fi
echo ""