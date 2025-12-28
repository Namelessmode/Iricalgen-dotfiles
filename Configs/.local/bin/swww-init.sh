scrDir=$(dirname "$(realpath "$0")")
source "$scrDir/globalvariable.sh"

confDir="${cacheDir}/ivy-shell/"
flag="$confDir/done"

if ! pgrep -x "swww-daemon" >/dev/null; then
  swww-daemon &
fi

if [[ ! -f "$flag" ]]; then
  default="$HOME/Pictures/wallpapers/1_rain_world.png"
  $scrDir/wbselecgen.sh "$default"
  touch "$flag"
fi

