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
echo "All commands finished successfully, your computer should now look like windows 10."
