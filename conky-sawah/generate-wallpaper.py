#!/usr/bin/env python3
"""Render a dusk rice-terrace wallpaper procedurally; no downloaded assets.

Development only: needs python3-cairo and python3-numpy.
"""
import math
import random
from pathlib import Path
import cairo
import numpy as np

ROOT = Path(__file__).resolve().parent / 'theme'
WIDTH, HEIGHT = 1920, 1080
HORIZON = 585
SUN = (1452, 540, 44)
SKY = [(0, '19162D'), (.36, '372948'), (.66, '7F485A'), (.86, 'CF8762'), (1, 'EFBA84')]

def rgb(hex_value):
    return np.array([int(hex_value[i:i + 2], 16) / 255 for i in (0, 2, 4)])

def smooth(edge0, edge1, x):
    t = np.clip((x - edge0) / (edge1 - edge0), 0, 1)
    return t * t * (3 - 2 * t)

def sky_color(y):
    """Sky gradient colour for an array of rows (used again for reflections)."""
    t = np.clip(y / (HORIZON + 30), 0, 1)
    stops = np.array([s for s, _ in SKY])
    colors = np.array([rgb(c) for _, c in SKY])
    return np.stack([np.interp(t, stops, colors[:, i]) for i in range(3)], -1)

def sky(img, yy, xx):
    img[:] = sky_color(yy)
    sx, sy, r = SUN
    d = np.hypot(xx - sx, (yy - sy) * 1.25)
    img += (rgb('F6CF98') - img) * (.55 * np.exp(-d / 210))[..., None]
    img += (rgb('E99A68') - img) * (.22 * np.exp(-d / 620))[..., None]
    img[:] = np.where((np.hypot(xx - sx, yy - sy) < r)[..., None], rgb('FBE4B6'), img)
    rnd = np.random.default_rng(11)
    for x, y, a in zip(rnd.uniform(0, WIDTH, 90), rnd.uniform(0, 300, 90), rnd.uniform(.2, .7, 90)):
        img[int(y), int(x)] += (1 - img[int(y), int(x)]) * a * (1 - y / 320)

def volcano(x, peaks, base, seed):
    """Concave stratovolcano silhouettes with a small crater notch."""
    rnd = np.random.default_rng(seed)
    y = np.full_like(x, base, dtype=float)
    for px, py, spread in peaks:
        # A rounded tip, then truncated below into a flat crater rim.
        d = np.sqrt(((x - px) / spread) ** 2 + .04 ** 2)
        h = (base - py) * 1.07 * np.exp(-d ** .85 * 1.9)
        h = np.minimum(h, (base - py) * (.97 + .012 * np.cos(d * 90)))
        y = np.minimum(y, base - h)
    for f, a in [(1 / 23, 1.6), (1 / 61, 3.2), (1 / 7, .6)]:
        y += a * np.sin(x * f + rnd.uniform(0, 6.3))
    return np.minimum(y, base)

def mountains(img, yy, xx):
    x = xx[0]
    far = volcano(x, [(1185, 292, 300), (1720, 392, 210), (430, 440, 250)], HORIZON + 6, 1)
    mask = smooth(-.8, .8, yy - far[None, :])
    # Lit from the sun side, hazy toward the horizon, with erosion gullies.
    side = np.tanh((xx - 1185) / 260) * .5 + .5
    color = rgb('6C4459') + (rgb('B47670') - rgb('6C4459')) * side[..., None] * .8
    haze = smooth(320, HORIZON, yy)[..., None]
    color = color + (rgb('C98068') - color) * haze * .55
    angle = np.arctan2(xx - 1185, yy - 270)
    gully = np.sin(angle * 70 + np.sin(angle * 9) * 3) * smooth(310, 470, yy)
    color *= (1 - .06 * gully * (1 - haze[..., 0]))[..., None]
    img += (color - img) * mask[..., None]
    near = volcano(x, [(1560, 508, 430), (230, 528, 400), (860, 552, 300)], HORIZON + 26, 2)
    mask = smooth(-.8, .8, yy - near[None, :])
    color = rgb('3E2A3E') + (rgb('5A3A4C') - rgb('3E2A3E')) * smooth(400, 1700, xx)[..., None]
    img += (color - img) * mask[..., None]
    return near

