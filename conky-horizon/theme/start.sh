#!/bin/sh
set -eu
base="$HOME/.config/conky/Horizon"
cache="$HOME/.cache/conky-horizon"
mkdir -p "$cache"
exec 9>"$cache/start.lock"
flock -n 9 || exit 0
pgrep -u "$(id -u)" -x conky | while read -r pid; do kill "$pid"; done
nohup python3 "$base/metrics.py" >"$cache/metrics.log" 2>&1 9>&- &
sleep 1
# Detect the primary display; keep the 1920px layout proportions.
if command -v xrandr >/dev/null 2>&1; then
  HORIZON_WIDTH=$(xrandr --current 2>/dev/null | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r" connected primary (\d+)x",s) or re.search(r" connected (\d+)x",s); print(m.group(1) if m else 1920)')
  export HORIZON_WIDTH
fi
exec conky -c "$base/Horizon.conf"
