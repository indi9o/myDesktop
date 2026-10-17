"""Illustrative sun/moon clock driven by Malang sunrise and sunset epochs."""
from datetime import datetime, timedelta
import math
from zoneinfo import ZoneInfo

ZONE = ZoneInfo('Asia/Jakarta')


def cycle(now, days=None):
    """Return a continuous day/night clock; the moon is an illustrative night marker."""
    events = []
    if isinstance(days, list):
        for row in days:
            try:
                rise, setting = float(row['sunrise']), float(row['sunset'])
                if math.isfinite(rise) and math.isfinite(setting) and 0 < setting-rise < 86400:
                    events.extend([(rise, 'day'), (setting, 'night')])
            except (TypeError, ValueError, KeyError, OverflowError):
                continue
    events = sorted(set(events))
    before = [event for event in events if event[0] <= now]
    after = [event for event in events if event[0] > now]
    estimated = True
    if before and after:
        start, phase = before[-1]
        end, next_phase = after[0]
        estimated = phase == next_phase or not (0 < end-start <= 86400)
    if estimated:
        # Explicit clock approximation when cached astronomical events do not cover now.
        local = datetime.fromtimestamp(now, ZONE)
        today = local.replace(hour=0, minute=0, second=0, microsecond=0)
        rise, setting = today+timedelta(hours=6), today+timedelta(hours=18)
        if local < rise:
            start, end, phase = (setting-timedelta(days=1)).timestamp(), rise.timestamp(), 'night'
        elif local < setting:
            start, end, phase = rise.timestamp(), setting.timestamp(), 'day'
        else:
            start, end, phase = setting.timestamp(), (rise+timedelta(days=1)).timestamp(), 'night'
    progress = max(0, min(1, (now-start)/(end-start)))
    # Sun traverses the upper semicircle during the day and the lower one at night.
    # The opposite moon symbol visualizes the night cycle, not the physical Moon's position.
    sun = math.pi*(1+progress) if phase == 'day' else math.pi*progress
    rise = start if phase == 'day' else end
    setting = end if phase == 'day' else start
    return {
        'solar_phase': phase,
        'solar_progress': f'{progress:.6f}',
        'sun_angle': f'{sun:.8f}',
        'moon_angle': f'{(sun+math.pi)%(2*math.pi):.8f}',
        'sunrise_label': datetime.fromtimestamp(rise, ZONE).strftime('%H.%M'),
        'sunset_label': datetime.fromtimestamp(setting, ZONE).strftime('%H.%M'),
        'solar_source': 'estimated' if estimated else 'open-meteo',
    }