def terraces(img, yy, xx):
    """Terraces are bands of a screen-space contour field: depth plus hills."""
    v = np.maximum(yy - HORIZON, 0)
    g = 4 * v ** .72
    # Spurs and gullies grow toward the viewer and bend the contours into arcs.
    depth = v / (HEIGHT - HORIZON)
    for cx, rx, a in [(1420, 210, -150), (560, 230, -55), (1010, 120, 45), (1880, 110, -50)]:
        # Lorentzian spurs: sharp tips, long shoulders, stacked through every level.
        t = (xx - cx) / (rx * (.35 + 1.3 * depth))
        g += a * (.12 + depth) / (1 + t * t)
    g += (1 + 4 * depth) * np.sin(xx / 260 + depth * 2.1)
    spacing = 12
    level = g / spacing
    band = np.floor(level)
    frac = level - band
    gy, gx = np.gradient(g)
    slope = np.maximum(np.hypot(gx, gy), 1e-3) / spacing
    near = smooth(0, HEIGHT - HORIZON, v)
    # Cross bunds split each terrace into paddies that widen toward the viewer.
    rnd = np.random.default_rng(5)
    offsets = rnd.uniform(0, 400, 600)
    width = 60 + 360 * depth
    u = (xx + offsets[band.astype(int) % 600]) / width
    cell = np.floor(u)
    seed = np.sin(band * 12.9898 + cell * 78.233) * 43758.5453
    kind = seed - np.floor(seed)
    is_water = kind < .3
    ripe = smooth(.78, .9, kind)
    # Planted paddies: green deepening toward the viewer; some already ripening.
    green = rgb('5F7A50') + (rgb('182819') - rgb('5F7A50')) * (near ** .6)[..., None]
    gold = rgb('9C8A4E') + (rgb('3C3A22') - rgb('9C8A4E')) * (near ** .6)[..., None]
    green = green + (gold - green) * ripe[..., None]
    green = green + (rgb('8C5868') - green) * (.3 * (1 - near) ** 3)[..., None]
    rows = np.sin(frac * math.pi * 2 * 5) * .5 + .5
    green *= (1 - .14 * (kind - .5) - .08 * rows * near)[..., None]
    # Flooded paddies mirror the sky, glowing beneath the sun.
    mirror = sky_color(np.clip(HORIZON - .55 * v - 18 * frac, 0, HORIZON))
    glow = np.exp(-((xx - SUN[0]) / (230 + .9 * v)) ** 2) * (1 - near) ** 1.5
    water = mirror * (.8 - .35 * near)[..., None] + (rgb('F3C58E') - mirror) * (glow * .6)[..., None]
    color = np.where(is_water[..., None], water, green)
    edge = np.minimum(u - cell, cell + 1 - u) * width
    cross = 1 - smooth(.3, 1 + 1.2 * near, edge)
    color *= (1 - .3 * cross)[..., None]
    # Bunds: a lit rim on the far edge of each terrace, shadow on the near edge.
    px = frac / slope
    rim = 1 - smooth(.4, 1.6 + 1.4 * near, px)
    shadow = 1 - smooth(.2, 1.4 + 2 * near, (1 - frac) / slope)
    color = color + (rgb('EDB27F') - color) * (rim * (.5 - .3 * near))[..., None]
    color *= (1 - .35 * shadow)[..., None]
    mask = smooth(-.5, 1.5, yy - HORIZON - 4)
    img += (color - img) * mask[..., None]
    # A low tree line of canopies and palms hides the seam at the horizon.
    x = xx[0]
    rnd = np.random.default_rng(9)
    crown = np.zeros_like(x)
    for cx, r in zip(rnd.uniform(0, WIDTH, 260), rnd.uniform(4, 13, 260)):
        crown = np.maximum(crown, np.sqrt(np.maximum(r * r - (x - cx) ** 2, 0)))
    top = HORIZON + 9 - crown - 3 * np.sin(x / 140)
    trees = smooth(-.7, .7, yy - top[None, :]) * (1 - smooth(HORIZON + 8, HORIZON + 16, yy))
    tone = rgb('3A2A38') + (rgb('5B3E44') - rgb('3A2A38')) * np.exp(-((xx - SUN[0]) / 380) ** 2)[..., None]
    img += (tone - img) * trees[..., None]

