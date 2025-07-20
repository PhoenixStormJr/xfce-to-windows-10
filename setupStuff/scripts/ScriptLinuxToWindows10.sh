#!/bin/bash


cd "$(dirname "$0")/../.."
echo "Hello, this is the Linux installer for the application Linux-to-windows-10. This application will transform your linux desktop to a windows 10 like look and feel. Currently there is no ULA. Would you like to install it? Enter y for yes or n for no."
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
THEME_NAME="UniversalWin10Icons"
SYSTEM_ICON_DIR="/usr/share/icons"
ARCHIVE_PATH="setupStuff/UniversalWin10Icons.tar.gz"
TARGET_DIR="$SYSTEM_ICON_DIR/$THEME_NAME"
if [ -d "$TARGET_DIR" ]; then
    echo "System-wide $THEME_NAME already installed at $TARGET_DIR. Skipping unpack."
else
    echo "Installing $THEME_NAME system-wide..."
    sudo tar -xvzf "$ARCHIVE_PATH" -C "$SYSTEM_ICON_DIR"
    echo "Installation complete."
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


#Making backgrounds directory if it does not exist:
if [ -d /usr/share/backgrounds ]; then
    echo "/usr/share/backgrounds already exists and is a directory."
elif [ -e /usr/share/backgrounds ]; then
    echo "Error: /usr/share/backgrounds exists but is not a directory. Removing it..."
    sudo rm -f /usr/share/backgrounds
    sudo mkdir /usr/share/backgrounds
    echo "Created /usr/share/backgrounds as a directory."
else
    echo "/usr/share/backgrounds does not exist. Creating it..."
    sudo mkdir /usr/share/backgrounds
    echo "Created /usr/share/backgrounds."
fi


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
  
  ICON_DIR="/usr/share/icons/UniversalWin10Icons"
  if [ -d "$ICON_DIR" ]; then
    echo "making sure the windows 10 icons can be read but not deleted"
    sudo chmod 755 -R /usr/share/icons/UniversalWin10Icons
    echo "Permissions updated successfully."
    echo "changing icons to UniversalWin10Icons"
    xfconf-query -c xsettings -p /Net/IconThemeName -s UniversalWin10Icons
    echo "changing cursor to UniversalWin10Icons"
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -n -t string -s "UniversalWin10Icons"
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




if [[ "$DE" == *gnome* || "$DE" == *ubuntu* ]]; then
  ICON_DIR="/usr/share/icons/UniversalWin10Icons"
  if [ -d "$ICON_DIR" ]; then
    echo "making sure the windows 10 icons can be read but not deleted"
    sudo chmod 555 -R /usr/share/icons/UniversalWin10Icons
    echo "Permissions updated successfully."
    echo "changing icons to UniversalWin10Icons"
    gsettings set org.gnome.desktop.interface icon-theme 'UniversalWin10Icons'
    echo "changing cursor to UniversalWin10Icons"
    gsettings set org.gnome.desktop.interface cursor-theme "UniversalWin10Icons"
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
  sudo apt install -y nemo gnome-tweaks gnome-software gnome-extensions-app ttf-mscorefonts-installer ulauncher gtk2-engines-murrine gnome-themes-extra sassc wmctrl xdotool
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

  
  #Enabling 4 workspaces only, and workspace switcher:
  gsettings set org.gnome.mutter dynamic-workspaces false
  gsettings set org.gnome.desktop.wm.preferences num-workspaces 4
  mkdir -p ~/.local/bin
  cat > ~/.local/bin/workspace-next-loop.sh << 'EOF'
#!/bin/bash
# Get current workspace (0-indexed)
current=$(wmctrl -d | awk '$2 == "*" {print $1}')
# Get total workspaces
total=$(wmctrl -d | wc -l)
# Calculate next workspace index with loop
next=$(( (current + 1) % total ))
# Switch to next workspace
xdotool set_desktop $next
EOF
  chmod +x ~/.local/bin/workspace-next-loop.sh
  mkdir -p ~/.local/share/applications
  cat > ~/.local/share/applications/workspace-next-loop.desktop << 'EOF'
