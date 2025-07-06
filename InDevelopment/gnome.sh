#!/bin/bash
echo "expanding entire volume of usable space, to use entire disk..."
# Get the root logical volume device
LV=$(sudo findmnt -n -o SOURCE /)
FSTYPE=$(sudo findmnt -n -o FSTYPE /)
echo "[🔍] Checking for unused LVM space..."
# Get free extents in the volume group
FREE_PE=$(sudo vgdisplay | awk '/Free  *PE/ { print $5 }')
if [ "$FREE_PE" -gt 0 ]; then
    echo "[📦] Unallocated space detected. Expanding root volume..."
    # Extend the logical volume only if there's free space
    sudo lvextend -l +100%FREE "$LV" >/dev/null 2>&1
    # Resize filesystem depending on type
    if [ "$FSTYPE" = "ext4" ]; then
        echo "[🧱] Resizing ext4 filesystem..."
        sudo resize2fs "$LV" >/dev/null 2>&1
    elif [ "$FSTYPE" = "xfs" ]; then
        echo "[🧱] Resizing XFS filesystem..."
        sudo xfs_growfs / >/dev/null 2>&1
    else
        echo "[❌] Unsupported filesystem type: $FSTYPE"
        exit 1
    fi
    echo "[✅] Root volume successfully expanded to use all available space."
else
    echo "[✅] No unallocated space. Root volume is already fully expanded."
fi
sudo add-apt-repository ppa:agornostal/ulauncher -y
sudo apt update
#Install dependencies:
sudo apt install -y nemo gnome-tweaks ttf-mscorefonts-installer ulauncher
# Set Nemo as default file manager for folders
xdg-mime default nemo.desktop inode/directory
set -e
OVERRIDE_DIR="/etc/systemd/system/systemd-networkd-wait-online.service.d"
OVERRIDE_FILE="$OVERRIDE_DIR/timeout.conf"
# === SYSTEMD CHECK ===
if ! pidof systemd > /dev/null; then
    echo "❌ Not a systemd-based system. Skipping systemd-networkd-wait-online configuration."
else
    # === SERVICE EXISTENCE CHECK ===
    if systemctl list-unit-files | grep -q systemd-networkd-wait-online.service; then
        # === APPLY TIMEOUT CONFIGURATION ===
        echo "✅ Detected systemd-networkd-wait-online.service — applying timeout override."
        sudo mkdir -p "$OVERRIDE_DIR"
        if grep -q -- '--timeout=10' "$OVERRIDE_FILE" 2>/dev/null; then
            echo "⏩ Timeout already set to 10 seconds in $OVERRIDE_FILE"
        else
            echo "⚙️  Setting timeout to 10 seconds for systemd-networkd-wait-online.service"
            sudo tee "$OVERRIDE_FILE" > /dev/null <<EOF
[Service]
ExecStart=
ExecStart=/lib/systemd/systemd-networkd-wait-online --timeout=10
EOF
        fi
        # === RELOAD SYSTEMD TO APPLY CHANGES ===
        sudo systemctl daemon-reexec
        sudo systemctl daemon-reload
        echo "✅ systemd-networkd-wait-online timeout config applied (or already present)"
    else
        echo "ℹ️ systemd-networkd-wait-online.service not found — skipping override."
    fi
fi
#Adding right click menu.
mkdir -p ~/Templates
if [ ! -f ~/Templates/"Empty File.txt" ]; then
    touch ~/Templates/"Empty File.txt"
fi
set -e
UUID="dash-to-panel@jderose9.github.com"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$UUID"
ZIP_URL="https://extensions.gnome.org/extension-data/dash-to-paneljderose9.github.com.v65.shell-extension.zip"
echo "🔍 Checking if Dash to Panel is installed..."
if [ ! -d "$EXT_DIR" ]; then
  echo "⚠️ Dash to Panel not installed — installing fallback v65..."
  sudo apt install -y curl unzip gnome-shell-extensions
  echo "🌐 Downloading..."
  curl -sL "$ZIP_URL" -o /tmp/dash-to-panel.zip
  echo "📦 Extracting..."
  mkdir -p "$EXT_DIR"
  unzip -o /tmp/dash-to-panel.zip -d "$EXT_DIR"
