#!/bin/bash


cd "$(dirname "$0")/../.."
echo "Hello, this is the Linux installer for the application xfce-to-windows-10. This application will transform your linux xfce desktop to a windows 10 like look and feel. Currently there is no ULA. Would you like to install it? Enter y for yes or n for no."
while [ true ]
do
  read -p 'y/n: ' option
  echo you entered $option
  if [ "$option" = "y" ]
  then
    break
  fi
  if [ "$option" = "n" ]
  then
    exit 1
  fi
  if [ "$option" != "n" ] && [ "$option" != "n" ]
  then
    echo "that was not an option. Your options were y or n"
  fi
done


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


#Speeding up boot time by reducing check if internet is connected. 
#This is harmless. It ONLY CHECKS if the internet is connected, LITERALLY DOES NOTHING ELSE!
#NOT EVEN ACTUALLY CONNECT TO THE INTERNET!:
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


#Creating Windows 10 Icons:
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
    tar -xvf setupStuff/Kali-Windows-10-Icons.tar
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
    sudo cp -r setupStuff/MissingIcons/Windows-10-Icons /usr/share/icons/
else
    echo "Windows 10 icon theme already exists. Skipping installation."
fi


#Copying desktop files to their right places.
sudo cp setupStuff/desktopFiles/applications/libreoffice-excel.desktop /usr/share/applications
sudo cp setupStuff/desktopFiles/applications/libreoffice-powerpoint.desktop /usr/share/applications
sudo cp setupStuff/desktopFiles/applications/libreoffice-startcenter.desktop /usr/share/applications
sudo cp setupStuff/desktopFiles/applications/libreoffice-word.desktop /usr/share/applications
sudo cp setupStuff/desktopFiles/applications/ParoleMediaPlayer.desktop /usr/share/applications
sudo cp setupStuff/desktopFiles/applications/RhythmboxMusic.desktop /usr/share/applications
sudo cp setupStuff/desktopFiles/applications/RistrettoImageViewer.desktop /usr/share/applications
sudo cp setupStuff/desktopFiles/applications/thunderbird.desktop /usr/share/applications
sudo cp setupStuff/desktopFiles/applications/thunderbird_thunderbird.desktop /usr/share/applications


BG_PATH="/usr/share/backgrounds/Windows-10.jpg"
echo "Checking if background image is already installed..."
if [ ! -f "$BG_PATH" ]; then
    echo "Windows 10 Background not found. Copying now..."
    sudo cp setupStuff/Windows-10.jpg /usr/share/backgrounds/
    echo "Windows 10 Background copied successfully."
else
    echo "Windows 10 Background already exists. Skipping copy."
fi












DE=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

