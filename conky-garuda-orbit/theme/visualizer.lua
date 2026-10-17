require 'cairo'
require 'cairo_xlib'
function conky_garuda_spectrum()
 if not conky_window then return end
 local path=os.getenv('GARUDA_AUDIO_STATE')
 if not path then return end
 local f=io.open(path);if not f then return end
 local stamp,active=(f:read('*l') or ''):match('^(%S+) (%d)$')
 local values=f:read('*l') or '';f:close()
 if active~='1' or os.time()-(tonumber(stamp) or 0)>2 then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local w=tonumber(os.getenv('GARUDA_VIZ_W')) or 1130
 local h=tonumber(os.getenv('GARUDA_VIZ_H')) or 100
 local step=w/64;local bar=math.max(2,step*.42)
 cairo_set_line_width(cr,bar);cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
 local i=0
 for value in values:gmatch('%S+') do
  if i>=64 then break end
  local v=math.max(0,math.min(1,tonumber(value) or 0))
  if v>.015 then
   local t=i/63
   cairo_set_source_rgba(cr,(216+(225-216)*t)/255,(180+(120-180)*t)/255,(119+(95-119)*t)/255,.94)
   local x=step*(i+.5)
   cairo_move_to(cr,x,h-bar);cairo_line_to(cr,x,h-bar-v*(h-2*bar));cairo_stroke(cr)
  end
  i=i+1
 end
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