else
  echo "ℹ️ Dash to Panel already installed."
fi
echo "🔍 Checking if Dash to Panel is enabled..."
if ! gnome-extensions info "$UUID" 2>/dev/null | grep -q "State: ENABLED"; then
  echo "🚀 Enabling Dash to Panel..."
  gnome-extensions enable "$UUID" || echo "⚠️ May need GNOME shell restart for effect."
else
  echo "✅ Dash to Panel already enabled."
fi
echo "🎉 Done!"
set -e
UUID="arcmenu@arcmenu.com"
EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$UUID"
ZIP_URL="https://extensions.gnome.org/extension-data/arcmenuarcmenu.com.v50.shell-extension.zip"
echo "🔍 Checking if Arc Menu is installed..."
if [ ! -d "$EXT_DIR" ]; then
  echo "⚠️ Arc Menu not installed — installing fallback v50..."
  echo "🌐 Downloading..."
  curl -sL "$ZIP_URL" -o /tmp/arcmenu.zip
  echo "📦 Extracting..."
  mkdir -p "$EXT_DIR"
  unzip -o /tmp/arcmenu.zip -d "$EXT_DIR"
else
  echo "ℹ️ Arc Menu already installed."
fi
echo "🔍 Checking if Arc Menu is enabled..."
if ! gnome-extensions info "$UUID" 2>/dev/null | grep -q "State: ENABLED"; then
  echo "🚀 Enabling Arc Menu..."
  gnome-extensions enable "$UUID" || echo "⚠️ May need GNOME shell restart for effect."
else
  echo "✅ Arc Menu already enabled."
fi
echo "🎉 Arc Menu setup complete!"
gnome-extensions disable ubuntu-dock@ubuntu.com
dconf load /org/gnome/shell/extensions/dash-to-panel/ < dash-to-panel-windows-10.txt
dconf load /org/gnome/shell/extensions/arcmenu/ < arc-menu-windows-10.txt
#dconf read /org/gnome/shell/favorite-apps > favorite-apps-windows-10.txt
dconf write /org/gnome/shell/favorite-apps "$(cat favorite-apps-windows-10.txt)"
# System-wide Windows 10 GTK theme installation
THEME_NAME="Windows 10"
THEME_DIR="/usr/share/themes/$THEME_NAME"
TMP_ZIP="/tmp/windows-10-theme.zip"
# Only install if theme is not already present
if [ ! -d "$THEME_DIR" ]; then
    echo "[INFO] Installing Windows 10 GTK theme system-wide..."
    sudo mkdir -p /usr/share/themes
    # Download and extract
    curl -L -o "$TMP_ZIP" https://github.com/B00merang-Project/Windows-10/archive/refs/heads/master.zip
    sudo unzip -q "$TMP_ZIP" -d /usr/share/themes
    sudo mv /usr/share/themes/Windows-10-master "$THEME_DIR"
    rm -f "$TMP_ZIP"
else
    echo "[INFO] Theme already installed: $THEME_DIR"