#If the desktop environment is xfce then install the xfce version of my program:
if [[ "$DE" == *xfce* ]]; then
  echo "xfce"
  DISTROUNKNOWN="true"
  echo $DISTROUNKNOWN
  echo "getting name of your linux distro"
  source /etc/os-release
  echo "the name of your system is:"
  echo $NAME
  echo "installing dependancies"
  if [ "$NAME" = "Ubuntu" ]; then
    sudo apt update --allow-unauthenticated --allow-insecure-repositories
    sudo apt install xfce4-panel-profiles dconf-cli git python3 fonts-liberation gir1.2-glib-2.0 libnotify-bin mousepad procps psmisc xdotool xfce4-datetime-plugin xfce4-power-manager-plugins xfce4-pulseaudio-plugin xfce4-whiskermenu-plugin xfce4-panel-profiles snapd wmctrl -y --allow-unauthenticated
    sudo snap install snap-store
    DISTROUNKNOWN="false"
  fi
  if [ "$NAME" = "Linux Mint" ]; then
    sudo apt update --allow-unauthenticated --allow-insecure-repositories
    sudo apt install xfce4-panel-profiles dconf-cli git python3 fonts-liberation gir1.2-glib-2.0 libnotify-bin mousepad procps psmisc xdotool xfce4-datetime-plugin xfce4-power-manager-plugins xfce4-pulseaudio-plugin xfce4-whiskermenu-plugin xfce4-panel-profiles wmctrl -y --allow-unauthenticated
    DISTROUNKNOWN="false"
  fi
  if [ "$DISTROUNKNOWN" = "true" ]; then
    sudo cp setupStuff/apt/UbuntuSources.list /etc/apt/sources.list.d
    sudo apt update --allow-unauthenticated --allow-insecure-repositories
    echo "UNKNOWN DISTRO DETECTED. we'll go ahead anyway..."
    sudo apt install xfce4-panel-profiles -y --allow-unauthenticated
    sudo apt install dconf-cli -y --allow-unauthenticated
    sudo apt install git -y --allow-unauthenticated
    sudo apt install python3 -y --allow-unauthenticated
    sudo apt install fonts-liberation -y --allow-unauthenticated
    sudo apt install gir1.2-glib-2.0 -y --allow-unauthenticated
    sudo apt install libnotify-bin -y --allow-unauthenticated
    sudo apt install mousepad -y --allow-unauthenticated
    sudo apt install procps -y --allow-unauthenticated
    sudo apt install psmisc -y --allow-unauthenticated
    sudo apt install xdotool -y --allow-unauthenticated
    sudo apt install xfce4-datetime-plugin -y --allow-unauthenticated
    sudo apt install xfce4-power-manager-plugins -y --allow-unauthenticated
    sudo apt install xfce4-pulseaudio-plugin -y --allow-unauthenticated
    sudo apt install xfce4-whiskermenu-plugin -y --allow-unauthenticated
    sudo apt install xfce4-panel-profiles -y --allow-unauthenticated
    sudo apt install snapd -y --allow-unauthenticated
    NAME="Ubuntu"
  fi
  
  
  #Sets a variable to see the Windows 10 theme directory.
  THEME_DIR="/usr/share/themes/Kali-Windows-10-theme"
  #This command checks if Windows 10 theme is already installed.
  echo "Checking if Windows 10 theme is already installed..."
  if [ ! -d "$THEME_DIR" ]; then
    #this command copies the windows 10 theme, from kali, to your theme folder.
    echo "Theme not found. Copying Windows 10 theme to /usr/share/themes/..."
    sudo cp -r setupStuff/Kali-Windows-10-theme "$THEME_DIR"
    echo "Theme installed."
  else
    echo "Theme already exists. Skipping copy."
  fi
  #this command makes sure everyone can use the theme, but no one can delete it.
  echo "making sure the windows 10 theme can be read but not deleted"
  if [ -d "$THEME_DIR" ]; then
    sudo chmod 555 -R "$THEME_DIR"
    echo "Permissions updated to read/execute only."
    #this command applies the new theme we copied to the system.
    echo "applying the theme to your computer"
    xfconf-query -c xsettings -p /Net/ThemeName -s "Kali-Windows-10-theme"
    echo "changing the window buttons to look like Windows 10"
    xfconf-query -c xfwm4 -p /general/theme -n -t string -s "Kali-Windows-10-theme"
  else
    echo "Theme folder not found. Skipping chmod."
  fi
  
  
  if [ -d "$ICON_DIR" ]; then
    echo "making sure the windows 10 icons can be read but not deleted"
    sudo chmod 555 -R /usr/share/icons/Windows-10-Icons
    echo "Permissions updated successfully."
    echo "changing icons to Windows-10-Icons"
    xfconf-query -c xsettings -p /Net/IconThemeName -s Windows-10-Icons
    echo "changing cursor to Windows-10-Icons"
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -n -t string -s "Windows-10-Icons"
  else
    echo "Icon folder not found. Skipping chmod."
  fi
  
  
  echo "Changing the text theme to the windows style."
  xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "Liberation Sans 11"
  echo "changing the button pictures to be like windows 10."
  xfconf-query -c xfwm4 -p /general/button_layout -n -t string -s "|HMC"
  
  
  TAR_FILE="./windowsLike.tar.gz"
  echo "Checking for existing XFCE panel theme archive..."
  if [ ! -f "$TAR_FILE" ]; then
    echo "creating the xfce4 panel theme"
    mkdir windowsLike
    mkdir windowsLike/launcher-2
    mkdir windowsLike/launcher-3
    mkdir windowsLike/launcher-6
    mkdir windowsLike/launcher-7
    mkdir windowsLike/launcher-8
    mkdir windowsLike/launcher-18
    mkdir windowsLike/launcher-19
    echo -e "/configver 2\n/panels [<1>]\n/panels/dark-mode false\n/panels/panel-1/icon-size uint32 24\n/panels/panel-1/length 100.0\n/panels/panel-1/length-adjust true\n/panels/panel-1/plugin-ids [<1>, <2>, <3>, <4>, <5>, <6>, <18>, <7>, <19>, <8>, <9>, <10>, <11>, <12>, <13>, <14>, <16>, <15>, <17>]\n/panels/panel-1/position 'p=8;x=0;y=0'\n/panels/panel-1/position-locked true\n/panels/panel-1/size uint32 44\n/plugins/plugin-1 'whiskermenu'\n/plugins/plugin-10 'separator'\n/plugins/plugin-10/expand true\n/plugins/plugin-10/style uint32 0\n/plugins/plugin-11 'power-manager-plugin'\n/plugins/plugin-12 'systray'\n/plugins/plugin-12/known-items [<'nm-applet'>]\n/plugins/plugin-12/show-frame false\n/plugins/plugin-12/size-max uint32 24\n/plugins/plugin-12/square-icons true\n/plugins/plugin-13 'pulseaudio'\n/plugins/plugin-13/enable-keyboard-shortcuts true\n/plugins/plugin-14 'notification-plugin'\n/plugins/plugin-15 'separator'\n/plugins/plugin-15/style uint32 0\n/plugins/plugin-16 'datetime'\n/plugins/plugin-17 'separator'\n/plugins/plugin-17/style uint32 0\n/plugins/plugin-18 'launcher'\n/plugins/plugin-18/items [<'16878133091.desktop'>]\n/plugins/plugin-19 'launcher'\n/plugins/plugin-19/items [<'16895434911.desktop'>]\n/plugins/plugin-2 'launcher'\n/plugins/plugin-2/items [<'15780470832.desktop'>]\n/plugins/plugin-3 'launcher'\n/plugins/plugin-3/items [<'15780471503.desktop'>]\n/plugins/plugin-4 'showdesktop'\n/plugins/plugin-5 'directorymenu'\n/plugins/plugin-5/base-directory '/home/$USER'\n/plugins/plugin-5/icon-name 'system-file-manager'\n/plugins/plugin-6 'launcher'\n/plugins/plugin-6/items [<'15735608061.desktop'>]\n/plugins/plugin-7 'launcher'\n/plugins/plugin-7/items [<'15780459961.desktop'>]\n/plugins/plugin-8 'launcher'\n/plugins/plugin-8/items [<'15780460092.desktop'>]\n/plugins/plugin-9 'tasklist'\n/plugins/plugin-9/show-handle false\n/plugins/plugin-9/show-labels false" > ./windowsLike/config.txt
    echo -e "favorites=xfce4-terminal-emulator.desktop,xfce4-file-manager.desktop,xfce-text-editor.desktop,xfce4-web-browser.desktop,xfce-ui-settings.desktop,xfce-display-settings.desktop,xfce-settings-manager.desktop,org.xfce.Parole.desktop,org.xfce.ristretto.desktop,xfce-backdrop-settings.desktop\nrecent=\nbutton-icon=xfce4-panel-menu\nbutton-single-row=false\nshow-button-title=false\nshow-button-icon=true\nlauncher-show-name=true\nlauncher-show-description=false\nlauncher-show-tooltip=true\nlauncher-icon-size=4\nhover-switch-category=true\ncategory-show-name=true\ncategory-icon-size=2\nsort-categories=false\nview-mode=0\ndefault-category=0\nrecent-items-max=10\nfavorites-in-recent=true\nposition-search-alternate=true\nposition-commands-alternate=true\nposition-categories-alternate=true\nposition-categories-horizontal=false\nstay-on-focus-out=false\nprofile-shape=0\nconfirm-session-command=true\nmenu-width=678\nmenu-height=710\nmenu-opacity=95\ncommand-settings=xfce4-settings-manager\nshow-command-settings=false\ncommand-lockscreen=xflock4\nshow-command-lockscreen=false\ncommand-switchuser=dm-tool switch-to-greeter\nshow-command-switchuser=false\ncommand-logoutuser=xfce4-session-logout --logout --fast\nshow-command-logoutuser=false\ncommand-restart=xfce4-session-logout --reboot --fast\nshow-command-restart=false\ncommand-shutdown=xfce4-session-logout --halt --fast\nshow-command-shutdown=false\ncommand-suspend=xfce4-session-logout --suspend\nshow-command-suspend=false\ncommand-hibernate=xfce4-session-logout --hibernate\nshow-command-hibernate=false\ncommand-logout=xfce4-session-logout\nshow-command-logout=true\ncommand-menueditor=menulibre\nshow-command-menueditor=false\ncommand-profile=mugshot\nshow-command-profile=false\nsearch-actions=0\n\n" > ./windowsLike/whiskermenu-1.rc
    echo -e "[Desktop Entry]\nVersion=1.0\nExec=xfce4-appfinder\nIcon=edit-find-symbolic\nStartupNotify=true\nTerminal=false\nType=Application\nCategories=Utility;X-XFCE;\nName=Application Finder\n" > ./windowsLike/launcher-2/15780470832.desktop
    echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nName=Next Workspace\nExec=xdotool set_desktop --relative 1\nIcon=xfce4-workspaces\nTerminal=false\nStartupNotify=false\n" > ./windowsLike/launcher-3/15780471503.desktop
    echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nExec=exo-open --launch TerminalEmulator\nIcon=utilities-terminal\nStartupNotify=true\nTerminal=false\nCategories=Utility;X-XFCE;X-Xfce-Toplevel;\nOnlyShowIn=XFCE;\nX-AppStream-Ignore=True\nName=Terminal\n" > ./windowsLike/launcher-6/15735608061.desktop
    echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nExec=exo-open --launch WebBrowser %u\nIcon=web-browser\nStartupNotify=true\nTerminal=false\nCategories=Network;X-XFCE;X-Xfce-Toplevel;\nOnlyShowIn=XFCE;\nX-XFCE-MimeType=x-scheme-handler/http;x-scheme-handler/https;\nX-AppStream-Ignore=True\nName=Web Browser\n" > ./windowsLike/launcher-7/15780459961.desktop
    echo -e "[Desktop Entry]\nName=Text Editor\nExec=mousepad %F\nIcon=accessories-text-editor\nTerminal=false\nStartupNotify=true\nType=Application\nCategories=Utility;TextEditor;GTK;\nMimeType=text/plain;\n" > ./windowsLike/launcher-8/15780460092.desktop
    echo -e "layout=1\ndate_font=Liberation Sans 9\ntime_font=Liberation Sans 9\ndate_format=%m/%d/%Y\ntime_format=%l:%M %p" > ./windowsLike/datetime-16.rc
    if [ "$NAME" = "Ubuntu" ]; then
      echo -e "[Desktop Entry]\nName=App Store\nComment=Add, remove or update software on this computer\nIcon=softwarecenter\nExec=snap-store %U\nTerminal=false\nType=Application\nCategories=GNOME;GTK;System;PackageManager;\nKeywords=Updates;Upgrade;Sources;Repositories;Preferences;Install;Uninstall;Program;Software;App;Store;\nStartupNotify=true\nMimeType=x-scheme-handler/appstream;x-scheme-handler/apt;x-scheme-handler/snap;\nX-GNOME-UsesNotifications=true\nDBusActivatable=true\nX-Purism-FormFactor=Workstation;Mobile;\nX-Ubuntu-Gettext-Domain=gnome-software\nPath=\n" > ./windowsLike/launcher-18/16878133091.desktop
    fi
    if [ "$NAME" = "Linux Mint" ]; then
      echo -e "[Desktop Entry]\nName=App Store\nComment=Add, remove or update software on this computer\nIcon=softwarecenter\nExec=mintinstall %U\nTerminal=false\nType=Application\nCategories=GNOME;GTK;System;PackageManager;\nKeywords=Updates;Upgrade;Sources;Repositories;Preferences;Install;Uninstall;Program;Software;App;Store;\nStartupNotify=true\nMimeType=x-scheme-handler/appstream;x-scheme-handler/apt;x-scheme-handler/snap;\nX-GNOME-UsesNotifications=true\nDBusActivatable=true\nX-Purism-FormFactor=Workstation;Mobile;\nX-Ubuntu-Gettext-Domain=gnome-software\nPath=\n" > ./windowsLike/launcher-18/16878133091.desktop
    fi
    echo -e "[Desktop Entry]\nEncoding=UTF-8\nName=Thunderbird Mail\nComment=Send and receive mail with Thunderbird\nGenericName=Mail Client\nKeywords=Email;E-mail;Newsgroup;Feed;RSS\nExec=thunderbird %u\nTerminal=false\nX-MultipleArgs=false\nType=Application\nIcon=thunderbird\nCategories=Application;Network;Email;\nMimeType=x-scheme-handler/mailto;application/x-xpinstall;x-scheme-handler/webcal;x-scheme-handler/mid;message/rfc822;\nStartupNotify=true\nActions=Compose;Contacts\nX-XFCE-Source=file:///usr/share/applications/thunderbird.desktop\n\n[Desktop Action Compose]\nName=Compose New Message\nExec=thunderbird -compose\nOnlyShowIn=Messaging Menu;Unity;\n\n[Desktop Action Contacts]\nName=Contacts\nExec=thunderbird -addressbook\nOnlyShowIn=Messaging Menu;Unity;\n" > ./windowsLike/launcher-19/16895434911.desktop
    cd windowsLike/ && tar -zcvf ../windowsLike.tar.gz * && cd - 
  else
    echo "XFCE panel theme archive already exists. Skipping creation."
  fi
  #Okay, NOW we're installing the shortcuts!
  xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" -r
  xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_L" --create -t string -s "xfce4-popup-whiskermenu"
  xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>d" -r
  xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Super>d" --create -t string -s "wmctrl -k on"
  echo "waiting 10 (0/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (1/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (2/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (3/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (4/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (5/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (6/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (7/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (8/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (9/10) seconds before applying it"
  sleep 1
  echo "waiting 10 (10/10) seconds before applying it"
  sleep 1
  xfce4-panel-profiles load windowsLike.tar.gz
  
  
  
  if [ -f "$BG_PATH" ]; then
    echo "applying Windows 10 background to your desktop"
    xfconf-query --channel xfce4-desktop --list | grep last-image | while read path; do
      xfconf-query --channel xfce4-desktop --property $path --set /usr/share/backgrounds/Windows-10.jpg
    done
  else
    echo "Background image not found at $BG_PATH. Skipping background application."
  fi
  
  
  echo "copying shortcuts, which, on linux are known as .desktop files, to their proper places."
  sudo cp setupStuff/desktopFiles/applications/ControlPanel.desktop /usr/share/applications
  sudo cp setupStuff/desktopFiles/applications/Notepad.desktop /usr/share/applications
  
  #Now to the desktop:
  cp setupStuff/desktopFiles/Desktop/firefox_firefox.desktop ~/Desktop/
  cp setupStuff/desktopFiles/Desktop/HowToInstallApps.txt ~/Desktop/
  
  
  LINK_PATH="/home/$USER/Desktop/ALL_Applications"
  TARGET="/usr/share/applications"
  if [ ! -L "$LINK_PATH" ] && [ ! -e "$LINK_PATH" ]; then
    echo "Creating symbolic link $LINK_PATH -> $TARGET"
    ln -s "$TARGET" "$LINK_PATH"
  else
    echo "Symbolic link or file $LINK_PATH already exists. Skipping."
  fi
  
  
  SRC="setupStuff/desktopFiles/$NAME/AppStore.desktop"
  DST="/home/$USER/Desktop/AppStore.desktop"
  if [ ! -e "$DST" ]; then
    echo "Copying AppStore.desktop to Desktop"
    cp "$SRC" "$DST"
  else
    echo "AppStore.desktop already exists on Desktop. Skipping."
  fi
  
  
  SRC="setupStuff/desktopFiles/$NAME/AppStore.desktop"
  DST="/usr/share/applications/AppStore.desktop"
  if [ ! -e "$DST" ]; then
    echo "Copying AppStore.desktop to /usr/share/applications/"
    sudo cp "$SRC" "$DST"
  else
    echo "AppStore.desktop already exists in /usr/share/applications/. Skipping."
  fi
  
  
  echo "Now changing mousepad, or notepad settings, to be easier to use"
  dconf load /org/xfce/mousepad/ < setupStuff/mousepad.settings
  echo "All commands finished successfully, your computer should now look like Windows 10."