def vector_details(cr, ridge):
    # Coconut palms on the near ridge, silhouetted against the glow.
    for x, height, lean in [(1650, 118, .2), (1704, 94, -.14), (1785, 130, .28), (1296, 78, -.22)]:
        ground = ridge[x] + 5
        top = (x + lean * height, ground - height)
        cr.set_source_rgb(.21, .14, .21)
        cr.set_line_cap(cairo.LINE_CAP_ROUND)
        cr.set_line_width(3.5)
        cr.move_to(x, ground)
        cr.curve_to(x + lean * height * .15, ground - height * .5, top[0] - lean * 12, top[1] + 22, *top)
        cr.stroke()
        for angle in [-2.95, -2.45, -1.95, -1.2, -.7, -.2]:
            # Tapered fronds that droop toward their tips.
            length = 34 + 8 * math.cos(angle * 2)
            ex = top[0] + math.cos(angle) * length
            ey = top[1] + math.sin(angle) * length * .4 + 18
            mx = top[0] + math.cos(angle) * length * .55
            my = top[1] + math.sin(angle) * length * .55 - 10
            cr.move_to(*top)
            cr.curve_to(mx, my - 3, ex, ey - 10, ex, ey)
            cr.curve_to(ex, ey - 6, mx, my + 5, top[0], top[1] + 3)
            cr.close_path()
            cr.fill()
    # Thin cloud streaks lit from below, and birds heading home.
    rnd = random.Random(7)
    cr.set_line_cap(cairo.LINE_CAP_ROUND)
    for _ in range(11):
        x, y = rnd.uniform(820, 1900), rnd.uniform(270, 470)
        length = rnd.uniform(140, 360)
        cr.set_line_width(rnd.uniform(1.5, 4))
        cr.set_source_rgba(.95, .7, .54, rnd.uniform(.06, .16))
        cr.move_to(x, y)
        cr.curve_to(x + length * .3, y - 4, x + length * .7, y + 3, x + length, y - 2)
        cr.stroke()
    cr.set_source_rgba(.16, .12, .19, .85)
    cr.set_line_width(1.6)
    for x, y, s in [(1010, 418, 8), (1040, 402, 6), (1066, 426, 7), (1094, 410, 5), (930, 372, 5)]:
        cr.move_to(x - s, y - s * .4)
        cr.curve_to(x - s * .5, y - s * .7, x - s * .2, y - s * .3, x, y)
        cr.curve_to(x + s * .2, y - s * .3, x + s * .5, y - s * .7, x + s, y - s * .4)
        cr.stroke()
    # Keep the widget side calm: darken the left third, then a soft vignette.
    g = cairo.LinearGradient(0, 0, 1000, 0)
    g.add_color_stop_rgba(0, .07, .06, .11, .62)
    g.add_color_stop_rgba(.6, .07, .06, .11, .28)
    g.add_color_stop_rgba(1, .07, .06, .11, 0)
    cr.set_source(g)
    cr.paint()
    calm = cairo.RadialGradient(270, 700, 60, 270, 700, 640)
    calm.add_color_stop_rgba(0, .05, .05, .08, .5)
    calm.add_color_stop_rgba(1, .05, .05, .08, 0)
    cr.set_source(calm)
    cr.paint()
    vignette = cairo.RadialGradient(WIDTH * .6, HEIGHT * .5, 520, WIDTH * .55, HEIGHT * .5, 1250)
    vignette.add_color_stop_rgba(0, 0, 0, 0, 0)
    vignette.add_color_stop_rgba(1, 0, 0, 0, .42)
    cr.set_source(vignette)
    cr.paint()

if __name__ == '__main__':
    ROOT.mkdir(parents=True, exist_ok=True)
    yy, xx = np.mgrid[0:HEIGHT, 0:WIDTH].astype(float)
    img = np.zeros((HEIGHT, WIDTH, 3))
    sky(img, yy, xx)
    ridge = mountains(img, yy, xx)
    terraces(img, yy, xx)
    # Fine grain avoids banding in the long dusk gradients.
    img += np.random.default_rng(3).normal(0, .006, img.shape)
    pixels = (np.clip(img, 0, 1) * 255 + .5).astype(np.uint8)
    bgra = np.dstack([pixels[..., 2], pixels[..., 1], pixels[..., 0], np.full((HEIGHT, WIDTH), 255, np.uint8)])
    surface = cairo.ImageSurface(cairo.FORMAT_RGB24, WIDTH, HEIGHT)
    stride = surface.get_stride()
    buffer = np.ndarray((HEIGHT, stride // 4, 4), np.uint8, surface.get_data())
    buffer[:, :WIDTH] = bgra
    surface.mark_dirty()
    vector_details(cairo.Context(surface), ridge.astype(int))
    surface.write_to_png(str(ROOT / 'sawah-wallpaper.png'))
    print('Wallpaper written to', ROOT / 'sawah-wallpaper.png')
