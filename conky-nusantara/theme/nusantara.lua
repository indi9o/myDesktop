require 'cairo'
require 'cairo_xlib'
local home=os.getenv('HOME')
local p={ivory='F0E7D4',gold='CDB37B',red='DC8068',sage='BECAB4',muted='A6B5A6',dark='102019'}
local function color(cr,h,a)
 cairo_set_source_rgba(cr,tonumber(h:sub(1,2),16)/255,tonumber(h:sub(3,4),16)/255,tonumber(h:sub(5,6),16)/255,a or 1)
end
local function text(cr,x,y,value,size,h,family,bold)
 cairo_select_font_face(cr,family or 'DejaVu Sans Mono',CAIRO_FONT_SLANT_NORMAL,bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size);color(cr,h);cairo_move_to(cr,x,y);cairo_show_text(cr,tostring(value))
end
local function tracked(cr,x,y,value,size,gap,h)
 for c in value:gmatch('.') do text(cr,x,y,c,size,h);x=x+size*.6+gap end
end
local function rule(cr,x,y,x2,y2,a)
 color(cr,p.gold,a or .25);cairo_set_line_width(cr,1);cairo_move_to(cr,x,y);cairo_line_to(cr,x2,y2);cairo_stroke(cr)
end
local function ornament(cr,cx,cy,size)
 -- Four elliptical petals: a geometric ornament inspired by batik kawung.
 color(cr,p.gold,.32);cairo_set_line_width(cr,.8)
 for i=0,3 do
  cairo_new_path(cr);cairo_save(cr);cairo_translate(cr,cx,cy);cairo_rotate(cr,math.pi/4+i*math.pi/2)
  cairo_translate(cr,size*.39,0);cairo_scale(cr,.65,.3)
  cairo_arc(cr,0,0,size*.53,0,math.pi*2);cairo_restore(cr);cairo_stroke(cr)
 end
 color(cr,p.gold,.5);cairo_new_path(cr);cairo_arc(cr,cx,cy,1.7,0,math.pi*2);cairo_fill(cr)
end
local function read_data()
 local d={};local f=io.open(home..'/.cache/conky-nusantara/metrics.txt')
 if f then for l in f:lines() do local k,v=l:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close()end
 return setmetatable(d,{__index=function()return '--'end})
end
local function metric(cr,x,label,value,h)
 text(cr,x,34,label,13,p.gold,'DejaVu Serif',true)
 text(cr,x+55,34,value,19,h,'DejaVu Serif',true)
end
function conky_nusantara()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs);local scale=(tonumber(os.getenv('NUSANTARA_WIDTH')) or 1920)/1920;cairo_scale(cr,scale,scale)
 local d=read_data()
 -- Orbit layout: time/date/weather on the left; essential metrics across the top.
 -- Brick red, warm ivory, batik gold, serif lettering and kawung ornaments.
 metric(cr,680,'CPU',d.cpu..'%',p.sage)
 metric(cr,875,'RAM',d.ram..'%',p.ivory)
 metric(cr,1070,'SSD',d.disk..'%',p.sage)
 text(cr,1445,34,'MENYALA',12,p.gold,'DejaVu Serif',true)
 text(cr,1550,34,d.uptime,18,p.ivory,'DejaVu Serif',true)
 tracked(cr,58,56,'NUSANTARA',14,4,p.gold)
 ornament(cr,365,49,20)
 text(cr,49,196,os.date('%H.%M'),104,p.red,'DejaVu Serif',true)
 text(cr,59,226,'WIB',10,p.gold)
 local days={'MINGGU','SENIN','SELASA','RABU','KAMIS','JUMAT','SABTU'}
 local months={'JANUARI','FEBRUARI','MARET','APRIL','MEI','JUNI','JULI','AGUSTUS','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER'}
 text(cr,58,278,days[tonumber(os.date('%w'))+1]..', '..os.date('%d'),29,p.ivory,'DejaVu Serif',true)
 text(cr,58,318,months[tonumber(os.date('%m'))]..' '..os.date('%Y'),22,p.gold,'DejaVu Serif')
 text(cr,58,380,d.temperature..'°C',37,p.sage,'DejaVu Serif',true)
 tracked(cr,58,414,'MALANG / JAWA TIMUR',10,1.2,p.gold)
 text(cr,58,441,d.weather,11,p.sage)
 rule(cr,58,470,353,470,.5);ornament(cr,378,470,15)
 tracked(cr,58,509,'MEMORI TERSEDIA',10,1.3,p.gold)
 text(cr,58,549,d.ram_available..' GiB',28,p.ivory,'DejaVu Serif')
 text(cr,58,591,'ZRAM',11,p.sage);text(cr,187,591,d.zram..' / '..d.zram_total..' GiB',13,p.ivory)
 text(cr,58,623,'SWAP SSD',11,p.gold);text(cr,187,623,d.ssd_swap..' / '..d.ssd_swap_total..' GiB',13,p.ivory)
 text(cr,58,653,'ZRAM DI RAM  '..d.zram_physical..' MiB',10,p.muted)
 rule(cr,58,683,353,683,.5);ornament(cr,378,683,15)
 tracked(cr,58,722,'PENYIMPANAN KOSONG',10,1.3,p.gold)
 text(cr,58,762,d.disk_free..' GiB',28,p.ivory,'DejaVu Serif')
 text(cr,58,807,'SUHU CPU  '..d.cpu_temp..'°C',12,p.sage)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