fi
#Change positions of new icons like Windows 10:
gsettings set org.gnome.shell.extensions.ding start-corner 'top-left'
# Optionally set it (comment out if not needed in the larger script)
echo "Applying Windows 10 theme"
gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
gsettings set org.gnome.shell.extensions.user-theme name 'Windows 10'
ICON_DIR="/usr/share/icons/Windows-10-Icons"
echo "Checking if Windows 10 icon theme is already installed..."
if [ ! -d "$ICON_DIR" ]; then
    echo "Icon theme not found. Proceeding with installation..."
    echo "Updating package lists..."
    sudo apt update
    echo "downloading windows 10 icon theme from b00merang"
    git clone https://github.com/B00merang-Artwork/Windows-10.git
    echo "changing name of the icon folder to Windows-10-Icons"
    mv Windows-10 Windows-10-Icons
    echo "Moving Windows-10-Icons to /usr/share/icons"
    sudo mv Windows-10-Icons /usr/share/icons
    echo "untarring kali windows 10 icons"
    tar -xvf ../setupStuff/Kali-Windows-10-Icons.tar
    echo "copying missing icons to /usr/share/icons/Windows-10-Icons"
    sudo cp -r Kali-Windows-10-Icons/8x8 /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/16x16 /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/22x22 /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/24x24 /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/32x32 /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/48x48 /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/128x128 /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/256x256 /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/512x512 /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/cursors /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/scalable /usr/share/icons/Windows-10-Icons
    sudo cp -r Kali-Windows-10-Icons/index.theme /usr/share/icons/Windows-10-Icons
    echo "multiple icons have not been copied from Windows, I copied some and others I found online."
    sudo rm /usr/share/icons/Windows-10-Icons/22x22/apps/thunderbird.svg
    sudo rm /usr/share/icons/Windows-10-Icons/24x24/apps/thunderbird.svg
    sudo rm /usr/share/icons/Windows-10-Icons/32x32/apps/thunderbird.svg
    sudo rm /usr/share/icons/Windows-10-Icons/48x48/apps/thunderbird.svg
    sudo rm /usr/share/icons/Windows-10-Icons/128x128/apps/thunderbird.svg
    sudo cp -r ../setupStuff/MissingIcons/Windows-10-Icons /usr/share/icons/
else
    echo "Windows 10 icon theme already exists. Skipping installation."
fi
if [ -d "$ICON_DIR" ]; then
    echo "making sure the windows 10 icons can be read but not deleted"
    sudo chmod 555 -R /usr/share/icons/Windows-10-Icons
    echo "Permissions updated successfully."
    echo "changing icons to Windows-10-Icons"
    gsettings set org.gnome.desktop.interface icon-theme 'Windows-10-Icons'
    echo "changing cursor to Windows-10-Icons"
    gsettings set org.gnome.desktop.interface cursor-theme "Windows-10-Icons"
else
    echo "Icon folder not found. Skipping chmod."
fi
sudo rm /usr/share/applications/ulauncher.desktop
sudo cp ../setupStuff/desktopFiles/applications/show_desktop.desktop /usr/share/applications/show_desktop.desktop
sudo cp ../setupStuff/desktopFiles/applications/ulauncher.desktop /usr/share/applications/ulauncher.desktop
cp ../setupStuff/desktopFiles/applications/thunderbird_thunderbird.desktop ~/.local/share/applications
# Set GNOME font settings
gsettings set org.gnome.desktop.interface font-name 'Segoe UI 11'
gsettings set org.gnome.desktop.interface document-font-name 'Segoe UI 11'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Segoe UI Bold 11'
gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 12'
# Updated antialiasing and hinting options
gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
gsettings set org.gnome.desktop.interface font-hinting 'slight'
BG_PATH="/usr/share/backgrounds/Windows-10.jpg"
echo "Checking if background image is already installed..."
if [ ! -f "$BG_PATH" ]; then
    echo "Windows 10 Background not found. Copying now..."
    sudo cp ../setupStuff/Windows-10.jpg /usr/share/backgrounds/
    echo "Windows 10 Background copied successfully."
else
    echo "Windows 10 Background already exists. Skipping copy."
fi
if [ -f "$BG_PATH" ]; then
    echo "applying Windows 10 background to your desktop"
    gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/Windows-10.jpg'
    gsettings set org.gnome.desktop.background picture-options "zoom"
else
    echo "Background image not found at $BG_PATH. Skipping background application."
fi
#Finally when all is done, log out and log back in:
gnome-session-quit --logout
