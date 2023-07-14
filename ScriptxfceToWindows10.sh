#!/bin/bash
#this command copies the windows 10 theme, from kali, to your theme folder.
sudo cp -r setupStuff/Kali-Windows-10-theme /usr/share/themes
#this command makes sure everyone can use the theme, but no one can delete it.
sudo chmod 555 -R /usr/share/themes/Kali-Windows-10-theme