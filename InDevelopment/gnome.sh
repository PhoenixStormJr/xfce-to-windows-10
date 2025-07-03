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
