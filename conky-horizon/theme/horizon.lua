require 'cairo'
require 'cairo_xlib'
local home = os.getenv('HOME')
local palette = {ink='F1ECE3', muted='A2AAA9', dim='6D777B', accent='C6B99A', rule='677277'}
local history = {}

local function color(cr,hex,alpha)
 cairo_set_source_rgba(cr,tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,alpha or 1)
end
local function text(cr,x,y,value,size,hex,family,bold)
 cairo_select_font_face(cr,family or 'DejaVu Sans',CAIRO_FONT_SLANT_NORMAL,bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size);color(cr,hex or palette.ink);cairo_move_to(cr,x,y);cairo_show_text(cr,tostring(value))
end
local function tracking(cr,x,y,value,size,spacing,hex)
 cairo_select_font_face(cr,'DejaVu Sans Mono',CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size);color(cr,hex)
 for char in value:gmatch('.') do
  cairo_move_to(cr,x,y);cairo_show_text(cr,char);x=x+size*.6+spacing
 end
end
local function rule(cr,x1,y1,x2,y2,alpha)
 color(cr,palette.rule,alpha or .35);cairo_set_line_width(cr,1)
 cairo_move_to(cr,x1,y1);cairo_line_to(cr,x2,y2);cairo_stroke(cr)
end
local function data()
 local d={};local f=io.open(home..'/.cache/conky-horizon/metrics.txt')
 if f then
  for line in f:lines() do local k,v=line:match('^([^=]+)=(.*)$');if k then d[k]=v end end
  f:close()
 end
 return setmetatable(d,{__index=function() return '--' end})
end
local function metric(cr,x,label,value,unit,detail)
 tracking(cr,x,826,label,11,2.2,palette.muted)
 text(cr,x,879,value,37,palette.ink,'DejaVu Sans')
 local offset=#tostring(value)*23+10
 text(cr,x+offset,878,unit,14,palette.accent,'DejaVu Sans Mono')
 text(cr,x,912,detail,11,palette.dim,'DejaVu Sans Mono')
end

function conky_horizon()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local scale=conky_window.width/1920;cairo_scale(cr,scale,scale)
 local d=data()
 tracking(cr,112,76,'HORIZON',13,5,palette.ink)
 rule(cr,255,72,291,72,.6)
 tracking(cr,313,76,'LOCAL SYSTEM',10,2,palette.dim)
 tracking(cr,1460,76,'UP '..d.uptime,10,1.3,palette.muted)
 text(cr,100,310,os.date('%H:%M'),178,palette.ink,'DejaVu Sans')
 local weekdays={'SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY'}
 local months={'JANUARY','FEBRUARY','MARCH','APRIL','MAY','JUNE','JULY','AUGUST','SEPTEMBER','OCTOBER','NOVEMBER','DECEMBER'}
 local date=weekdays[tonumber(os.date('%w'))+1]..'  /  '..os.date('%d')..' '..months[tonumber(os.date('%m'))]..' '..os.date('%Y')
 tracking(cr,113,373,date,12,2,palette.muted)
 rule(cr,114,409,162,409,.8)
 text(cr,181,415,'MALANG',12,palette.accent,'DejaVu Sans Mono')
 text(cr,278,415,d.temperature..'°C',17,palette.ink)
 text(cr,351,415,d.weather,11,palette.dim,'DejaVu Sans Mono')
 -- A flat dark footer keeps live statistics readable over textured terrain.
 color(cr,'10171B',.94);cairo_rectangle(cr,0,750,1920,260);cairo_fill(cr)
 rule(cr,112,782,1808,782,.5)
 metric(cr,112,'PROCESSOR',d.cpu,'%', 'CPU LOAD')
 metric(cr,400,'MEMORY',d.ram_available,'GiB','AVAILABLE / '..d.ram..'% USED')
 metric(cr,688,'STORAGE',d.disk_free,'GiB','FREE / '..d.disk..'% USED')
 metric(cr,976,'ZRAM',d.zram,'GiB','OF '..d.zram_total..' GiB / '..d.zram_physical..' MiB RAM')
 metric(cr,1264,'SSD SWAP',d.ssd_swap,'GiB','OF '..d.ssd_swap_total..' GiB ALLOCATED')
 metric(cr,1552,'TEMPERATURE',d.cpu_temp,'°C','CPU PACKAGE')
 for i=1,5 do local x=112+288*i-35;rule(cr,x,812,x,917,.2) end
 history[#history+1]=math.max(0,math.min(100,tonumber(d.cpu) or 0))
 if #history>60 then table.remove(history,1) end
 if #history>1 then
  color(cr,palette.accent,.65);cairo_set_line_width(cr,1)
  for i,v in ipairs(history) do
   local x=112+(i-1)*3.2;local y=950-v*.2
   if i==1 then cairo_move_to(cr,x,y) else cairo_line_to(cr,x,y) end
  end
  cairo_stroke(cr)
 end
 tracking(cr,1540,953,'EARTH / UTC+07',9,1.5,palette.dim)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
