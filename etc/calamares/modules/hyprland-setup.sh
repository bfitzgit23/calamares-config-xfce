#!/bin/bash
USER_HOME="/home/$USERNAME"

# Create Hyprland config structure
mkdir -p "$USER_HOME/.config/hypr"
cat > "$USER_HOME/.config/hypr/hyprland.conf" << 'EOF'
# StormOS Hyprland Config
exec-once = waybar
exec-once = swaybg -i /usr/share/wallpapers/StormOS/default.jpg

# Dracula color scheme
$dracula_bg = rgba(404254ff)
$dracula_fg = rgba(f8f8f2ff)
$dracula_purple = rgba(bd93f9ff)

# Window rules
windowrule = blur,^(?!.*float.*).*
windowrule = opacity 0.95 override 0.8,^(?!.*float.*).*

# Input settings
input {
  kb_layout = us
  follow_mouse = 1
}
EOF

# Set ownership
chown -R $USERNAME:$USERNAME "$USER_HOME/.config/hypr"

# Create systemd user service for auto-start
mkdir -p "$USER_HOME/.config/systemd/user"
cat > "$USER_HOME/.config/systemd/user/hyprland.service" << 'EOF'
[Unit]
Description=Hyprland compositor
BindsTo=graphical-session.target

[Service]
ExecStart=/usr/bin/Hyprland
Restart=on-failure

[Install]
WantedBy=graphical-session.target
EOF

chown -R $USERNAME:$USERNAME "$USER_HOME/.config/systemd"
