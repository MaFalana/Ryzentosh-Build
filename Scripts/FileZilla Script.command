#!/bin/zsh

#
## Installing FileZilla

curl -L -o ~/Downloads/FileZilla.zip "https://dl3.cdn.filezilla-project.org/client/FileZilla_3.68.1_macos-x86.app.tar.bz2?h=mcibK7NYS06yfOgDovzl8g&x=1744206135"



tar -xvf ~/Downloads/FileZilla.zip -C ~/Downloads/

mv ~/Downloads/FileZilla.app /Applications/

rm -rf ~/Downloads/FileZilla.zip #Clean up the downloaded file

# Add the app to the Dock (if needed)
osascript -e 'tell application "System Events" to make new dock item at end of dock items with properties {path:"/Applications/FileZilla.app"}'

echo "FileZilla has been installed and added to your Dock."

# Move apps to folder named "Remote"
FOLDER3="/Applications/Remote"
sudo mkdir -p "$FOLDER3"
sudo mv /Applications/Microsoft\ Remote\ Desktop.app "$FOLDER3/Microsoft Remote Desktop.app"
sudo mv /Applications/FileZilla.app "$FOLDER3/FileZilla.app"
sudo mv /Applications/Utilities/Screen\ Sharing.app "$FOLDER3/Screen Sharing.app"
sudo mv /Applications/NCPlayer.app "$FOLDER3/NRPlayer.app"



defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock # Refresh Launchpad


## Customize Dock





