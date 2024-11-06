# calamares-config

# AcreetionOS Calamares Configuration & Boot Fix

This repository contains the custom Calamares installer configuration files for AcreetionOS, including a crucial post-installation boot fix script.

## Overview

These configuration files and scripts customize the Calamares installer framework for AcreetionOS. The configuration handles partitioning, package installation, system configuration, and includes a specialized post-installation script to ensure proper boot setup.

## Key Components

### Main Configuration Files
- `settings.conf` - Main Calamares configuration and module sequence
- `modules/` - Directory containing module-specific configurations:
 - `packages.conf` - Package installation configuration
 - `bootloader.conf` - GRUB bootloader settings 
 - `fstab.conf` - Filesystem table configuration (ext4/fat32)
 - `unpackfs.conf` - Root filesystem unpacking settings
 - `shellprocess.conf` - Post-installation script configuration

### Boot Fix Script
`scripts/postinstall.sh` - Comprehensive boot setup script that handles:
- GRUB installation for both UEFI and BIOS systems
- EFI directory structure creation and verification
- Bootloader configuration and backup
- Initramfs generation
- System boot verification
- Detailed logging for troubleshooting

### Branding
- `branding/AcreetionOS/` - Custom branding elements
 - `branding.desc` - Branding settings and strings
 - `logo.png` - Distribution logo
 - `show.qml` - Slideshow configuration

## Installation Sequence

1. Welcome & Language Selection
2. Partition Setup (ext4 for root, fat32 for EFI)
3. User Creation
4. System Installation
5. Package Installation
6. Post-Installation Boot Fix Script Execution
7. Final Configuration

## Requirements

- Arch Linux base system
- Calamares dependencies
- Required packages:
 - grub
 - efibootmgr
 - mkinitcpio
 - linux
 - linux-firmware
 - os-prober
 
 
