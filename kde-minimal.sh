#!/usr/bin/env bash
# Minimal KDE Plasma 6 installer for a fresh Arch Linux install.
# Run as a normal user with sudo rights (not as root):
#   chmod +x kde-minimal.sh && ./kde-minimal.sh

set -euo pipefail

if [[ $EUID -eq 0 ]]; then
    echo "Run this as a normal user with sudo, not as root." >&2
    exit 1
fi

if ! ping -c1 -W3 archlinux.org >/dev/null 2>&1; then
    echo "No internet connection. Connect first (nmcli / iwctl) and retry." >&2
    exit 1
fi

PKGS=(
    # Plasma core
    plasma-desktop systemsettings plasma-workspace plasma-nm plasma-pa
    bluedevil powerdevil kscreen kwallet-pam xdg-desktop-portal-kde
    kde-cli-tools kmenuedit kinfocenter plasma-systemmonitor kdeplasma-addons
    plasma-workspace-wallpapers

    # Login manager
    sddm sddm-kcm

    # Audio
    pipewire pipewire-pulse pipewire-alsa wireplumber sof-firmware

    # Theming support
    breeze breeze-gtk kde-gtk-config kvantum qt6-svg

    # Core apps
    dolphin konsole kate ark spectacle kio-extras kio-admin
    kdegraphics-thumbnailers ffmpegthumbs gwenview

    # Fonts
    noto-fonts noto-fonts-emoji ttf-dejavu

    # Intel graphics + power
    mesa intel-media-driver vulkan-intel tlp

    # Tools
    git base-devel xdg-user-dirs
)

echo ">> Updating system and installing packages..."
sudo pacman -Syu --needed --noconfirm "${PKGS[@]}"

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
