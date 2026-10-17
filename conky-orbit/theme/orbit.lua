require 'cairo'
require 'cairo_xlib'
local home = os.getenv('HOME')
local colors = {coral='CD715B', teal='86AAA8', green='9EB987', amber='CCAC79', dim='778693', light='C6D0D4'}
local glyphs = {
 ['0']={'11111','11001','11001','10101','10011','10011','11111'},
 ['1']={'00110','01110','00110','00110','00110','00110','11111'},
 ['2']={'11111','00011','00011','11111','11000','11000','11111'},
 ['3']={'11111','00011','00011','01111','00011','00011','11111'},
 ['4']={'11011','11011','11011','11111','00011','00011','00011'},
 ['5']={'11111','11000','11000','11111','00011','00011','11111'},
 ['6']={'11111','11000','11000','11111','11011','11011','11111'},
 ['7']={'11111','00011','00110','00110','01100','01100','01100'},
 ['8']={'11111','11011','11011','11111','11011','11011','11111'},
 ['9']={'11111','11011','11011','11111','00011','00011','11111'},
 [':']={'00','11','11','00','11','11','00'},
}
local function color(cr, hex, alpha)
 cairo_set_source_rgba(cr, tonumber(hex:sub(1,2),16)/255, tonumber(hex:sub(3,4),16)/255, tonumber(hex:sub(5,6),16)/255, alpha or 1)
end
local function text(cr,x,y,value,size,hex,bold)
 cairo_select_font_face(cr,'DejaVu Sans Mono',CAIRO_FONT_SLANT_NORMAL,bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size); color(cr,hex); cairo_move_to(cr,x,y); cairo_show_text(cr,tostring(value))
end
local function pixels(cr,x,y,value,scale,hex)
 color(cr,hex)
 for char in tostring(value):gmatch('.') do
  local g=glyphs[char]
  if g then
   for row,line in ipairs(g) do
    for col=1,#line do
     if line:sub(col,col)=='1' then cairo_rectangle(cr,x+(col-1)*scale,y+(row-1)*scale,scale-.5,scale-.5) end
    end
   end
   cairo_fill(cr); x=x+(#g[1]+1)*scale
  end
 end
end
local function rule(cr,x,y,w)
 color(cr,colors.dim,.35); cairo_set_line_width(cr,1); cairo_move_to(cr,x,y);cairo_line_to(cr,x+w,y);cairo_stroke(cr)
end
local function metric(cr,x,label,value,hex)
 text(cr,x,32,label,15,hex,true); text(cr,x+52,32,value,16,hex,true)
end
local function data()
 local d={};local f=io.open(home..'/.cache/conky-orbit/metrics.txt')
 if f then for line in f:lines() do local k,v=line:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close() end
 return setmetatable(d,{__index=function() return '--' end})
end
function conky_orbit()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 -- All positions are scaled from the 1920 x 1080 reference layout.
 local scale=conky_window.width/1920;cairo_scale(cr,scale,scale)
 local d=data()
 metric(cr,680,'CPU',string.format('%02d',tonumber(d.cpu) or 0)..'%',colors.teal)
 metric(cr,875,'RAM',d.ram..'%',colors.amber)
 metric(cr,1070,'SSD',d.disk..'%',colors.teal)
 text(cr,1510,32,'UPTIME  '..d.uptime,15,colors.teal,true)
 pixels(cr,54,78,os.date('%H:%M'),14,colors.coral)
 local weekdays={'SUN','MON','TUE','WED','THU','FRI','SAT'}
 local months={'JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'}
 local day=weekdays[tonumber(os.date('%w'))+1]
 for i=1,3 do text(cr,58,250+(i-1)*63,day:sub(i,i),35,colors.teal,true) end
 pixels(cr,158,213,os.date('%d'),9,colors.coral)
 text(cr,159,320,months[tonumber(os.date('%m'))],36,colors.green,true)
 text(cr,159,379,d.temperature..'°C',34,colors.green,true)
 text(cr,57,423,'MALANG / '..d.weather,12,colors.dim)
 rule(cr,57,459,298)
 text(cr,57,492,'MEMORY AVAILABLE',12,colors.dim)
 text(cr,57,524,d.ram_available..' GiB',24,colors.light,true)
 text(cr,57,567,'ZRAM',12,colors.teal,true)
 text(cr,180,567,d.zram..' / '..d.zram_total..' GiB',13,colors.light)
 text(cr,57,599,'SSD SWAP',12,colors.amber,true)
 text(cr,180,599,d.ssd_swap..' / '..d.ssd_swap_total..' GiB',13,colors.light)
 text(cr,57,629,'ZRAM IN RAM  '..d.zram_physical..' MiB',11,colors.dim)
 rule(cr,57,657,298)
 text(cr,57,691,'DISK FREE',12,colors.dim)
 text(cr,57,723,d.disk_free..' GiB',24,colors.light,true)
 text(cr,57,767,'CPU TEMP  '..d.cpu_temp..'°C',12,colors.teal)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