[Desktop Entry]
Name=Next Workspace
Comment=Switch to the next workspace, looping back to the first
Exec=bash -c "/home/$USER/.local/bin/workspace-next-loop.sh"
Icon=xfce4-workspaces
Terminal=false
Type=Application
Categories=Utility;
EOF
  
  
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
#end of the GNOME section of my program.






check_and_set() {
  local group=$1
  local key=$2
  local desired=$3
  current=$(kreadconfig5 --file "$FILE" --group "$group" --key "$key")
  if [[ "$current" != "$desired" ]]; then
    kwriteconfig5 --file "$FILE" --group "$group" --key "$key" "$desired"
    CHANGED=1
  fi
}
delete_key_if_exists() {
  local group=$1
  local key=$2
  current=$(kreadconfig5 --file "$FILE" --group "$group" --key "$key" 2>/dev/null)
  if [[ -n "$current" ]]; then
    kwriteconfig5 --file "$FILE" --group "$group" --key "$key" --delete
    CHANGED=1
  fi
}


if [[ "$DE" == *kde* ]]; then
  #Making the windows stick to the borders of your monitor like Windows 10:
  SCRIPT_ID="sticky-window-snapping"
  SCRIPT_PATH="setupStuff/kde-windows-10-stuff/sticky-window-snapping-v2.0.1.kwinscript"
  # Check if the script is already installed
  if ! kpackagetool5 -t KWin/Script -l | grep -q "$SCRIPT_ID"; then
    echo "Installing $SCRIPT_ID..."
    kpackagetool5 -t KWin/Script -i "$SCRIPT_PATH"
  else
    echo "$SCRIPT_ID is already installed. Skipping..."
  fi
  #Changing basic settings to be like Windows 10:
  FILE="kwinrc"
  CHANGED=0
  # Now check each setting:
  check_and_set "Windows" "Placement" "Centered"
  check_and_set "TabBox" "LayoutName" "thumbnails"
  check_and_set "TabBox" "AlternativeLayoutName" "thumbnails"
  check_and_set "Plugins" "sticky-window-snappingEnabled" "true"
  delete_key_if_exists "ElectricBorders" "TopLeft"
  delete_key_if_exists "TouchEdges" "Left"
  delete_key_if_exists "Effect-overview" "TouchBorderActivate"
  # Only reconfigure if changes made
  if [[ $CHANGED -eq 1 ]]; then
    qdbus org.kde.KWin /KWin reconfigure
  fi
  
  
  #Installing the Global Windows 10 theme for KDE-Plasma:
  #Check if any installed global theme contains "Win10OS" in its name
  if ! find /usr/share/plasma/look-and-feel -maxdepth 1 -type d -name '*Win10OS*' | grep -q .; then
    echo "Installing Win10OS Global Theme..."
    rm -rf /tmp/Win10OS-kde
    git clone https://github.com/yeyushengfan258/Win10OS-kde.git /tmp/Win10OS-kde
    sudo bash /tmp/Win10OS-kde/install.sh --global
    sudo tar -xzf setupStuff/kde-windows-10-stuff/Win10OS-default.tar.gz -C /usr/share/plasma/look-and-feel/
    sudo chown -R root:root /usr/share/plasma/look-and-feel/com.github.yeyushengfan258.Win10OS-default/
  else
    echo "Win10OS Global Theme already installed. Checking metadata.desktop..."
    metadata_file="/usr/share/plasma/look-and-feel/com.github.yeyushengfan258.Win10OS-default/metadata.desktop"
    if [[ ! -s "$metadata_file" ]]; then
      echo "⚠️  metadata.desktop is missing or empty. Reinstalling theme..."
      sudo rm -rf /usr/share/plasma/look-and-feel/com.github.yeyushengfan258.Win10OS-default/
      sudo rm -rf /usr/share/plasma/look-and-feel/com.github.yeyushengfan258.Win10OS-dark/
      sudo rm -rf /usr/share/plasma/look-and-feel/com.github.yeyushengfan258.Win10OS-light/
      rm -rf /tmp/Win10OS-kde
      git clone https://github.com/yeyushengfan258/Win10OS-kde.git /tmp/Win10OS-kde
      sudo bash /tmp/Win10OS-kde/install.sh --global
      sudo tar -xzf setupStuff/kde-windows-10-stuff/Win10OS-default.tar.gz -C /usr/share/plasma/look-and-feel/
      sudo chown -R root:root /usr/share/plasma/look-and-feel/com.github.yeyushengfan258.Win10OS-default/
    else
      echo "✅ metadata.desktop exists and is not empty. Skipping install."
    fi
  fi
  

  # Installing Windows 10 Search Menu:
  MENUZ_DIR="$HOME/.local/share/plasma/plasmoids/menuZ"
  if [ -d "$MENUZ_DIR" ]; then
    echo "[✓] Windows 10 Search Menu (Menu Z) is already installed."
  else
    echo "[*] Installing Windows 10 Search Menu (Menu Z)..."
    mkdir -p ~/.local/share/plasma/plasmoids
    plasmapkg2 -i ./setupStuff/kde-windows-10-stuff/menuZ.plasmoid
  fi

  # Installing Windows 10 Start Menu (Menu X):
  MENUX_DIR="$HOME/.local/share/plasma/plasmoids/menuX"
  if [ -d "$MENUX_DIR" ]; then
    echo "[✓] Windows 10 Start Menu (Menu X) is already installed."
  else
    echo "[*] Installing Windows 10 Start Menu (Menu X)..."
    mkdir -p ~/.local/share/plasma/plasmoids
    plasmapkg2 -i ./setupStuff/kde-windows-10-stuff/menuX.plasmoid
  fi
  
  #Applying Windows 10 theme:
  FILE_KDEGLOBALS="kdeglobals"
  FILE_PLASMARCT="plasmarc"
  LOOKANDFEEL="com.github.yeyushengfan258.Win10OS-default"
  THEME_NAME="Win10OS-dark"
  CHANGED=0
  echo "Checking LookAndFeelPackage in $FILE_KDEGLOBALS..."
  current_laf=$(kreadconfig5 --file "$FILE_KDEGLOBALS" --group KDE --key LookAndFeelPackage)
  echo "Current LookAndFeelPackage: '$current_laf'"
  if [[ "$current_laf" != "$LOOKANDFEEL" ]]; then
    echo "Setting LookAndFeelPackage to '$LOOKANDFEEL'..."
    kwriteconfig5 --file "$FILE_KDEGLOBALS" --group KDE --key LookAndFeelPackage "$LOOKANDFEEL"
    CHANGED=1
  else
    echo "LookAndFeelPackage already set to '$LOOKANDFEEL'. Skipping."
  fi
  echo "Checking current applied lookandfeel via lookandfeeltool..."
  current_applied=$(kreadconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage)
  if [[ "$current_applied" != "$LOOKANDFEEL" ]]; then
    echo "Applying lookandfeel '$LOOKANDFEEL' with lookandfeeltool..."
    lookandfeeltool -a "com.github.yeyushengfan258.Win10OS-default"
    CHANGED=1
  else
    echo "Lookandfeel '$LOOKANDFEEL' already applied. Skipping."
  fi
  echo "Checking theme name in $FILE_PLASMARCT..."
  current_theme=$(kreadconfig5 --file "$FILE_PLASMARCT" --group Theme --key name)
  echo "Current theme name: '$current_theme'"
  if [[ "$current_theme" != "$THEME_NAME" ]]; then
    echo "Setting theme name to '$THEME_NAME'..."
    kwriteconfig5 --file "$FILE_PLASMARCT" --group Theme --key name "$THEME_NAME"
    CHANGED=1
  else
    echo "Theme name already set to '$THEME_NAME'. Skipping."
  fi
  # Update icon arrangement if needed
  original_file=~/.config/plasma-org.kde.plasma.desktop-appletsrc
  temp_file=~/.config/tmp
  changed_flag=0
  awk '
  BEGIN { inside=0; inserted=0; changed=0 }
  /^\[Containments\]\[1\]\[General\]/ { inside=1; print; next }
  /^\[.*\]/ {
    if (inside && !inserted) {
      print "arrangement=1"
      inserted=1
      changed=1
    }
    inside=0
  }
  {
    if (inside && $0 ~ /^arrangement=/) {
      if ($0 != "arrangement=1") changed=1
      print "arrangement=1"
      inserted=1
    } else print
  }
  END {
    if (inside && !inserted) {
      print "arrangement=1"
      changed=1
    }
    # write changed status to a file
    if (changed == 1) print "CHANGED" > "/tmp/arrangement_changed_flag"
  }
