#!/usr/bin/env python3
"""Render illustrative vector contour studies; no geography or downloaded assets."""
import math
from pathlib import Path
import cairo

ROOT = Path(__file__).resolve().parent / 'theme'
WIDTH, HEIGHT = 1920, 1080

def paint(cr):
    cr.set_source_rgb(0.075, 0.091, 0.094)
    cr.paint()
    # Sparse survey grid, intentionally quieter than the contour lines.
    cr.set_source_rgba(0.48, 0.54, 0.50, 0.13)
    cr.set_line_width(0.8)
    for x in range(60, WIDTH, 160):
        for y in range(60, HEIGHT, 160):
            cr.move_to(x-3,y);cr.line_to(x+3,y)
            cr.move_to(x,y-3);cr.line_to(x,y+3)
    cr.stroke()
    # Each study consists of nested, harmonically warped closed curves.
    for cx,cy,count,stretch,phase in [(790,290,39,1.38,0.4),(180,1050,23,1.2,1.7)]:
        for level in range(count):
            radius=18+level*18
            for i in range(301):
                angle=i*2*math.pi/300
                warp=(1+0.15*math.sin(3*angle+phase)
                      +0.075*math.cos(5*angle-0.8)
                      +0.035*math.sin(9*angle+level*.035))
                r=radius*warp
                x=cx+math.cos(angle)*r*stretch
                y=cy+math.sin(angle)*r*.84
                if i==0:cr.move_to(x,y)
                else:cr.line_to(x,y)
            cr.close_path()
            major=level%5==0
            if major:cr.set_source_rgba(.68,.45,.31,.43)
            else:cr.set_source_rgba(.47,.56,.48,.24)
            cr.set_line_width(1.05 if major else .65)
            cr.stroke()

if __name__ == '__main__':
    ROOT.mkdir(exist_ok=True)
    for kind in ['svg','png']:
        surface=(cairo.SVGSurface(str(ROOT/'topography-wallpaper.svg'),WIDTH,HEIGHT)
                 if kind=='svg' else cairo.ImageSurface(cairo.FORMAT_RGB24,WIDTH,HEIGHT))
        paint(cairo.Context(surface))
        if kind=='png':surface.write_to_png(str(ROOT/'topography-wallpaper.png'))
        surface.finish()
    print('Topography SVG and PNG written to',ROOT)
