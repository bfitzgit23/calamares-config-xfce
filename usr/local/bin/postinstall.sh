#!/bin/bash -e
#
##############################################################################
#
#  PostInstall is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your discretion) any later version.
#
#  PostInstall is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
##############################################################################

 name=$(ls -1 /home)
 REAL_NAME=/home/$name

cp /cinnamon-configs/cinnamon-stuff/bin/* /bin/
cp /cinnamon-configs/cinnamon-stuff/usr/bin/* /usr/bin/
cp -r /cinnamon-configs/cinnamon-stuff/usr/share/* /usr/share/

mkdir /home/$name/.config
mkdir /home/$name/.config/nemo

cp -r /cinnamon-configs/cinnamon-stuff/nemo/* /home/$name/.config/nemo

cp -r /cinnamon-configs/cinnamon-stuff/.config/* /home/$name/.config/

mkdir /home/$name/.config/autostart

cp -r /cinnamon-configs/dd.desktop /home/$name/.config/autostart

chown -R $name:$name /home/$name/.config

cp -r /cinnamon-configs/.bashrc /home/$name/.bashrc

#!/bin/bash
#!/bin/bash

# Log function
log() {
   echo "[Postinstall] $1"
}

log "Starting complete boot setup..."

# Show initial system state
log "Initial system state:"
ls -la /boot /boot/efi 2>/dev/null
mount | grep -E "boot|efi"

# Get the actual install device (don't just assume sda)
INSTALL_DEVICE=$(lsblk -o NAME,MOUNTPOINT -n | grep -E '/$' | cut -d' ' -f1)
INSTALL_DEVICE="/dev/$(echo $INSTALL_DEVICE | sed 's/[0-9]*$//')"
log "Detected install device: $INSTALL_DEVICE"

# Create necessary directories with more explicit EFI structure
log "Creating boot directories..."
mkdir -p /boot || log "Failed to create /boot"
mkdir -p /boot/grub || log "Failed to create /boot/grub"
mkdir -p /boot/efi || log "Failed to create /boot/efi"
mkdir -p /boot/efi/EFI/GRUB || log "Failed to create GRUB EFI directory"
mkdir -p /boot/efi/EFI/BOOT || log "Failed to create EFI BOOT directory"

# Mount necessary filesystems
log "Mounting virtual filesystems..."
mount -t proc proc /proc 2>/dev/null || log "Failed to mount proc"
mount -t sysfs sys /sys 2>/dev/null || log "Failed to mount sysfs"
mount -t devtmpfs udev /dev 2>/dev/null || log "Failed to mount devtmpfs"
mount -t efivarfs efivarfs /sys/firmware/efi/efivars 2>/dev/null || log "EFI vars mount failed (might be normal for BIOS)"

# Create initial mkinitcpio config
log "Creating mkinitcpio configuration..."
cat > /etc/mkinitcpio.conf << EOF
MODULES=(ext4)
BINARIES=()
FILES=()
HOOKS=(base udev block autodetect modconf filesystems keyboard fsck)
EOF

# Create more detailed GRUB config
log "Creating GRUB configuration..."
cat > /etc/default/grub << EOF
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="AcreetionOS"
GRUB_CMDLINE_LINUX_DEFAULT="quiet loglevel=3"
GRUB_CMDLINE_LINUX=""
GRUB_PRELOAD_MODULES="part_gpt part_msdos"
GRUB_TIMEOUT_STYLE=menu
GRUB_TERMINAL_OUTPUT="console"
GRUB_DISABLE_OS_PROBER=false
GRUB_DISABLE_SUBMENU=y
# For better boot menu detection
GRUB_HIDDEN_TIMEOUT=0
GRUB_HIDDEN_TIMEOUT_QUIET=false
EOF

# Install GRUB with more explicit error checking
log "Installing GRUB bootloader..."
if [ -d /sys/firmware/efi ]; then
   log "Detected UEFI system"
   
   # Verify EFI mount
   if ! mountpoint -q /boot/efi; then
       log "ERROR: /boot/efi is not mounted"
       ls -l /boot/efi
       mount | grep efi
       log "Attempting to proceed anyway..."
   fi
   
   # Ensure directories exist and show their state
   log "Creating and verifying EFI directories..."
   mkdir -p /boot/efi/EFI/GRUB
   mkdir -p /boot/efi/EFI/BOOT
   ls -la /boot/efi/EFI/
   
   # Install GRUB for UEFI with maximum verbosity
   log "Installing GRUB EFI (verbose)..."
   grub-install \
       --target=x86_64-efi \
       --efi-directory=/boot/efi \
       --bootloader-id=GRUB \
       --boot-directory=/boot \
       --recheck \
       --removable \
       --verbose
   
   GRUB_INSTALL_STATUS=$?
   log "GRUB install exited with status: $GRUB_INSTALL_STATUS"
   
   # Create direct EFI boot entry
   if [ -f /boot/efi/EFI/GRUB/grubx64.efi ]; then
       log "Creating EFI boot entry..."
       efibootmgr -c -d $INSTALL_DEVICE -p 1 -L "GRUB" -l "\\EFI\\GRUB\\grubx64.efi"
   fi
   
   # Show what files were created
   log "Files in EFI directory after GRUB install:"
   ls -R /boot/efi/EFI/
   
   # Wait a moment and check for EFI file
   sleep 2
   
   # Try multiple known locations for the EFI file
   EFI_LOCATIONS=(
       "/boot/efi/EFI/GRUB/grubx64.efi"
       "/boot/efi/EFI/grub/grubx64.efi"
       "/boot/efi/EFI/BOOT/BOOTX64.EFI"
   )
   
   EFI_FOUND=0
   for efi_file in "${EFI_LOCATIONS[@]}"; do
       if [ -f "$efi_file" ]; then
           log "Found EFI file at: $efi_file"
           EFI_FOUND=1
           # Copy to backup location if not already there
           if [ "$efi_file" != "/boot/efi/EFI/BOOT/BOOTX64.EFI" ]; then
               log "Copying to backup location..."
               cp -fv "$efi_file" /boot/efi/EFI/BOOT/BOOTX64.EFI
           fi
       fi
   done
   
   if [ $EFI_FOUND -eq 0 ]; then
       log "ERROR: No EFI file found in any known location"
       log "Directory contents:"
       find /boot/efi -type f -ls
   fi

else
   log "Detected BIOS system"
   grub-install \
       --target=i386-pc \
       --recheck \
       --boot-directory=/boot \
       $INSTALL_DEVICE || {
           log "BIOS GRUB install failed"
           exit 1
       }
fi

# Generate initramfs
log "Generating initramfs..."
mkinitcpio -P linux || log "Initramfs generation failed"

# Ensure os-prober is installed and can find other OSes
log "Running os-prober..."
os-prober || log "No other operating systems found"

# Generate GRUB config with extra debugging
log "Generating GRUB configuration..."
grub-mkconfig -o /boot/grub/grub.cfg || log "GRUB config generation failed"

# Verify GRUB config content
log "Verifying GRUB config content:"
if [ -f /boot/grub/grub.cfg ]; then
   grep -i "menuentry" /boot/grub/grub.cfg || log "No menu entries found in GRUB config"
fi

# Check for core.img in BIOS mode
if [ ! -d /sys/firmware/efi ]; then
   log "Checking GRUB core.img..."
   if [ -f /boot/grub/i386-pc/core.img ]; then
       log "GRUB core.img found"
   else
       log "ERROR: GRUB core.img missing"
   fi
fi

# Show current mount points for debugging
log "Current mount points:"
mount | grep -E "boot|efi"

# Verify all required files exist
log "Verifying boot files..."

CHECK_FILES=(
   "/boot/initramfs-linux.img"
   "/boot/vmlinuz-linux"
   "/boot/grub/grub.cfg"
   "/etc/default/grub"
   "/etc/mkinitcpio.conf"
)

for file in "${CHECK_FILES[@]}"; do
   if [ ! -f "$file" ]; then
       log "ERROR: Missing $file"
   else
       log "Verified: $file exists"
   fi
done

# Additional UEFI checks with more debugging
if [ -d /sys/firmware/efi ]; then
   log "Performing UEFI-specific checks..."
   
   if [ ! -d /boot/efi/EFI ]; then
       log "ERROR: EFI directory structure missing"
       mkdir -p /boot/efi/EFI
   fi
   
   EFI_FILES=(
       "/boot/efi/EFI/GRUB/grubx64.efi"
       "/boot/efi/EFI/BOOT/BOOTX64.EFI"
   )
   
   for file in "${EFI_FILES[@]}"; do
       if [ ! -f "$file" ]; then
           log "WARNING: Missing $file"
       else
           log "Verified: $file exists"
       fi
   done
   
   log "EFI directory structure:"
   find /boot/efi -type f -ls
   
   log "EFI boot entries:"
   efibootmgr -v || log "Unable to get EFI boot entries"
fi

# Show boot directory contents
log "Boot directory contents:"
ls -la /boot
log "EFI directory contents (if applicable):"
ls -la /boot/efi/EFI 2>/dev/null

# Verify permissions
log "Setting correct permissions..."
chmod 700 /boot
chmod 700 /boot/efi 2>/dev/null
chmod 600 /boot/initramfs-linux.img

# Final verification
ERRORS=0
for file in "${CHECK_FILES[@]}"; do
   if [ ! -f "$file" ]; then
       ERRORS=$((ERRORS+1))
   fi
done

if [ $ERRORS -eq 0 ]; then
   log "Post-installation completed successfully"
   exit 0
else
   log "Post-installation completed with $ERRORS errors"
   exit 0
fi
