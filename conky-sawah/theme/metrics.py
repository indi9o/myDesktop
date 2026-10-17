#!/usr/bin/env python3
"""Small local metrics collector. No external packages; weather refreshes every 15 min."""
import datetime
import json
import math
import os
from pathlib import Path
import shutil
import threading
import time
import urllib.request

BASE = Path.home() / '.cache/conky-sawah'
BASE.mkdir(parents=True, exist_ok=True)
# Malang; used for both the weather request and the local sun times.
LAT, LON = -7.98, 112.63
weather = {'temperature': '--', 'weather': 'CUACA TIDAK TERSEDIA', 'weather_time': 0}
try:
    weather.update(json.loads((BASE / 'weather.json').read_text()))
except (OSError, ValueError):
    pass

def refresh_weather():
    while True:
        retry = 60
        try:
            url = (f'https://api.open-meteo.com/v1/forecast?latitude={LAT}&longitude={LON}'
                   '&current=temperature_2m,weather_code&timezone=Asia%2FJakarta')
            with urllib.request.urlopen(url, timeout=8) as response:
                current = json.load(response)['current']
            code = int(current['weather_code'])
            label = ('CERAH' if code == 0 else 'CERAH BERAWAN' if code < 3
                     else 'MENDUNG' if code == 3 else 'BERKABUT' if code < 50
                     else 'GERIMIS' if code < 60 else 'HUJAN' if code < 70
                     else 'SALJU' if code < 80 else 'HUJAN LOKAL' if code < 95 else 'HUJAN PETIR')
            weather.update(temperature=str(round(current['temperature_2m'])),
                           weather=label, weather_time=time.time())
            tmp = BASE / 'weather.tmp'
            tmp.write_text(json.dumps(weather))
            tmp.replace(BASE / 'weather.json')
            retry = 900
        except (OSError, ValueError, KeyError):
            pass
        time.sleep(retry)

def sun_times(now):
    """Local sunrise and sunset (HH:MM) from the sunrise equation; no network needed."""
    rad = math.radians
    day = math.ceil(now / 86400 + 2440587.5 - 2451545.0 + .0008) - LON / 360
    mean = (357.5291 + .98560028 * day) % 360
    centre = 1.9148 * math.sin(rad(mean)) + .02 * math.sin(rad(2 * mean)) + .0003 * math.sin(rad(3 * mean))
    ecliptic = rad((mean + centre + 282.9372) % 360)
    transit = 2451545.0 + day + .0053 * math.sin(rad(mean)) - .0069 * math.sin(2 * ecliptic)
    declination = math.asin(math.sin(ecliptic) * math.sin(rad(23.4397)))
    cos_hour = ((math.sin(rad(-.833)) - math.sin(rad(LAT)) * math.sin(declination))
                / (math.cos(rad(LAT)) * math.cos(declination)))
    hour = math.degrees(math.acos(max(-1, min(1, cos_hour)))) / 360
    clock = lambda julian: datetime.datetime.fromtimestamp((julian - 2440587.5) * 86400).strftime('%H:%M')
    return clock(transit - hour), clock(transit + hour)

def cpu_times():
    values = list(map(int, Path('/proc/stat').read_text().splitlines()[0].split()[1:9]))
    return sum(values), values[3] + values[4]

def collect():
    mem = {key: int(value.split()[0]) for key, value in
           (line.split(':', 1) for line in Path('/proc/meminfo').read_text().splitlines())}
    total, free, available = mem['MemTotal'], mem['MemFree'], mem['MemAvailable']
    disk = shutil.disk_usage('/')
    uptime = int(float(Path('/proc/uptime').read_text().split()[0]))
    days, seconds = divmod(uptime, 86400)
    hours, seconds = divmod(seconds, 3600)
    minutes = seconds // 60
    result = {
        'ram': str(round(100 * (total - available) / total)),
        'ram_available': f'{available / 1048576:.1f}',
        'disk': str(round(100 * disk.used / (disk.used + disk.free))),
        'disk_free': str(round(disk.free / 1024**3)),
        'uptime': f'{days}d {hours:02d}h {minutes:02d}m' if days else f'{hours:02d}h {minutes:02d}m',
    }
    for line in Path('/proc/swaps').read_text().splitlines()[1:]:
        name, kind, size, used, priority = line.split()
        key = 'zram' if name.startswith('/dev/zram') else 'ssd_swap'
        result[key] = f'{int(used) / 1048576:.1f}'
        result[key + '_total'] = f'{int(size) / 1048576:.0f}'
    result.setdefault('zram', '0.0')
    result.setdefault('ssd_swap', '0.0')
    result.setdefault('zram_total', '0')
    result.setdefault('ssd_swap_total', '0')
    result['zram_physical'] = '--'
    try:
        result['zram_physical'] = f'{int(Path("/sys/block/zram0/mm_stat").read_text().split()[2]) / 1024**2:.0f}'
    except (OSError, ValueError, IndexError):
        pass
    result['cpu_temp'] = '--'
    for zone in sorted(Path('/sys/class/thermal').glob('thermal_zone*')):
        try:
            if zone.joinpath('type').read_text().strip() in ('x86_pkg_temp', 'cpu-thermal', 'k10temp'):
                result['cpu_temp'] = str(round(int(zone.joinpath('temp').read_text()) / 1000))
                break
        except (OSError, ValueError):
            pass
    result['sunrise'], result['sunset'] = sun_times(time.time())
    result.update(weather)
    if time.time() - float(result['weather_time']) > 7200:
        result['temperature'], result['weather'] = '--', 'CUACA TIDAK TERSEDIA'
    return result

if __name__ == '__main__':
    import fcntl
    lock = (BASE / 'metrics.lock').open('w')
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        raise SystemExit(0)
    threading.Thread(target=refresh_weather, daemon=True).start()
    previous = cpu_times()
    while True:
        try:
            result = collect()
            current = cpu_times()
            delta = current[0] - previous[0]
            result['cpu'] = str(round(100 * (1 - (current[1] - previous[1]) / delta))) if delta else '0'
            previous = current
            tmp = BASE / 'metrics.tmp'
            tmp.write_text('\n'.join(f'{k}={v}' for k, v in result.items()) + '\n')
            tmp.replace(BASE / 'metrics.txt')
        except (OSError, ValueError):
            pass
        time.sleep(3)
