#!/usr/bin/env bash
scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"

wallpapers_dir="$HOME/Pictures/wallpapers"
random_wallpaper=$(find "$wallpapers_dir" -maxdepth 1 -type f | shuf -n 1)
$localDir/bin/wbselecgen.sh "$random_wallpaper"
