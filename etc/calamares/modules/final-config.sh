#!/bin/bash
# Final SDDM configuration for StormOS

set -e

# Only run if SDDM is installed
if ! command -v sddm &>/dev/null; then
  exit 0
fi

# Ensure wayland-sessions directory exists
mkdir -p /usr/share/wayland-sessions

# Verify Hyprland/Sway session files exist (Arch packages provide these)
if [ ! -f /usr/share/wayland-sessions/hyprland.desktop ]; then
  cat > /usr/share/wayland-sessions/hyprland.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Hyprland
Comment=Hyprland Wayland Compositor
Exec=Hyprland
TryExec=Hyprland
DesktopNames=Hyprland
X-KDE-PluginInfo-Version=0.1.0
EOF
fi

if [ ! -f /usr/share/wayland-sessions/sway.desktop ]; then
  cat > /usr/share/wayland-sessions/sway.desktop << 'EOF'
[Desktop Entry]
Type=Application
Name=Sway
Comment=Sway Wayland Compositor
Exec=sway
TryExec=sway
DesktopNames=Sway
EOF
fi

# Configure SDDM for Wayland (critical for Hyprland/Sway)
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/wayland.conf << 'EOF'
[Wayland]
# Enable Wayland support in SDDM
EnableWayland=true

[General]
# Use Breeze theme (ships with sddm package - no extra deps)
Theme=breeze
DisplayServer=wayland

[Autologin]
User=
Session=
EOF

# Fix permissions
chmod 644 /etc/sddm.conf.d/wayland.conf

# Enable SDDM service
systemctl enable sddm.service

echo "✅ SDDM configured for Wayland sessions (Hyprland/Sway/Plasma)"
