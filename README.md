# 🎮 RetroArch Nightly Linux Updater/Launcher

A simple Bash script for to automate the installation, updating, and launching of **RetroArch-Nightly** (x86_64) build on Linux.

## ✨ Features
* **Smart Updates:** Checks ETags to skip downloading if no new build is found.
* **Clean Install:** Installs everything to `~/.retroarch/`.
* **Auto-Launch:** Boots the AppImage immediately after checking/updating.

## 🛠️ Requirements & Usage
Ensure you have `curl` and `7z` installed:
```bash
# Ubuntu/Debian/Mint
sudo apt install curl p7zip-full

# Fedora
sudo dnf install curl p7zip p7zip-plugins

# Arch
sudo pacman -S curl p7zip
```
1. **Save the script** as `retroarch_nightly.sh`.
2. **Make it executable**:
   ```bash
   chmod +x retroarch_nightly.sh
