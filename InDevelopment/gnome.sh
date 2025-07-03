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
