"""Illustrative 24-hour curve for Malang, not astronomical altitude or Moon position."""
from datetime import datetime
import math
from zoneinfo import ZoneInfo

ZONE = ZoneInfo('Asia/Jakarta')


def height(hour, rise, setting):
    """Above the horizon during daylight; a shallow night curve below it."""
    if rise <= hour <= setting:
        return math.sin(math.pi * (hour-rise)/(setting-rise))
    night_hour = hour if hour >= setting else hour+24
    return -.4 * math.sin(math.pi * (night_hour-setting)/(24-setting+rise))


def cycle(now, days=None):
    local = datetime.fromtimestamp(now, ZONE)
    midnight = local.replace(hour=0, minute=0, second=0, microsecond=0).timestamp()
    rise, setting, estimated = 6., 18., True
    if isinstance(days, list):
        for row in days:
            try:
                r, s = float(row['sunrise']), float(row['sunset'])
                if not (math.isfinite(r) and math.isfinite(s)):
                    continue
                # Use BOTH events for today's local calendar date, even at night.
                if midnight < r < s < midnight+86400:
                    rise, setting = (r-midnight)/3600, (s-midnight)/3600
                    estimated = False
                    break
            except (TypeError, ValueError, KeyError, OverflowError):
                continue
    hour = (now-midnight)/3600
    day = rise <= hour < setting
    def label(value):
        return datetime.fromtimestamp(midnight+value*3600, ZONE).strftime('%H.%M')
    return {
        'solar_phase': 'day' if day else 'night',
        'clock_progress': f'{hour/24:.8f}',
        'curve_now': f'{height(hour, rise, setting):.8f}',
        'curve_points': ','.join(f'{height(i/4, rise, setting):.8f}' for i in range(97)),
        'sunrise_label': label(rise),
        'sunset_label': label(setting),
        'solar_source': 'estimated' if estimated else 'open-meteo',
    }
