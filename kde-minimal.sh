#!/usr/bin/env bash
# Minimal KDE Plasma 6 installer for a fresh Arch Linux install.
# Assumes git is already installed (you used it to pull this script).
# Clones yay-bin into ~/sources, installs it, then installs the KDE packages.
# Run as a normal user with sudo rights (not as root):
#   chmod +x kde-minimal.sh && ./kde-minimal.sh

set -euo pipefail

SOURCES_DIR="$HOME/sources"

if [[ $EUID -eq 0 ]]; then
    echo "Run this as a normal user with sudo, not as root." >&2
    exit 1
fi

if ! command -v git >/dev/null 2>&1; then
    echo "git is not installed. Install it first: sudo pacman -S git" >&2
    exit 1
fi

if ! ping -c1 -W3 archlinux.org >/dev/null 2>&1; then
    echo "No internet connection. Connect first (nmcli / iwctl) and retry." >&2
    exit 1
fi

# ---------------------------------------------------------------
# Step 1: yay-bin, cloned into ~/sources
# ---------------------------------------------------------------
mkdir -p "$SOURCES_DIR"

if ! command -v yay >/dev/null 2>&1; then
    echo ">> Installing build prerequisite (base-devel)..."
    sudo pacman -Syu --needed --noconfirm base-devel

    if [[ -d "$SOURCES_DIR/yay-bin/.git" ]]; then
        echo ">> Updating existing yay-bin clone..."
        git -C "$SOURCES_DIR/yay-bin" pull --ff-only
    else
        echo ">> Cloning yay-bin into $SOURCES_DIR..."
        git clone https://aur.archlinux.org/yay-bin.git "$SOURCES_DIR/yay-bin"
    fi

    echo ">> Building and installing yay-bin..."
    (cd "$SOURCES_DIR/yay-bin" && makepkg -si --noconfirm)
else
    echo ">> yay already installed, skipping."
fi

# ---------------------------------------------------------------
# Step 2: KDE Plasma 6 minimal packages
# ---------------------------------------------------------------
PKGS=(
    # Plasma core
    plasma-desktop systemsettings plasma-workspace plasma-nm plasma-pa
    bluedevil powerdevil kscreen kwallet-pam xdg-desktop-portal-kde
    kde-cli-tools kmenuedit kinfocenter plasma-systemmonitor kdeplasma-addons
    plasma-workspace-wallpapers

    # Login manager
    sddm sddm-kcm

    # Audio
    pipewire pipewire-pulse pipewire-alsa wireplumber

    # Theming support
    breeze breeze-gtk kde-gtk-config kvantum qt6-svg

    # Core apps
    dolphin konsole kate ark spectacle gwenview kio-extras kio-admin
    kdegraphics-thumbnailers ffmpegthumbs

    # Fonts
    noto-fonts noto-fonts-emoji ttf-dejavu

    # Intel graphics + power
    mesa intel-media-driver vulkan-intel tlp

    # Tools
    xdg-user-dirs
)

echo ">> Installing KDE packages with yay..."
yay -S --needed --noconfirm "${PKGS[@]}"

# ---------------------------------------------------------------
# Step 3: Services
# ---------------------------------------------------------------
echo ">> Enabling services..."
sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service 2>/dev/null || true
sudo systemctl enable bluetooth.service
sudo systemctl enable tlp.service

echo ">> Creating user directories..."
xdg-user-dirs-update

echo
echo "Done. Reboot now:  sudo reboot"
echo "At the SDDM login screen, choose 'Plasma (Wayland)'."
