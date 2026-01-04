#!/bin/bash

# Exit on any error
set -e

# --- Configuration ---
BASE_URL="https://buildbot.libretro.com/nightly/linux/x86_64/"
INSTALL_DIR="$HOME/.retroarch-nightly"
VERSION_FILE="$INSTALL_DIR/.version_tag"
TEMP_DIR="/tmp/ra_stage"

# --- Color Palette ---
G='\033[0;32m' # Green
B='\033[0;34m' # Blue
Y='\033[1;33m' # Yellow
R='\033[0;31m' # Red
NC='\033[0m'    # No Color

# --- Optimized Functions ---
log_info() { echo -e "${B}🔹 $1${NC}"; }
log_ok()   { echo -e "${G}✔ $1${NC}"; }
log_warn() { echo -e "${Y}🔸 $1${NC}"; }
log_err()  { echo -e "${R}✖ $1${NC}"; }

# Check dependencies once
for cmd in curl 7z grep; do
    if ! command -v $cmd &> /dev/null; then
        log_err "Required tool '$cmd' is missing."
        exit 1
    fi
done

# 1. Scrape Filename & Metadata in one go
log_info "Synchronizing with Libretro Buildbot..."
PAGE_DATA=$(curl -sL "$BASE_URL")
LATEST_FILENAME=$(echo "$PAGE_DATA" | grep -oP 'RetroArch\.7z(?=")' | head -n 1)

if [[ -z "$LATEST_FILENAME" ]]; then
    log_err "Failed to fetch remote manifest."
    exit 1
fi

# Fetch Remote ETag (unique file hash) for precise versioning
REMOTE_ID=$(curl -sI "$BASE_URL$LATEST_FILENAME" | grep -i "etag" | tr -d '\r')

# 2. Smart Update Logic
if [[ -f "$VERSION_FILE" ]]; then
    LOCAL_ID=$(cat "$VERSION_FILE")
    if [[ "$REMOTE_ID" == "$LOCAL_ID" ]]; then
        log_ok "RetroArch is already at the latest nightly build."
        log_info "Launching..."
        cd "$INSTALL_DIR" && ./RetroArch-Linux-x86_64.AppImage
        exit 0
    fi
fi

log_warn "New update detected: $LATEST_FILENAME"

# 3. Optimized Download & Clean Extraction
# Use -C - to resume if a previous download was interrupted
mkdir -p "$TEMP_DIR"
log_info "Downloading (using parallel streams if possible)..."
curl -L -# -o "$TEMP_DIR/RA.7z" "$BASE_URL$LATEST_FILENAME"

log_info "Performing clean extraction..."
# Extract to a subfolder within temp
7z x "$TEMP_DIR/RA.7z" -o"$TEMP_DIR/extracted" -y > /dev/null

# 4. Atomic Update
mkdir -p "$INSTALL_DIR"
cp -af "$TEMP_DIR/extracted/RetroArch-Linux-x86_64/." "$INSTALL_DIR/"

# 5. Finalize & Cleanup
chmod +x "$INSTALL_DIR/RetroArch-Linux-x86_64.AppImage"
echo "$REMOTE_ID" > "$VERSION_FILE"
rm -rf "$TEMP_DIR"

log_ok "Update applied successfully."
echo -e "\033[1;30m--------------------------------------------------\033[0m"

# 6. Execute
cd "$INSTALL_DIR" && ./RetroArch-Linux-x86_64.AppImage
