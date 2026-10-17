require 'cairo'
require 'cairo_xlib'
local home=os.getenv('HOME')
local p={white='E8E5DC',sage='9FAB99',copper='C88D69',dim='78817C',dark='141A1B'}
local samples={}
local last_sample=0
local cached_data=nil
local last_data_read=0
local function col(cr,h,a)
 cairo_set_source_rgba(cr,tonumber(h:sub(1,2),16)/255,tonumber(h:sub(3,4),16)/255,tonumber(h:sub(5,6),16)/255,a or 1)
end
local function text(cr,x,y,value,size,h,family)
 cairo_select_font_face(cr,family or 'DejaVu Sans Mono',CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size);col(cr,h);cairo_move_to(cr,x,y);cairo_show_text(cr,tostring(value))
end
local function tracked(cr,x,y,value,size,gap,h)
 for c in value:gmatch('.') do text(cr,x,y,c,size,h);x=x+size*.6+gap end
end
local function line(cr,x,y,x2,y2,opacity)
 col(cr,p.sage,opacity or .22);cairo_set_line_width(cr,1)
 cairo_move_to(cr,x,y);cairo_line_to(cr,x2,y2);cairo_stroke(cr)
end
local function data()
 if cached_data and os.time()-last_data_read<3 then return cached_data end
 local d={};local f=io.open(home..'/.cache/conky-atlas/metrics.txt')
 if f then for l in f:lines() do local k,v=l:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close() end
 cached_data=setmetatable(d,{__index=function()return '--'end})
 last_data_read=os.time()
 return cached_data
end
local function meter(cr,y,label,value,detail,fraction)
 tracked(cr,1515,y,label,10,2,p.sage)
 text(cr,1513,y+41,value,29,p.white,'DejaVu Sans')
 text(cr,1515,y+66,detail,10,p.dim)
 line(cr,1515,y+82,1785,y+82,.15)
 local percent=math.max(0,math.min(1,fraction or 0))
 col(cr,p.copper,.85);cairo_set_line_width(cr,2)
 cairo_move_to(cr,1515,y+82);cairo_line_to(cr,1515+270*percent,y+82);cairo_stroke(cr)
end
function conky_atlas(offset_y)
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local scale=conky_window.width/1920;cairo_scale(cr,scale,scale)
 if tonumber(offset_y) then cairo_translate(cr,0,tonumber(offset_y)) end
 local d=data()
 -- The sidebar is a flat surface so the map can never reduce legibility.
 col(cr,p.dark,.98);cairo_rectangle(cr,1450,40,385,930);cairo_fill(cr)
 line(cr,1450,40,1450,970,.28)
 tracked(cr,104,85,'ATLAS',20,7,p.white)
 tracked(cr,106,115,'A LOCAL SYSTEM STUDY',9,1.8,p.dim)
 text(cr,104,558,'03',18,p.copper)
 line(cr,154,551,212,551,.6)
 tracked(cr,229,555,'MALANG / INDONESIA',10,2,p.sage)
 text(cr,91,756,os.date('%H:%M'),151,p.white,'DejaVu Serif')
 local days={'SUNDAY','MONDAY','TUESDAY','WEDNESDAY','THURSDAY','FRIDAY','SATURDAY'}
 local months={'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'}
 tracked(cr,107,805,days[tonumber(os.date('%w'))+1]..' / '..os.date('%d')..' '..months[tonumber(os.date('%m'))]..' '..os.date('%Y'),11,2.5,p.sage)
 text(cr,106,859,d.temperature..'°C',24,p.copper,'DejaVu Sans')
 tracked(cr,204,854,d.weather,10,1.8,p.dim)
 tracked(cr,107,941,'UPTIME',9,2,p.dim);text(cr,196,941,d.uptime,11,p.sage)
 tracked(cr,1515,90,'SYSTEM / LIVE',10,2,p.copper)
 meter(cr,145,'CPU LOAD',d.cpu..' %','PACKAGE '..d.cpu_temp..'°C',(tonumber(d.cpu) or 0)/100)
 meter(cr,275,'RAM AVAILABLE',d.ram_available..' GiB',d.ram..'% USED',(tonumber(d.ram) or 0)/100)
 meter(cr,405,'STORAGE FREE',d.disk_free..' GiB',d.disk..'% USED',(tonumber(d.disk) or 0)/100)
 meter(cr,535,'ZRAM',d.zram..' / '..d.zram_total..' GiB',d.zram_physical..' MiB PHYSICAL RAM',(tonumber(d.zram) or 0)/math.max(1,tonumber(d.zram_total) or 1))
 meter(cr,665,'SSD SWAP',d.ssd_swap..' / '..d.ssd_swap_total..' GiB','ALLOCATED SWAP SPACE',(tonumber(d.ssd_swap) or 0)/math.max(1,tonumber(d.ssd_swap_total) or 1))
 tracked(cr,1515,822,'CPU / LAST 3 MIN',9,1.6,p.dim)
 if os.time()-last_sample>=3 then
  samples[#samples+1]=math.max(0,math.min(100,tonumber(d.cpu) or 0))
  last_sample=os.time()
 end
 if #samples>60 then table.remove(samples,1)end
 if #samples>1 then
  col(cr,p.sage,.8);cairo_set_line_width(cr,1.2)
  for i,v in ipairs(samples) do local x=1515+(i-1)*4.5;local y=901-v*.5;if i==1 then cairo_move_to(cr,x,y)else cairo_line_to(cr,x,y)end end
  cairo_stroke(cr)
 end
 line(cr,1515,912,1785,912,.15)
 tracked(cr,1515,945,'ATLAS / 01',9,2,p.dim)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
