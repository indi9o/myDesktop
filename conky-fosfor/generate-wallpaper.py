#!/usr/bin/env python3
"""Render a phosphor CRT oscilloscope wallpaper; vector only, no downloaded assets."""
import math
from pathlib import Path
import cairo

ROOT = Path(__file__).resolve().parent / 'theme'
WIDTH, HEIGHT = 1920, 1080
GREEN = (.49, .94, .63)
# Graticule: 10 x 8 divisions on the right; the left stays dark for the widget.
DIV, COLS, ROWS = 64, 10, 8
GX, GY = 1000, 236

def glow_stroke(cr, widths):
    for width, alpha in widths:
        cr.set_source_rgba(*GREEN, alpha)
        cr.set_line_width(width)
        cr.stroke_preserve()
    cr.new_path()

def paint(cr):
    # Tube face: slightly lit centre falling off to near black.
    face = cairo.RadialGradient(1320, 500, 60, 1100, 540, 1250)
    face.add_color_stop_rgb(0, .045, .102, .066)
    face.add_color_stop_rgb(.55, .020, .049, .032)
    face.add_color_stop_rgb(1, .008, .020, .013)
    cr.set_source(face)
    cr.paint()
    # Sparse dot grid over the whole screen.
    cr.set_source_rgba(*GREEN, .07)
    for x in range(32, WIDTH, 32):
        for y in range(32, HEIGHT, 32):
            cr.rectangle(x, y, 1.2, 1.2)
    cr.fill()
    w, h = DIV * COLS, DIV * ROWS
    cr.set_source_rgba(*GREEN, .11)
    cr.set_line_width(1)
    for i in range(COLS + 1):
        cr.move_to(GX + i * DIV + .5, GY); cr.line_to(GX + i * DIV + .5, GY + h)
    for j in range(ROWS + 1):
        cr.move_to(GX, GY + j * DIV + .5); cr.line_to(GX + w, GY + j * DIV + .5)
    cr.stroke()
    # Centre axes with minor ticks, as on a real scope face.
    cx, cy = GX + w / 2, GY + h / 2
    cr.set_source_rgba(*GREEN, .22)
    for i in range(COLS * 5 + 1):
        x = GX + i * DIV / 5
        cr.move_to(x, cy - 4); cr.line_to(x, cy + 4)
    for j in range(ROWS * 5 + 1):
        y = GY + j * DIV / 5
        cr.move_to(cx - 4, y); cr.line_to(cx + 4, y)
    cr.stroke()
    # Corner brackets around the graticule.
    cr.set_source_rgba(*GREEN, .38)
    cr.set_line_width(2)
    for x, y, dx, dy in [(GX, GY, 1, 1), (GX + w, GY, -1, 1), (GX, GY + h, 1, -1), (GX + w, GY + h, -1, -1)]:
        cr.move_to(x - 14 * dx, y + 30 * dy); cr.line_to(x - 14 * dx, y - 14 * dy); cr.line_to(x + 30 * dx, y - 14 * dy)
    cr.stroke()
    # Lissajous trace 3:2 with phosphor bloom.
    for i in range(1201):
        t = i * 2 * math.pi / 1200
        x = cx + math.cos(3 * t) * w * .36
        y = cy + math.sin(2 * t) * h * .36
        cr.line_to(x, y) if i else cr.move_to(x, y)
    glow_stroke(cr, [(18, .025), (9, .05), (4, .12), (1.6, .62)])
    cr.select_font_face('DejaVu Sans Mono', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_NORMAL)
    cr.set_font_size(13)
    cr.set_source_rgba(*GREEN, .34)
    for x, y, label in [(GX, GY - 28, 'CH1 2.00V   CH2 2.00V   X-Y'),
                        (GX + w - 186, GY - 28, 'FOSFOR // TTY1'),
                        (GX, GY + h + 38, 'P31  ~  RASIO 3:2'),
                        (GX + w - 132, GY + h + 38, 'TRIG  AUTO')]:
        cr.move_to(x, y); cr.show_text(label)
    # Scanlines, then a vignette darkening the tube edges.
    cr.set_source_rgba(0, 0, 0, .22)
    for y in range(0, HEIGHT, 3):
        cr.rectangle(0, y, WIDTH, 1)
    cr.fill()
    vignette = cairo.RadialGradient(WIDTH / 2, HEIGHT / 2, 420, WIDTH / 2, HEIGHT / 2, 1180)
    vignette.add_color_stop_rgba(0, 0, 0, 0, 0)
    vignette.add_color_stop_rgba(1, 0, 0, 0, .62)
    cr.set_source(vignette)
    cr.paint()

if __name__ == '__main__':
    ROOT.mkdir(exist_ok=True)
    surface = cairo.ImageSurface(cairo.FORMAT_RGB24, WIDTH, HEIGHT)
    paint(cairo.Context(surface))
    surface.write_to_png(str(ROOT / 'fosfor-wallpaper.png'))
    print('Wallpaper written to', ROOT / 'fosfor-wallpaper.png')
