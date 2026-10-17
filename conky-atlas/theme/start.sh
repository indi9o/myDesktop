#!/bin/sh
set -eu
base="$HOME/.config/conky/Atlas"
cache="$HOME/.cache/conky-atlas"
mkdir -p "$cache"
case "${1:---static}" in
  --live) config="$base/AtlasLive.conf" ;;
  --static) config="$base/Atlas.conf" ;;
  *) printf '%s\n' 'Usage: start.sh [--live|--static]' >&2; exit 2 ;;
esac
exec 9>"$cache/launch.lock"
flock 9
pgrep -u "$(id -u)" -x conky | while read -r pid; do kill "$pid"; done
nohup python3 "$base/metrics.py" >"$cache/metrics.log" 2>&1 9>&- &
sleep 1
# Detect the primary display; keep the 1920px layout proportions.
if command -v xrandr >/dev/null 2>&1; then
  ATLAS_WIDTH=$(xrandr --current 2>/dev/null | python3 -c 'import re,sys; s=sys.stdin.read(); m=re.search(r" connected primary (\d+)x",s) or re.search(r" connected (\d+)x",s); print(m.group(1) if m else 1920)')
  export ATLAS_WIDTH
fi
exec 9>&-
exec conky -c "$config"
