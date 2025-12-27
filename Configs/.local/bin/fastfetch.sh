#!/usr/bin/env bash
set -euo pipefail

scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"

iconDir="${confDir}/fastfetch/icons/"
fetch=$(find "$iconDir" -maxdepth 1 -type f | shuf -n 1)
exec fastfetch -l "$fetch"
exit 0