' "$original_file" > "$temp_file"
  if [[ -f /tmp/arrangement_changed_flag ]]; then
    echo "Icon arrangement updated to Top to Bottom."
    mv "$temp_file" "$original_file"
    rm /tmp/arrangement_changed_flag
    CHANGED=1
  else
    echo "Icon arrangement already correct. Skipping."
    rm "$temp_file"
  fi

  #Now updating panel layout to be like Windows 10:
  original_file="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
  new_file="./setupStuff/kde-windows-10-stuff/windows10-panel.conf"
  if ! cmp -s "$original_file" "$new_file"; then
    echo "[*] Panel layout differs. Updating..."
    #to backup mine:
    #cp ~/.config/plasma-org.kde.plasma.desktop-appletsrc ./setupStuff/kde-windows-10-stuff/windows10-panel.conf
    cp "$new_file" "$original_file"
    CHANGED=1
  else
    echo "[✓] Panel layout already matches. Skipping update."
  fi


  #Updating transparency of the menu to be more like Windows 10:
  CONFIG="$HOME/.config/plasmashellrc"
  if ! grep -q '^panelOpacity=1$' "$CONFIG"; then
    echo "[*] Changing panelOpacity to 1..."
    sed -i 's/^panelOpacity=.*/panelOpacity=1/' "$CONFIG"
    CHANGED=1
  else
    echo "[✓] panelOpacity is already set to 1."
  fi


  if [[ $CHANGED -eq 1 ]]; then
    echo "Changes detected. Restarting plasmashell to apply settings..."
    kquitapp5 plasmashell
    kstart5 plasmashell
  else
    echo "No changes needed. Skipping plasmashell restart."
  fi
  
  
  
  #Installing the GTK theme for KDE-Plasma:
  if [ ! -d "/usr/share/themes/Windows-10-Dark-3.2.1-dark" ]; then
    echo "Installing Windows-10-Dark theme..."
    sudo tar -xvzf setupStuff/kde-windows-10-stuff/Windows-10-Dark.tar.gz -C /usr/share/themes/
  else
    echo "Windows-10-Dark theme already installed. Skipping."
  fi
  # GTK 3 settings
  target="$HOME/.config/gtk-3.0/settings.ini"
  desired_content="[Settings]
