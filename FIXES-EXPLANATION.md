# Calamares Configuration Fixes - StormOS

## Issue 1: Reboot goes into liveuser instead of installed system

### Problem
After installation completes, the system reboots into the liveuser account instead of booting from the installed StormOS system.

### Root Cause Analysis
The bootloader configuration may not be properly:
1. Setting the correct boot device/partition as the primary boot target
2. Updating the EFI boot order to prioritize the installed system
3. Configuring GRUB to detect and boot from the installed kernel

### Solution Applied in bootloader.conf
- Added proper `efiBootMgr` configuration for EFI boot management
- Ensured `installEFIFallback: true` for BIOS compatibility
- Set `writeSystemdBoot: false` to use GRUB as the primary bootloader
- Added `ensureRemovable: false` to prevent boot priority issues

### Additional Recommendations
1. **GRUB Configuration (grubcfg.conf)**:
   - Ensure `GRUB_DEFAULT: "saved"` boots from the saved entry
   - Consider adding `GRUB_DISABLE_OS_PROBER="false"` to detect other OSes

2. **Post-Install Script**:
   - Add a shell process to update EFI boot order after installation:
   ```bash
   # Update EFI boot order to prioritize installed system
   efibootmgr --bootorder <installed_entry>,<fallback>
   ```

3. **Verify bootloader.targetLink in partition module**:
   - Ensure it's set to the correct boot partition

---

## Issue 2: White Flashing Before Calamares Loads

### Problem
A white flash appears before Calamares loads and during transitions between screens.

### Root Cause Analysis
1. Qt initializes with default (light) theme before stylesheet loads
2. Environment variables for dark mode may not be set early enough
3. No splash/loading screen during initialization

### Solution - Environment Variables for storm_welcome
The storm_welcome app should set these before launching Calamares:
```python
dark_env = {
    "QT_STYLE_OVERRIDE": "Fusion",
    "QT_QPA_PLATFORMTHEME": "qt6ct",  # or "gtk"
    "GTK_THEME": "Adwaita:dark",
    "XCURSOR_THEME": "Adwaita",
    "QT_QUICK_CONTROLS_STYLE": "Material",
    "QT_QUICK_CONTROLS_MATERIAL_THEME": "Dark",
}
```

### Additional Recommendations for Calamares
1. Add a `calamares.desktop` file with proper environment variables
2. Create a launch wrapper script that sets dark mode before starting Calamares
3. Add the dark theme colors directly to the branding.desc:
```yaml
style:
   SidebarBackground: "#1e1e20"
   SidebarText: "#ffffff"
```

---

## Issue 3: Theming/Branding Not Applied Correctly

### Problem
The Calamares dark theme and StormOS branding are not displaying correctly.

### Root Cause Analysis
1. The `stylesheet.qss` may have widget selectors that don't match actual Qt widget names
2. The `branding.desc` windowSize may not match actual display resolution
3. Color definitions may conflict between stylesheet.qss and branding.desc

### Solution in branding.desc
```yaml
windowExpanding: noexpand
windowSize: 1280px,720px
windowPlacement: center

style:
   SidebarBackground:    "#1e1e20"
   SidebarText:          "#FFFFFF"
   SidebarBackgroundCurrent: "#2d2d30"
```

### Stylesheet.qss Fixes
Key fixes needed:
- Ensure `#sidebarApp` selector matches the actual sidebar widget name
- Add fallback colors for all widget states
- Use proper Qt palette color roles

### Recommended Changes
1. Match sidebar selector to actual Calamares widget:
   ```css
   /* Correct selector for Calamares sidebar */
   #sidebarApp {
       background-color: #1e1e20;
   }
   ```

2. Add initialization styling to prevent white flash:
   ```css
   QMainWindow {
       background-color: #252527;
   }
   ```

---

## Summary of Files to Modify

| File | Issue | Fix |
|------|-------|-----|
| `modules/bootloader.conf` | Boot to liveuser | Ensure proper boot order |
| `modules/grubcfg.conf` | Boot to liveuser | GRUB default settings |
| `branding/Storm/branding.desc` | Theming | Window size/placement |
| `branding/Storm/stylesheet.qss` | White flash/theming | Add fallback styles |

---

## Testing Checklist

- [ ] System boots to installed StormOS after reboot
- [ ] No white flashing during Calamares launch
- [ ] Dark theme displays correctly on all screens
- [ ] Sidebar styling matches branding.desc colors
- [ ] GRUB menu shows correct entries
