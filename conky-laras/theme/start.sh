#!/bin/sh
set -eu
base="$HOME/.config/conky/Laras"
cache="$HOME/.cache/conky-laras"
mkdir -p "$cache"
exec 9>"$cache/launch.lock"
flock 9
pgrep -u "$(id -u)" -x conky | while read -r pid; do kill "$pid"; done
nohup env LARAS_PARENT_PID="$$" python3 "$base/metrics.py" >"$cache/metrics.log" 2>&1 9>&- &
sleep 1
# Keep the compact widget proportional to the primary display's width and height.
LARAS_WIDTH=1920
LARAS_HEIGHT=1080
if command -v xrandr >/dev/null 2>&1; then
  resolution=$(xrandr --current 2>/dev/null | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r" connected primary (\d+)x(\d+)",s) or re.search(r" connected (\d+)x(\d+)",s); print(m.group(1)+" "+m.group(2) if m else "1920 1080")')
  LARAS_WIDTH=${resolution% *}
  LARAS_HEIGHT=${resolution#* }
fi
export LARAS_WIDTH LARAS_HEIGHT
exec 9>&-
exec conky -c "$base/Laras.conf"