gtk-theme-name = Windows-10-Dark-3.2.1-dark
gtk-icon-theme-name = breeze"
  # Create directory if missing
  mkdir -p "$(dirname "$target")"
  # Check if file exists and matches desired content
  if ! [[ -f "$target" && "$(cat "$target")" == "$desired_content" ]]; then
    tee "$target" > /dev/null <<EOF
$desired_content
EOF
    echo "GTK settings.ini updated."
  else
    echo "GTK settings.ini already up to date."
  fi
  # GTK 2 settings
  target="$HOME/.config/gtk-2.0/gtkrc"
  desired_content='gtk-theme-name="Windows-10-Dark-3.2.1-dark"'
  mkdir -p "$(dirname "$target")"
  if ! [[ -f "$target" && "$(cat "$target")" == "$desired_content" ]]; then
    tee "$target" > /dev/null <<EOF
$desired_content
EOF
    echo "GTK 2.0 gtkrc updated."
  else
    echo "GTK 2.0 gtkrc already up to date."
  fi
  theme="Windows-10-Dark-3.2.1-dark"
  current1=$(kreadconfig5 --file gtkrc --group Settings --key gtk-theme-name)
  current2=$(kreadconfig5 --file gtkrc-3.0 --group Settings --key gtk-theme-name)
  if [[ "$current1" != "$theme" || "$current2" != "$theme" ]]; then
    rm ~/.config/gtkrc
    kwriteconfig5 --file gtkrc --group Settings --key gtk-theme-name "$theme"
    kwriteconfig5 --file gtkrc-3.0 --group Settings --key gtk-theme-name "$theme"
    echo "kwriteconfig5 gtk-theme-name keys updated."
  else
    echo "kwriteconfig5 gtk-theme-name keys already set."
  fi


  #Logout because the script needs to restart everything:
  echo ""
  echo "DONE! Logging out to apply the changes!"
  qdbus org.kde.ksmserver /KSMServer logout 0 0 1
fi
#End of KDE-Plasma configuration
