#!/bin/bash
set -e

KEY="F3B607488DB35A47"
CONF="/etc/pacman.conf"

sudo pacman-key --recv-keys "$KEY" --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key "$KEY"

sudo pacman -U --noconfirm \
'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-27-1-any.pkg.tar.zst' \
'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-27-1-any.pkg.tar.zst' \
'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v4-mirrorlist-27-1-any.pkg.tar.zst' \
'https://mirror.cachyos.org/repo/x86_64/cachyos/pacman-7.1.0.r9.g54d9411-4-x86_64.pkg.tar.zst'

BLOCK='
[cachyos-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos-core-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos-extra-znver4]
Include = /etc/pacman.d/cachyos-v4-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
'

export BLOCK
sudo -E awk '
  BEGIN { inserted = 0 }
  $0 == "#[core-testing]" && !inserted {
      print ENVIRON["BLOCK"]
      inserted = 1
  }
  { print }
' "$CONF" > /tmp/pacman.conf.new

sudo mv /tmp/pacman.conf.new "$CONF"

# Обновление системы
sudo pacman -Syyu --noconfirm

# Установка пакетов (в алфавитном порядке)
sudo pacman -S --noconfirm \
alsa-utils \
base-devel \
ddcutil \
discord \
firefox \
firefox-i18n-uk \
git \
hyprland \
i2c-tools \
kitty \
lact \
libva-nvidia-driver \
linux-cachyos-bore \
linux-cachyos-bore-headers \
nano \
nautilus \
noctalia \
nvidia-open-dkms \
nwg-look \
openrgb \
pavucontrol \
power-profiles-daemon \
qt5ct \
qt6ct \
realtime-privileges \
rtirq \
xorg-fonts-misc \
xpadneo-dkms \
xdg-desktop-portal-hyprland

# Настройка systemd-resolved
sudo systemctl enable systemd-resolved
sudo ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Настройка rtirq
sudo systemctl enable rtirq

# Сборка и установка AUR-пакетов
git clone https://aur.archlinux.org/rtl8761b-firmware.git || true
cd rtl8761b-firmware
makepkg -sirc --noconfirm
cd ..

git clone https://aur.archlinux.org/apple_cursor.git || true
cd apple_cursor
makepkg -sirc --noconfirm
cd ..

git clone https://aur.archlinux.org/adwaita-colors-icon-theme.git || true
cd adwaita-colors-icon-theme
makepkg -sirc --noconfirm
cd ..

# Клонирование и настройка backup2
git clone https://github.com/intimki/backup2 || true
cd backup2
mkdir -p ~/.config/hypr/
mv -f hyprland.lua ~/.config/hypr/

sudo mkdir -p /etc/cmdline.d/
sudo mv -f 10-power.conf 20-performance.conf 30-input.conf /etc/cmdline.d/

cd ..
rm -rf backup2/
