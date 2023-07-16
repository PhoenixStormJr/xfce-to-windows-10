#!/bin/bash
#this command copies the windows 10 theme, from kali, to your theme folder.
echo "Copying windows 10 theme to /usr/share/themes/"
sudo cp -r setupStuff/Kali-Windows-10-theme /usr/share/themes
#this command makes sure everyone can use the theme, but no one can delete it.
echo "making sure the windows 10 theme can be read but not deleted"
sudo chmod 555 -R /usr/share/themes/Kali-Windows-10-theme
#this command applies the new theme we copied to the system.
echo "applying the theme to your computer"
xfconf-query -c xsettings -p /Net/ThemeName -s "Kali-Windows-10-theme"
echo "downloading windows 10 icon theme from b00merang"
sudo apt update
sudo apt install git -y
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
echo "One icon apparently has never been ripped from Windows. The mail icon. I made it myself."
sudo cp setupStuff/MissingIcon/22x22/Windows10Mail.png /usr/share/icons/Windows-10-Icons/22x22/apps/thunderbird.png
sudo cp setupStuff/MissingIcon/24x24/Windows10Mail.png /usr/share/icons/Windows-10-Icons/24x24/apps/thunderbird.png
sudo cp setupStuff/MissingIcon/32x32/Windows10Mail.png /usr/share/icons/Windows-10-Icons/32x32/apps/thunderbird.png
sudo cp setupStuff/MissingIcon/48x48/Windows10Mail.png /usr/share/icons/Windows-10-Icons/48x48/apps/thunderbird.png
sudo cp setupStuff/MissingIcon/128x128/Windows10Mail.png /usr/share/icons/Windows-10-Icons/128x128/apps/thunderbird.png
sudo cp setupStuff/MissingIcon/256x256/Windows10Mail.png /usr/share/icons/Windows-10-Icons/256x256/apps/thunderbird.png
sudo rm /usr/share/icons/Windows-10-Icons/22x22/apps/thunderbird.svg
sudo rm /usr/share/icons/Windows-10-Icons/24x24/apps/thunderbird.svg
sudo rm /usr/share/icons/Windows-10-Icons/32x32/apps/thunderbird.svg
sudo rm /usr/share/icons/Windows-10-Icons/48x48/apps/thunderbird.svg
sudo rm /usr/share/icons/Windows-10-Icons/128x128/apps/thunderbird.svg
sudo rm /usr/share/icons/Windows-10-Icons/256x256/apps/thunderbird.svg
sudo rm /usr/share/icons/Windows-10-Icons/scalable/apps/thunderbird.svg
sudo cp setupStuff/MissingIcon/scalable/Windows10Mail.svg /usr/share/icons/Windows-10-Icons/scalable/apps/thunderbird.svg
echo "making sure the windows 10 icons can be read but not deleted"
echo "making sure the windows 10 icons can be read but not deleted"
sudo chmod 555 -R /usr/share/icons/Windows-10-Icons
echo "changing icons to Windows-10-Icons"
xfconf-query -c xsettings -p /Net/IconThemeName -s Windows-10-Icons
echo "downloading dependancies"
sudo apt install python3 fonts-liberation gir1.2-glib-2.0 libnotify-bin mousepad procps psmisc xdotool xfce4-datetime-plugin xfce4-power-manager-plugins xfce4-pulseaudio-plugin xfce4-whiskermenu-plugin xfce4-panel-profiles snapd -y
sudo snap install snap-store
echo "creating the xfce4 panel theme"
mkdir windowsLike
mkdir windowsLike/launcher-2
mkdir windowsLike/launcher-3
mkdir windowsLike/launcher-6
mkdir windowsLike/launcher-7
mkdir windowsLike/launcher-8
mkdir windowsLike/launcher-18
mkdir windowsLike/launcher-19
echo -e "/configver 2\n/panels [<1>]\n/panels/dark-mode false\n/panels/panel-1/icon-size uint32 24\n/panels/panel-1/length 100.0\n/panels/panel-1/length-adjust true\n/panels/panel-1/plugin-ids [<1>, <2>, <3>, <4>, <5>, <6>, <18>, <7>, <19>, <8>, <9>, <10>, <11>, <12>, <13>, <14>, <16>, <15>, <17>]\n/panels/panel-1/position 'p=8;x=0;y=0'\n/panels/panel-1/position-locked true\n/panels/panel-1/size uint32 44\n/plugins/plugin-1 'whiskermenu'\n/plugins/plugin-10 'separator'\n/plugins/plugin-10/expand true\n/plugins/plugin-10/style uint32 0\n/plugins/plugin-11 'power-manager-plugin'\n/plugins/plugin-12 'systray'\n/plugins/plugin-12/known-items [<'nm-applet'>]\n/plugins/plugin-12/show-frame false\n/plugins/plugin-12/size-max uint32 24\n/plugins/plugin-12/square-icons true\n/plugins/plugin-13 'pulseaudio'\n/plugins/plugin-13/enable-keyboard-shortcuts true\n/plugins/plugin-14 'notification-plugin'\n/plugins/plugin-15 'separator'\n/plugins/plugin-15/style uint32 0\n/plugins/plugin-16 'datetime'\n/plugins/plugin-17 'separator'\n/plugins/plugin-17/style uint32 0\n/plugins/plugin-18 'launcher'\n/plugins/plugin-18/items [<'16878133091.desktop'>]\n/plugins/plugin-19 'launcher'\n/plugins/plugin-19/items [<'16895434911.desktop'>]\n/plugins/plugin-2 'launcher'\n/plugins/plugin-2/items [<'15780470832.desktop'>]\n/plugins/plugin-3 'launcher'\n/plugins/plugin-3/items [<'15780471503.desktop'>]\n/plugins/plugin-4 'showdesktop'\n/plugins/plugin-5 'directorymenu'\n/plugins/plugin-5/base-directory '/home/xubuntu'\n/plugins/plugin-5/icon-name 'system-file-manager'\n/plugins/plugin-6 'launcher'\n/plugins/plugin-6/items [<'15735608061.desktop'>]\n/plugins/plugin-7 'launcher'\n/plugins/plugin-7/items [<'15780459961.desktop'>]\n/plugins/plugin-8 'launcher'\n/plugins/plugin-8/items [<'15780460092.desktop'>]\n/plugins/plugin-9 'tasklist'\n/plugins/plugin-9/show-handle false\n/plugins/plugin-9/show-labels false" > ./windowsLike/config.txt
echo -e "favorites=xfce4-terminal-emulator.desktop,xfce4-file-manager.desktop,xfce-text-editor.desktop,xfce4-web-browser.desktop,xfce-ui-settings.desktop,xfce-display-settings.desktop,xfce-settings-manager.desktop,org.xfce.Parole.desktop,org.xfce.ristretto.desktop,xfce-backdrop-settings.desktop\nrecent=\nbutton-icon=xfce4-panel-menu\nbutton-single-row=false\nshow-button-title=false\nshow-button-icon=true\nlauncher-show-name=true\nlauncher-show-description=false\nlauncher-show-tooltip=true\nlauncher-icon-size=4\nhover-switch-category=true\ncategory-show-name=true\ncategory-icon-size=2\nsort-categories=false\nview-mode=0\ndefault-category=0\nrecent-items-max=10\nfavorites-in-recent=true\nposition-search-alternate=true\nposition-commands-alternate=true\nposition-categories-alternate=true\nposition-categories-horizontal=false\nstay-on-focus-out=false\nprofile-shape=0\nconfirm-session-command=true\nmenu-width=678\nmenu-height=710\nmenu-opacity=95\ncommand-settings=xfce4-settings-manager\nshow-command-settings=false\ncommand-lockscreen=xflock4\nshow-command-lockscreen=false\ncommand-switchuser=dm-tool switch-to-greeter\nshow-command-switchuser=false\ncommand-logoutuser=xfce4-session-logout --logout --fast\nshow-command-logoutuser=false\ncommand-restart=xfce4-session-logout --reboot --fast\nshow-command-restart=false\ncommand-shutdown=xfce4-session-logout --halt --fast\nshow-command-shutdown=false\ncommand-suspend=xfce4-session-logout --suspend\nshow-command-suspend=false\ncommand-hibernate=xfce4-session-logout --hibernate\nshow-command-hibernate=false\ncommand-logout=xfce4-session-logout\nshow-command-logout=true\ncommand-menueditor=menulibre\nshow-command-menueditor=false\ncommand-profile=mugshot\nshow-command-profile=false\nsearch-actions=0\n\n" > ./windowsLike/whiskermenu-1.rc
echo -e "[Desktop Entry]\nVersion=1.0\nExec=xfce4-appfinder\nIcon=edit-find-symbolic\nStartupNotify=true\nTerminal=false\nType=Application\nCategories=Utility;X-XFCE;\nName=Application Finder\n" > ./windowsLike/launcher-2/15780470832.desktop
echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nName=Next Workspace\nExec=xdotool set_desktop --relative 1\nIcon=xfce4-workspaces\nTerminal=false\nStartupNotify=false\n" > ./windowsLike/launcher-3/15780471503.desktop
echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nExec=exo-open --launch TerminalEmulator\nIcon=utilities-terminal\nStartupNotify=true\nTerminal=false\nCategories=Utility;X-XFCE;X-Xfce-Toplevel;\nOnlyShowIn=XFCE;\nX-AppStream-Ignore=True\nName=Terminal\n" > ./windowsLike/launcher-6/15735608061.desktop
echo -e "[Desktop Entry]\nVersion=1.0\nType=Application\nExec=exo-open --launch WebBrowser %u\nIcon=web-browser\nStartupNotify=true\nTerminal=false\nCategories=Network;X-XFCE;X-Xfce-Toplevel;\nOnlyShowIn=XFCE;\nX-XFCE-MimeType=x-scheme-handler/http;x-scheme-handler/https;\nX-AppStream-Ignore=True\nName=Web Browser\n" > ./windowsLike/launcher-7/15780459961.desktop
echo -e "[Desktop Entry]\nName=Text Editor\nExec=mousepad %F\nIcon=accessories-text-editor\nTerminal=false\nStartupNotify=true\nType=Application\nCategories=Utility;TextEditor;GTK;\nMimeType=text/plain;\n" > ./windowsLike/launcher-8/15780460092.desktop
echo -e "[Desktop Entry]\nName=App Store\nComment=Add, remove or update software on this computer\nIcon=softwarecenter\nExec=snap-store %U\nTerminal=false\nType=Application\nCategories=GNOME;GTK;System;PackageManager;\nKeywords=Updates;Upgrade;Sources;Repositories;Preferences;Install;Uninstall;Program;Software;App;Store;\nStartupNotify=true\nMimeType=x-scheme-handler/appstream;x-scheme-handler/apt;x-scheme-handler/snap;\nX-GNOME-UsesNotifications=true\nDBusActivatable=true\nX-Purism-FormFactor=Workstation;Mobile;\nX-Ubuntu-Gettext-Domain=gnome-software\nPath=\n" > ./windowsLike/launcher-18/16878133091.desktop
echo -e "[Desktop Entry]\nEncoding=UTF-8\nName=Thunderbird Mail\nComment=Send and receive mail with Thunderbird\nGenericName=Mail Client\nKeywords=Email;E-mail;Newsgroup;Feed;RSS\nExec=thunderbird %u\nTerminal=false\nX-MultipleArgs=false\nType=Application\nIcon=thunderbird\nCategories=Application;Network;Email;\nMimeType=x-scheme-handler/mailto;application/x-xpinstall;x-scheme-handler/webcal;x-scheme-handler/mid;message/rfc822;\nStartupNotify=true\nActions=Compose;Contacts\nX-XFCE-Source=file:///usr/share/applications/thunderbird.desktop\n\n[Desktop Action Compose]\nName=Compose New Message\nExec=thunderbird -compose\nOnlyShowIn=Messaging Menu;Unity;\n\n[Desktop Action Contacts]\nName=Contacts\nExec=thunderbird -addressbook\nOnlyShowIn=Messaging Menu;Unity;\n" > ./windowsLike/launcher-19/16895434911.desktop
cd windowsLike/ && tar -zcvf ../windowsLike.tar.gz * && cd - 
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
echo "All commands finished successfully, your computer should now look like windows 10."
