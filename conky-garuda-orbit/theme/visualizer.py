#!/usr/bin/env python3
"""Output-only audio spectrum and movable placement editor for Garuda Orbit."""
import argparse
import fcntl
import json
import math
import os
from pathlib import Path
import re
import signal
import subprocess
import time

BASE = Path(__file__).resolve().parent
SETTINGS = Path.home() / '.config/garuda-orbit/visualizer-position.json'
CACHE = Path.home() / '.cache/conky-garuda-orbit'
RUNTIME = Path(os.environ.get('XDG_RUNTIME_DIR', '/dev/shm')) / ('garuda-orbit-' + str(os.getuid()))
FPS, RATE, SIZE, BARS = 20, 24000, 2048, 64
DEFAULT = {'x': 650, 'y': 870, 'width': 1130, 'height': 100}


def atomic(path, value):
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_suffix('.tmp')
    tmp.write_text(value)
    tmp.replace(path)


def position():
    result = dict(DEFAULT)
    try:
        saved = json.loads(SETTINGS.read_text())
        for key in ('x', 'y'):
            value = float(saved[key])
            if math.isfinite(value):
                result[key] = max(0, min(value, (1920 if key == 'x' else 1080) - result['width' if key == 'x' else 'height']))
    except (OSError, ValueError, KeyError, TypeError, OverflowError):
        pass
    return result


def screen():
    try:
        output = subprocess.check_output(['xrandr', '--current'], text=True, timeout=2)
        match = re.search(r' connected primary (\d+)x(\d+)([+-]\d+)([+-]\d+)', output)
        match = match or re.search(r' connected (\d+)x(\d+)([+-]\d+)([+-]\d+)', output)
        if match:
            return tuple(map(int, match.groups()))
    except (OSError, subprocess.SubprocessError):
        pass
    return (1920, 1080, 0, 0)


def geometry():
    width, height, ox, oy = screen()
    p = position()
    # Preserve the reference proportions, but fit short or narrow displays.
    scale = min(width / 1920, height / 1080)
    w, h = round(p['width'] * scale), round(p['height'] * scale)
    x = ox + max(0, min(round(p['x'] * scale), width - w))
    y = oy + max(0, min(round(p['y'] * scale), height - h))
    return x, y, w, h, scale


def configure():
    import tkinter as tk
    x, y, w, h, scale = geometry()
    sw, sh, ox, oy = screen()
    root = tk.Tk()
    root.title('Garuda Orbit — Atur visualizer')
    root.overrideredirect(True)
    root.attributes('-topmost', True)
    root.configure(bg='#102019', highlightbackground='#D8B477', highlightthickness=2)
    root.geometry(f'{w}x{h+42}+{x}+{min(y,oy+sh-h-46)}')
    canvas = tk.Canvas(root, width=w, height=h, bg='#102019', highlightthickness=0, cursor='fleur')
    canvas.pack(fill='both', expand=True)
    for i in range(BARS):
        bar = (0.18 + 0.65 * abs(math.sin(i * .19))) * (h - 30)
        bx = (i + .5) * w / BARS
        canvas.create_line(bx, h-8, bx, h-8-bar, fill='#D8B477' if i < 42 else '#E1785F', width=max(2, w/BARS*.43), capstyle='round')
    canvas.create_text(w/2, 12, text='GESER BINGKAI INI UNTUK MENGATUR POSISI', fill='#F5E8C9', font=('DejaVu Sans', 9))
    drag = {}

    def begin(event):
        drag.update(x=event.x_root, y=event.y_root, wx=root.winfo_x(), wy=root.winfo_y())

    def move(event):
        nx = max(ox, min(ox+sw-w-4, drag['wx']+event.x_root-drag['x']))
        ny = max(oy, min(oy+sh-h-46, drag['wy']+event.y_root-drag['y']))
        root.geometry(f'+{nx}+{ny}')

    def save():
        value = {'x': round((root.winfo_x()-ox)/scale), 'y': round((root.winfo_y()-oy)/scale)}
        atomic(SETTINGS, json.dumps(value, indent=2)+'\n')
        root.destroy()

    def reset():
        atomic(SETTINGS, json.dumps({'x': DEFAULT['x'], 'y': DEFAULT['y']}, indent=2)+'\n')
        root.destroy()

    canvas.bind('<Button-1>', begin)
    canvas.bind('<B1-Motion>', move)
    toolbar = tk.Frame(root, bg='#102019')
    toolbar.pack(fill='x', pady=4)
    for label, action in [('Simpan posisi', save), ('Batal', root.destroy), ('Posisi awal', reset)]:
        tk.Button(toolbar, text=label, command=action, bg='#24382D', fg='#F5E8C9', activebackground='#D8B477', relief='flat').pack(side='left', padx=6)
    root.bind('<Escape>', lambda event: root.destroy())
    root.mainloop()


