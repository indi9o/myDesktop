require 'cairo'
require 'cairo_xlib'
local home=os.getenv('HOME')
-- Merah-putih, antique gold, jade: a fictional Indonesian orbital mission.
local p={red='E1785F',ivory='F5E8C9',gold='D8B477',jade='A6C8AF',muted='A7B8AF'}
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

local function line(cr,x,y,x2,y2)
 color(cr,p.gold,.45);cairo_set_line_width(cr,1)
 cairo_move_to(cr,x,y);cairo_line_to(cr,x2,y2);cairo_stroke(cr)
end
local function kawung(cr,cx,cy)
 color(cr,p.gold,.55);cairo_set_line_width(cr,.9)
 for i=0,3 do
  cairo_new_path(cr);cairo_save(cr);cairo_translate(cr,cx,cy);cairo_rotate(cr,math.pi/4+i*math.pi/2)
  cairo_translate(cr,7,0);cairo_scale(cr,.65,.3);cairo_arc(cr,0,0,10,0,math.pi*2)
  cairo_restore(cr);cairo_stroke(cr)
 end
end
local function data()
 local d={};local f=io.open(home..'/.cache/conky-garuda-orbit/metrics.txt')
 if f then for l in f:lines() do local k,v=l:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close()end
 return setmetatable(d,{__index=function()return '--'end})
end
local function metric(cr,x,label,value,h)
 text(cr,x,37,label,13,p.gold,true);text(cr,x+53,37,value,20,h,true)
end
function conky_garuda_orbit()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local scale=(tonumber(os.getenv('GARUDA_ORBIT_WIDTH')) or 1920)/1920;cairo_scale(cr,scale,scale)
 local d=data()
 -- No opaque panel: all lettering is drawn directly on the wallpaper.
 metric(cr,650,'CPU',d.cpu..'%',p.jade)
 metric(cr,845,'RAM',d.ram..'%',p.ivory)
 metric(cr,1040,'SSD',d.disk..'%',p.jade)
 text(cr,1450,37,'MENYALA',12,p.gold,true);text(cr,1550,37,d.uptime,17,p.ivory,true)
 color(cr,p.red);cairo_rectangle(cr,58,56,29,9);cairo_fill(cr)
 color(cr,p.ivory);cairo_rectangle(cr,58,65,29,9);cairo_fill(cr)
 text(cr,102,73,'GARUDA / ORBIT',17,p.ivory,true)
 text(cr,58,100,'NUSANTARA · EKSPLORASI ANTARIKSA',10,p.gold)
 pixels(cr,58,137,os.date('%H:%M'),12,p.red)
 text(cr,58,246,'WAKTU INDONESIA BARAT',10,p.muted)
 local days={'MINGGU','SENIN','SELASA','RABU','KAMIS','JUMAT','SABTU'}
 local months={'JAN','FEB','MAR','APR','MEI','JUN','JUL','AGU','SEP','OKT','NOV','DES'}
 pixels(cr,58,283,os.date('%d'),8,p.ivory)
 text(cr,172,303,days[tonumber(os.date('%w'))+1],16,p.gold,true)
 text(cr,172,334,months[tonumber(os.date('%m'))]..' '..os.date('%Y'),23,p.jade,true)
 line(cr,58,368,356,368);kawung(cr,380,368)
 text(cr,58,407,'MALANG / JAWA TIMUR',11,p.gold,true)
 text(cr,58,456,d.temperature..'°C',36,p.jade,true)
 text(cr,58,484,d.weather,11,p.muted)
 line(cr,58,517,356,517);kawung(cr,380,517)
 text(cr,58,553,'MEMORI TERSEDIA',11,p.gold,true)
 text(cr,58,587,d.ram_available..' GiB',27,p.ivory,true)
 text(cr,58,627,'ZRAM',11,p.jade,true);text(cr,185,627,d.zram..' / '..d.zram_total..' GiB',12,p.ivory)
 text(cr,58,657,'SWAP SSD',11,p.red,true);text(cr,185,657,d.ssd_swap..' / '..d.ssd_swap_total..' GiB',12,p.ivory)
 text(cr,58,685,'ZRAM DI RAM  '..d.zram_physical..' MiB',10,p.muted)
 line(cr,58,716,356,716);kawung(cr,380,716)
 text(cr,58,752,'PENYIMPANAN KOSONG',11,p.gold,true)
 text(cr,58,786,d.disk_free..' GiB',27,p.ivory,true)
 text(cr,58,829,'SUHU CPU  '..d.cpu_temp..'°C',12,p.jade)
 text(cr,58,899,'INDONESIA / LANGIT TANPA BATAS',10,p.gold)
 line(cr,58,922,135,922)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
