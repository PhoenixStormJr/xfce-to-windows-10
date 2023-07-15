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
echo "making sure the windows 10 icons can be read but not deleted"
sudo chmod 555 -R /usr/share/icons/Windows-10-Icons
echo "changing theme to Windows-10-Icons"
xfconf-query -c xsettings -p /Net/IconThemeName -s Windows-10-Icons
echo "All commands finished successfully, your computer should now look like windows 10."
