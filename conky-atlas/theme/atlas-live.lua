-- Atlas Live: cached topographic artwork with Cairo motion, no video player.
require 'cairo'
require 'cairo_xlib'
local home=os.getenv('HOME')
dofile(home..'/.config/conky/Atlas/atlas.lua')
local background=nil
local started=nil
local function monotonic()
 local f=io.open('/proc/uptime')
 if not f then return os.time() end
 local value=tonumber(f:read('*n'));f:close()
 return value or os.time()
end
local function tint(cr,r,g,b,a) cairo_set_source_rgba(cr,r,g,b,a) end

function conky_atlas_live()
 if not conky_window then return end
 if not background then
  background=cairo_image_surface_create_from_png(home..'/.config/conky/Atlas/topography-wallpaper.png')
 end
 local now=monotonic();if not started then started=now end
 local elapsed=now-started
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local scale=conky_window.width/1920;cairo_scale(cr,scale,scale)
 -- Render the decoded artwork from memory. Only its transform changes per frame.
 cairo_save(cr)
 cairo_translate(cr,-38.4+math.sin(elapsed/23)*14,-21.6+math.cos(elapsed/31)*8)
 cairo_scale(cr,1.04,1.04)
 cairo_set_source_surface(cr,background,0,0);cairo_paint(cr)
 cairo_restore(cr)
 cairo_save(cr);cairo_rectangle(cr,0,0,1450,1080);cairo_clip(cr)
 -- A quiet vertical sweep repeats every 48 seconds without a bright flash.
 local phase=(elapsed%48)/48
 local x=-120+phase*1690
 for i=0,7 do
  tint(cr,.78,.55,.41,.0035*(8-i))
  cairo_rectangle(cr,x-10*i,0,10,1080);cairo_fill(cr)
 end
 tint(cr,.78,.55,.41,.22);cairo_set_line_width(cr,1)
 cairo_move_to(cr,x,0);cairo_line_to(cr,x,1080);cairo_stroke(cr)
 -- Three small survey markers follow the generative contour paths.
 for i,level in ipairs({5,13,23}) do
  local angle=elapsed/(47+i*11)+i*1.7
  local r=(18+level*18)*(1+.15*math.sin(3*angle+.4)+.075*math.cos(5*angle-.8)+.035*math.sin(9*angle+level*.035))
  local px=790+math.cos(angle)*r*1.38
  local py=290+math.sin(angle)*r*.84
  -- Match the cached map transform.
  px=px*1.04-38.4+math.sin(elapsed/23)*14
  py=py*1.04-21.6+math.cos(elapsed/31)*8
  tint(cr,.78,.55,.41,.75);cairo_arc(cr,px,py,2.5,0,2*math.pi);cairo_fill(cr)
  tint(cr,.78,.55,.41,.24);cairo_set_line_width(cr,1)
  cairo_arc(cr,px,py,7+math.sin(elapsed+i)*1.5,0,2*math.pi);cairo_stroke(cr)
 end
 cairo_restore(cr)
 cairo_destroy(cr);cairo_surface_destroy(cs)
 -- The existing UI remains fixed while only the map moves underneath it.
 conky_atlas(40)
end
