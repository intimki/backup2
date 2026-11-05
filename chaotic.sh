#!/bin/bash
sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com >/dev/null 2>&1
sudo pacman-key --lsign-key 3056513887B78AEB >/dev/null 2>&1
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' >/dev/null 2>&1
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst' >/dev/null 2>&1
echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf >/dev/null
