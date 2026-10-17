require 'cairo'
require 'cairo_xlib'
local home=os.getenv('HOME')
-- P31 phosphor green; amber and red only when a resource runs high.
local p={main='7DF0A0',bright='C9FFD9',dim='4F8F66',faint='2C5A3C',amber='F2B84B',red='FF6E5E'}
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
local function color(cr,hex,alpha)
 cairo_set_source_rgba(cr,tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,alpha or 1)
end
-- Fill the current path with a soft phosphor bloom around it.
local function glow(cr,hex,spread)
 color(cr,hex,.16);cairo_set_line_width(cr,spread);cairo_stroke_preserve(cr)
 color(cr,hex);cairo_fill(cr)
end
local function text(cr,x,y,value,size,hex,bold)
 cairo_select_font_face(cr,'DejaVu Sans Mono',CAIRO_FONT_SLANT_NORMAL,bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size);cairo_move_to(cr,x,y);cairo_text_path(cr,tostring(value))
 glow(cr,hex,size*.18)
end
-- DejaVu Sans Mono advances 0.602 em per character, bold included.
local function advance(value,size) return #tostring(value)*size*.602 end
local function pixels(cr,x,y,value,scale,hex)
 for char in tostring(value):gmatch('.') do
  local g=glyphs[char]
  if g then
   for row,line in ipairs(g) do
    for col=1,#line do
     if line:sub(col,col)=='1' then cairo_rectangle(cr,x+(col-1)*scale,y+(row-1)*scale,scale-1.5,scale-1.5) end
    end
   end
   x=x+(#g[1]+1)*scale
  end
 end
 glow(cr,hex,scale*.45)
 return x
end
local function prompt(cr,y,command)
 text(cr,64,y,'fosfor:~$',15,p.dim,true)
 if command then text(cr,64+advance('fosfor:~$ ',15),y,command,15,p.bright) end
end
local function level(value)
 local v=tonumber(value)
 return not v and p.dim or v>=90 and p.red or v>=75 and p.amber or p.main
end
-- Segmented meter like a curses progress bar: 20 cells of five percent.
local function meter(cr,y,label,value)
 local v=tonumber(value);local hue=level(value)
 text(cr,64,y,label,16,p.main,true)
 for i=0,19 do
  cairo_rectangle(cr,154+i*15,y-14,11,16)
  if v and v>=(i+.5)*5 then glow(cr,hue,2) else color(cr,p.faint,.55);cairo_fill(cr) end
 end
 text(cr,474,y,(v and string.format('%3d',v) or ' --')..'%',16,hue,true)
end
local function row(cr,y,key,value)
 text(cr,64,y,key,15,p.dim);text(cr,244,y,value,15,p.bright)
end
local function trace(cr,x,y,w,h,history)
 color(cr,p.faint,.6);cairo_set_line_width(cr,1)
 cairo_rectangle(cr,x+.5,y+.5,w,h);cairo_stroke(cr)
 for i=1,3 do cairo_move_to(cr,x,y+i*h/4+.5);cairo_line_to(cr,x+w,y+i*h/4+.5) end
 cairo_set_dash(cr,{2,4},2,0);cairo_stroke(cr);cairo_set_dash(cr,{},0,0)
 local values={}
 for v in (history or ''):gmatch('[^,]+') do values[#values+1]=math.max(0,math.min(100,tonumber(v) or 0)) end
 if #values<2 then text(cr,x+12,y+h/2+5,'menunggu data...',13,p.dim);return end
 local step=w/59
 local x0=x+w-(#values-1)*step
 for i,v in ipairs(values) do cairo_line_to(cr,x0+(i-1)*step,y+h-v/100*(h-6)-3) end
 local path=cairo_copy_path(cr)
 cairo_line_to(cr,x+w,y+h);cairo_line_to(cr,x0,y+h);cairo_close_path(cr)
 color(cr,p.main,.08);cairo_fill(cr)
 cairo_append_path(cr,path);cairo_path_destroy(path)
 cairo_set_line_join(cr,CAIRO_LINE_JOIN_ROUND)
 color(cr,p.main,.18);cairo_set_line_width(cr,5);cairo_stroke_preserve(cr)
 color(cr,p.main);cairo_set_line_width(cr,1.6);cairo_stroke(cr)
end
local function data()
 local d={};local f=io.open(home..'/.cache/conky-fosfor/metrics.txt')
 if f then for l in f:lines() do local k,v=l:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close()end
 return setmetatable(d,{__index=function()return '--'end})
end
function conky_fosfor()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local scale=(tonumber(os.getenv('FOSFOR_WIDTH')) or 1920)/1920
 local d=data()
 -- Draw into a group so scanlines can be cut from the lettering only.
 cairo_push_group(cr)
 cairo_scale(cr,scale,scale)
 prompt(cr,40,'date +%H:%M')
 local right=pixels(cr,64,62,os.date('%H:%M'),15,p.main)
 cairo_rectangle(cr,right+4,62+6*15,4*15-1.5,15-1.5);glow(cr,p.bright,6)
 local days={'MIN','SEN','SEL','RAB','KAM','JUM','SAB'}
 local months={'JAN','FEB','MAR','APR','MEI','JUN','JUL','AGU','SEP','OKT','NOV','DES'}
 text(cr,64,210,days[tonumber(os.date('%w'))+1]..' '..os.date('%d')..' '..months[tonumber(os.date('%m'))]..' '..os.date('%Y'),24,p.bright,true)
 text(cr,64,240,'MALANG  '..d.temperature..'°C  '..d.weather,16,p.main)
 prompt(cr,296,'sysstat')
 meter(cr,334,'cpu',d.cpu)
 meter(cr,368,'ram',d.ram)
 meter(cr,402,'ssd',d.disk)
 color(cr,p.faint);cairo_set_line_width(cr,1);cairo_set_dash(cr,{4,4},2,0)
 cairo_move_to(cr,64,428.5);cairo_line_to(cr,538,428.5);cairo_stroke(cr);cairo_set_dash(cr,{},0,0)
 row(cr,460,'mem.tersedia',d.ram_available..' GiB')
 row(cr,488,'zram',d.zram..' / '..d.zram_total..' GiB')
 row(cr,516,'zram.fisik',d.zram_physical..' MiB')
 row(cr,544,'swap.ssd',d.ssd_swap..' / '..d.ssd_swap_total..' GiB')
 row(cr,572,'ssd.kosong',d.disk_free..' GiB')
 row(cr,600,'suhu.cpu',d.cpu_temp..'°C')
 row(cr,628,'menyala',d.uptime)
 prompt(cr,684,'tail -f cpu.log')
 trace(cr,64,702,474,84,rawget(d,'cpu_hist'))
 text(cr,64,808,'-3 mnt',11,p.dim);text(cr,496,808,'kini',11,p.dim)
 prompt(cr,856)
 cairo_rectangle(cr,64+advance('fosfor:~$ ',15),842,9,17);glow(cr,p.main,4)
 -- Scanlines in device pixels, matching the wallpaper's three-pixel pitch.
 cairo_identity_matrix(cr)
 cairo_set_operator(cr,CAIRO_OPERATOR_DEST_OUT);cairo_set_source_rgba(cr,0,0,0,.32)
 for y=0,conky_window.height,3 do cairo_rectangle(cr,0,y,conky_window.width,1) end
 cairo_fill(cr)
 cairo_pop_group_to_source(cr);cairo_paint(cr)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