class Spectrum:
    def __init__(self):
        os.environ['OPENBLAS_NUM_THREADS'] = '1'
        import numpy as np
        self.np = np
        self.samples = np.zeros(SIZE, dtype=np.float32)
        self.window = np.hanning(SIZE)
        self.edges = np.geomspace(45, 11000, BARS + 1)
        self.indices = np.clip(np.round(self.edges * SIZE / RATE).astype(int), 1, SIZE // 2)
        self.levels = np.zeros(BARS)
        self.last_sound = -math.inf

    def update(self, raw, now):
        np = self.np
        if raw:
            values = np.frombuffer(raw, dtype='<i2').astype(np.float32) / 32768
            n = min(len(values), SIZE)
            self.samples = np.roll(self.samples, -n)
            self.samples[-n:] = values[-n:]
        else:
            self.samples *= .4
        rms = float(np.sqrt(np.mean(self.samples ** 2)))
        target = np.zeros(BARS)
        if rms > .0005:
            self.last_sound = now
            fft = np.abs(np.fft.rfft(self.samples * self.window)) * 2 / self.window.sum()
            for i in range(BARS):
                lo, hi = int(self.indices[i]), int(self.indices[i+1])
                peak = float(np.max(fft[lo:max(lo+1, hi)]))
                target[i] = np.clip((20 * math.log10(max(peak, 1e-8)) + 65) / 55, 0, 1)
        self.levels += (target - self.levels) * np.where(target > self.levels, .72, .22)
        return now - self.last_sound < 3, self.levels


def default_monitor():
    # Explicit output monitor; never use the default source (often a microphone).
    try:
        sink = subprocess.check_output(['pactl', 'get-default-sink'], text=True, timeout=1).strip()
        if sink:
            return sink + '.monitor'
    except (OSError, subprocess.SubprocessError):
        pass
    return None


def stop(proc):
    if proc is not None:
        if proc.poll() is None:
            proc.terminate()
            try:
                proc.wait(timeout=2)
            except subprocess.TimeoutExpired:
                proc.kill()
        proc.wait()
        if proc.stdout:
            proc.stdout.close()


def run(parent=None, headless=False):
    CACHE.mkdir(parents=True, exist_ok=True)
    RUNTIME.mkdir(parents=True, mode=0o700, exist_ok=True)
    lock = (CACHE/'visualizer.lock').open('w')
    deadline = time.monotonic() + 4
    while True:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            break
        except BlockingIOError:
            if time.monotonic() > deadline:
                return
            time.sleep(.1)
    state = RUNTIME/'spectrum.txt'
    spectrum = Spectrum()
    capture = overlay = None
    source = None
    next_check = 0
    last_geometry = None
    pending = b''
    running = True

    def finish(signum, frame):
        nonlocal running
        running = False

    signal.signal(signal.SIGTERM, finish)
    signal.signal(signal.SIGINT, finish)
    try:
        while running:
            tick = time.monotonic()
            if parent and not Path('/proc', str(parent)).exists():
                break
            if tick >= next_check:
                wanted = default_monitor()
                if wanted != source or (wanted and (capture is None or capture.poll() is not None)):
                    stop(capture)
                    capture = None
                    source = wanted
                    spectrum = Spectrum()
                    pending = b''
                    if source:
                        capture = subprocess.Popen([
                            'parec', '--raw', '--device='+source, '--format=s16le',
                            '--rate='+str(RATE), '--channels=1', '--latency-msec=50',
                            '--process-time-msec=25', '--client-name=Garuda Orbit Visualizer',
                            '--stream-name=Output spectrum'], stdout=subprocess.PIPE, stderr=subprocess.DEVNULL)
                        os.set_blocking(capture.stdout.fileno(), False)
                if not headless:
                    g = geometry()
                    if g != last_geometry or overlay is None or overlay.poll() is not None:
                        stop(overlay)
                        x, y, w, h, _ = g
                        env = {**os.environ, 'GARUDA_AUDIO_STATE': str(state),
                               'GARUDA_VIZ_X': str(x), 'GARUDA_VIZ_Y': str(y),
                               'GARUDA_VIZ_W': str(w), 'GARUDA_VIZ_H': str(h)}
                        overlay = subprocess.Popen(['conky', '-c', str(BASE/'Visualizer.conf')], env=env,
                                                   stdout=subprocess.DEVNULL)
                        last_geometry = g
                next_check = tick + 1
            if capture and capture.poll() is None:
                while True:
                    try:
                        chunk = os.read(capture.stdout.fileno(), 65536)
                        if not chunk:
                            break
                        pending += chunk
                    except BlockingIOError:
                        break
            count = len(pending) // 2 * 2
            raw, pending = pending[:count], pending[count:]
            visible, levels = spectrum.update(raw[-SIZE*2:], tick)
            atomic(state, f'{time.time():.3f} {int(visible)}\n'+' '.join(f'{v:.3f}' for v in levels)+'\n')
            time.sleep(max(0, 1/FPS - (time.monotonic() - tick)))
    finally:
        stop(capture)
        stop(overlay)
        atomic(state, '0 0\n')
        lock.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--configure', action='store_true', help='Drag and save the visualizer position')
    parser.add_argument('--parent', type=int, help='Exit when the main Conky process exits')
    parser.add_argument('--headless', action='store_true', help='Collect audio without launching Conky')
    args = parser.parse_args()
    if args.configure:
        configure()
    else:
        run(args.parent, args.headless)
