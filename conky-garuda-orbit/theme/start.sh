#!/bin/sh
set -eu
base="$HOME/.config/conky/GarudaOrbit"
cache="$HOME/.cache/conky-garuda-orbit"
mkdir -p "$cache"
exec 9>"$cache/launch.lock"
flock 9
pgrep -u "$(id -u)" -x conky | while read -r pid; do kill "$pid"; done
nohup python3 "$base/metrics.py" >"$cache/metrics.log" 2>&1 9>&- &
sleep 1
# Detect the primary display; keep the 1920px layout proportions.
if command -v xrandr >/dev/null 2>&1; then
  GARUDA_ORBIT_WIDTH=$(xrandr --current 2>/dev/null | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r" connected primary (\d+)x",s) or re.search(r" connected (\d+)x",s); print(m.group(1) if m else 1920)')
  export GARUDA_ORBIT_WIDTH
fi
nohup python3 "$base/visualizer.py" --parent "$$" >"$cache/visualizer.log" 2>&1 9>&- &
exec 9>&-
exec conky -c "$base/GarudaOrbit.conf"
