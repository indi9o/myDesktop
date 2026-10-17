#!/bin/sh
set -eu
base="$HOME/.config/conky/Nusantara"
cache="$HOME/.cache/conky-nusantara"
mkdir -p "$cache"
exec 9>"$cache/launch.lock"
flock 9
pgrep -u "$(id -u)" -x conky | while read -r pid; do kill "$pid"; done
nohup python3 "$base/metrics.py" >"$cache/metrics.log" 2>&1 9>&- &
sleep 1
# Detect the primary display; keep the 1920px layout proportions.
if command -v xrandr >/dev/null 2>&1; then
  NUSANTARA_WIDTH=$(xrandr --current 2>/dev/null | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r" connected primary (\d+)x",s) or re.search(r" connected (\d+)x",s); print(m.group(1) if m else 1920)')
  export NUSANTARA_WIDTH
fi
exec 9>&-
exec conky -c "$base/Nusantara.conf"
