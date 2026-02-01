#!/bin/bash
# Validate DE/WM installation after package install

DE_CHOSEN=$(cat /tmp/calamares-desktop-choice)

case $DE_CHOSEN in
  hyprland|sway|cosmic)
    # Wayland sessions need special validation
    if ! grep -q "WAYLAND_DISPLAY" /home/$USERNAME/.xinitrc 2>/dev/null; then
      echo "CONFIG: Setting up Wayland session for $DE_CHOSEN"
      echo "export XDG_SESSION_TYPE=wayland" > /home/$USERNAME/.xinitrc
      echo "export MOZ_ENABLE_WAYLAND=1" >> /home/$USERNAME/.xinitrc
      echo "exec $DE_CHOSEN" >> /home/$USERNAME/.xinitrc
    fi
    ;;
  plasma)
    # Ensure SDDM theme is set to StormOS
    sed -i 's/^Current=.*/Current=stormos-sddm/' /etc/sddm.conf.d/kde_settings.conf
    ;;
  xfce-stormos)
    # Apply StormOS panel layout
    cp -r /etc/skel/.config/xfce4 /home/$USERNAME/.config/
    chown -R $USERNAME:$USERNAME /home/$USERNAME/.config/xfce4
    ;;
esac

# Set Dracula GTK theme globally
cat > /etc/gtk-3.0/settings.ini << 'EOF'
[Settings]
gtk-theme-name=Dracula-StormOS
gtk-icon-theme-name=Papirus-Dark
gtk-font-name=JetBrains Mono 10
gtk-cursor-theme-name=Bibata-Modern-Ice
gtk-cursor-theme-size=24
gtk-toolbar-style=GTK_TOOLBAR_BOTH_HORIZ
gtk-toolbar-icon-size=GTK_ICON_SIZE_LARGE_TOOLBAR
gtk-button-images=0
gtk-menu-images=0
gtk-enable-event-sounds=1
gtk-enable-input-feedback-sounds=1
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintslight
gtk-xft-rgba=rgb
EOF
