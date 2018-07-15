#!/usr/bin/env bash
#
# Custom ICNS for macOS
#
# disrupted
#
# credit to https://www.sethvargo.com/replace-icons-osx
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# USER SETTINGS #################################
# make sure your custom icons are in .icns format
# rename them each to the corresponding App name 
# and place in this subfolder:
dir='icons'
ext='.icns'
#################################################
red='\033[0;31m'
reset='\033[0m'
icns_changed=0

set -x
if [ "$EUID" -ne 0 ]; then
    echo "Simulating output, to change the icons please run as root"
fi

for file in $dir/*$ext; do
    [ -e "$file" ] || continue
    app=$(basename "$file" $ext)
    echo -e "\n${red}$app${reset}"
    icon=$(defaults read /Applications/"$app".app/Contents/Info CFBundleIconFile)
    icon=${icon%$ext}
    echo "$file -> /Applications/$app.app/Contents/Resources/$icon$ext"
    if [ "$EUID" -eq 0 ]; then
        sudo cp "$file" "/Applications/$app.app/Contents/Resources/$icon$ext"
        if [ $? -eq 0 ]; then
            echo OK
            touch /Applications/"$app".app
            icns_changed=$((icns_changed+1))
        else
            echo FAILED
        fi
    fi
done
set +x

if [ $icns_changed -gt 0 ]; then
    echo $icns_changed "app icons changed. rebuilding icon cache..."
    sudo rm -rfv /Library/Caches/com.apple.iconservices.store
    sudo find /private/var/folders/ \( -name com.apple.dock.iconcache -or -name com.apple.iconservices \) -exec rm -rfv {} \; ;
    sleep 3
    sudo killall Dock && sudo killall Finder
else
    echo "no icons changed."
fi
echo DONE