fi
#End of the xfce part of my program.




if [[ "$DE" == *gnome* ]]; then
  ICON_DIR="/usr/share/icons/Windows-10-Icons"
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
  
  
  if [ -f "$BG_PATH" ]; then
    echo "applying Windows 10 background to your desktop"
    gsettings set org.gnome.desktop.background picture-uri 'file:///usr/share/backgrounds/Windows-10.jpg'
    gsettings set org.gnome.desktop.background picture-options "zoom"
  else
    echo "Background image not found at $BG_PATH. Skipping background application."
  fi
  
  
  #Install dependencies:
  sudo add-apt-repository ppa:agornostal/ulauncher -y
  sudo apt update
  sudo apt install -y nemo gnome-tweaks gnome-software gnome-extensions-app ttf-mscorefonts-installer ulauncher gtk2-engines-murrine gnome-themes-extra sassc
  # Set Nemo as default file manager for folders
  xdg-mime default nemo.desktop inode/directory
  
  
  #Adding right click menu.
  mkdir -p ~/Templates
  if [ ! -f ~/Templates/"Empty File.txt" ]; then
    touch ~/Templates/"Empty File.txt"
  fi
  
  
  #Installing GNOME extensions:
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
  echo "🎉 Arc Menu setup complete!"
  echo "Installing Date Menu Formatter"
  EXT_ID=4655
  GNOME_VERSION=$(gnome-shell --version | awk '{print $3}')
  # Fetch metadata
  VERSIONS_JSON=$(curl -s "https://extensions.gnome.org/extension-info/?pk=$EXT_ID&shell_version=$GNOME_VERSION")
  # Fallback to latest available version if GNOME version unsupported
  if echo "$VERSIONS_JSON" | jq -e .download_url | grep null >/dev/null; then
    echo "⚠️ GNOME version $GNOME_VERSION not supported. Trying latest available version..."
    GNOME_VERSION=$(curl -s "https://extensions.gnome.org/extension-query/?search=$EXT_ID" | jq -r '.extensions[0].shell_version_map | keys_unsorted[-1]')
    VERSIONS_JSON=$(curl -s "https://extensions.gnome.org/extension-info/?pk=$EXT_ID&shell_version=$GNOME_VERSION")
  fi
  # Get download URL and UUID
  ZIP_URL=$(echo "$VERSIONS_JSON" | jq -r .download_url)
  UUID=$(echo "$VERSIONS_JSON" | jq -r .uuid)
  # Abort if missing data, but NO 'exit'
  if [ -z "$ZIP_URL" ] || [ "$ZIP_URL" = "null" ] || [ -z "$UUID" ]; then
    echo "❌ Failed to get extension metadata."
  else
    EXT_DIR="$HOME/.local/share/gnome-shell/extensions/$UUID"
    # Only install if not already installed
    if [ ! -d "$EXT_DIR" ]; then
      echo "📦 Installing extension: date-menu-formatter@marcinjakubowski.github.com"
      curl -s -L -o ext.zip "https://extensions.gnome.org$ZIP_URL"
      mkdir -p "$EXT_DIR"
      unzip -q ext.zip -d "$EXT_DIR"
      rm ext.zip
    else
      echo "✅ Extension already installed: date-menu-formatter@marcinjakubowski.github.com"
    fi
  fi
  
  
  #Enabling GNOME extensions. This... might crash, you may need to log out and log back in, then run the script again:
  echo "Enabling GNOME extensions. This... might crash. Log out, log back in, and run the script again."
  echo "🚀 Enabling Dash to Panel..."
  gnome-extensions enable "dash-to-panel@jderose9.github.com" || echo "⚠️ May need GNOME shell restart for effect."
  echo "🚀 Enabling Arc Menu..."
  gnome-extensions enable "arcmenu@arcmenu.com" || echo "⚠️ May need GNOME shell restart for effect."
  echo "🚀 Enabling Date Menu Formatter..."
  gnome-extensions enable "date-menu-formatter@marcinjakubowski.github.com"  || echo "⚠️ May need GNOME shell restart for effect."
  echo "🚀 Enabling User Theme"
  gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com
  echo "🚀 Disabling Ubuntu Dock..."
  gnome-extensions disable ubuntu-dock@ubuntu.com
  
  
  #Changing extension settings to be like Windows 10:
  dconf load /org/gnome/shell/extensions/dash-to-panel/ < setupStuff/dash-to-panel-windows-10.txt
  dconf load /org/gnome/shell/extensions/arcmenu/ < setupStuff/arc-menu-windows-10.txt
  #dconf read /org/gnome/shell/favorite-apps > setupStuff/favorite-apps-windows-10.txt
  dconf write /org/gnome/shell/favorite-apps "$(cat setupStuff/favorite-apps-windows-10.txt)"
  #Restoring date and time configuration to look like windows 10:
  SCHEMA=org.gnome.shell.extensions.date-menu-formatter
  SCHEMA_DIR=~/.local/share/gnome-shell/extensions/date-menu-formatter@marcinjakubowski.github.com/schemas
  while IFS=": " read -r key val; do
    eval GSETTINGS_SCHEMA_DIR=$SCHEMA_DIR gsettings set $SCHEMA $key "$val"
  done < setupStuff/date-menu-formatter-windows-10.txt
  #Change positions of new icons like Windows 10:
  gsettings set org.gnome.shell.extensions.ding start-corner 'top-left'
  #Enabling 4 workspaces only:
  gsettings set org.gnome.mutter dynamic-workspaces false
  gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
  
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
  # Optionally set it (comment out if not needed in the larger script)
  echo "Applying Windows 10 theme"
  gsettings set org.gnome.desktop.interface gtk-theme "$THEME_NAME"
  gsettings set org.gnome.shell.extensions.user-theme name 'Windows 10'
  
  
  #Change the desktop files to be like Windows 10:
  sudo rm /usr/share/applications/ulauncher.desktop
  sudo cp setupStuff/desktopFiles/applications/show_desktop.desktop /usr/share/applications/show_desktop.desktop
  sudo cp setupStuff/desktopFiles/applications/org.gnome.TextEditor.desktop /usr/share/applications/org.gnome.TextEditor.desktop
  sudo cp setupStuff/desktopFiles/applications/ulauncher.desktop /usr/share/applications/ulauncher.desktop
  
  
  # Set GNOME font settings
  gsettings set org.gnome.desktop.interface font-name 'Segoe UI 11'
  gsettings set org.gnome.desktop.interface document-font-name 'Segoe UI 11'
  gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Segoe UI Bold 11'
  gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 12'
  # Updated antialiasing and hinting options
  gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
  gsettings set org.gnome.desktop.interface font-hinting 'slight'
  
  
  #Installing the final Windows 10 theme:
  echo "Installing the final windows 10 theme:"
  git clone https://github.com/vinceliuice/Fluent-gtk-theme.git
  sudo ./Fluent-gtk-theme/install.sh 
  gsettings set org.gnome.shell.extensions.user-theme name "Fluent-Dark"
  
  
  #Finally when all is done, log out and log back in:
  gnome-session-quit --logout
  
fi

