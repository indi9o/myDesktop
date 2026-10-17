require 'cairo'
require 'cairo_xlib'
local home=os.getenv('HOME')
local p={ivory='F0E7D4',gold='CDB37B',red='B9684F',sage='A6B8A6',muted='82978B',dark='102019'}
local function color(cr,h,a)
 cairo_set_source_rgba(cr,tonumber(h:sub(1,2),16)/255,tonumber(h:sub(3,4),16)/255,tonumber(h:sub(5,6),16)/255,a or 1)
end
local function text(cr,x,y,value,size,h,family)
 cairo_select_font_face(cr,family or 'DejaVu Sans Mono',CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
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
local function metric(cr,x,label,value,detail)
 tracked(cr,x,838,label,10,1.8,p.sage)
 text(cr,x,884,value,29,p.ivory,'DejaVu Sans')
 text(cr,x,916,detail,10,p.muted)
end
function conky_nusantara()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs);local scale=(tonumber(os.getenv('NUSANTARA_WIDTH')) or 1920)/1920;cairo_scale(cr,scale,scale)
 local d=read_data()
 tracked(cr,111,83,'NUSANTARA',20,5,p.ivory)
 rule(cr,112,110,158,110,.8)
 tracked(cr,179,114,'RUANG DESKTOP',9,2,p.gold)
 local days={'MINGGU','SENIN','SELASA','RABU','KAMIS','JUMAT','SABTU'}
 local months={'JANUARI','FEBRUARI','MARET','APRIL','MEI','JUNI','JULI','AGUSTUS','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER'}
 tracked(cr,115,221,days[tonumber(os.date('%w'))+1]..', '..os.date('%d')..' '..months[tonumber(os.date('%m'))]..' '..os.date('%Y'),11,1.9,p.sage)
 text(cr,95,382,os.date('%H.%M'),146,p.ivory,'DejaVu Serif')
 text(cr,600,383,'WIB',12,p.gold)
 tracked(cr,116,431,'MALANG / JAWA TIMUR',11,2,p.gold)
 text(cr,113,503,d.temperature..'°C',34,p.ivory,'DejaVu Sans')
 text(cr,230,500,d.weather,11,p.sage)
 rule(cr,115,540,400,540,.25)
 text(cr,115,579,'SUHU CPU',10,p.muted);text(cr,265,579,d.cpu_temp..'°C',12,p.sage)
 text(cr,115,614,'MENYALA',10,p.muted);text(cr,265,614,d.uptime,12,p.sage)
 for i=0,4 do ornament(cr,1780,110+i*116,34)end
 -- A quiet footer maintains legibility regardless of terrain detail.
 color(cr,p.dark,.96);cairo_rectangle(cr,70,779,1780,185);cairo_fill(cr)
 rule(cr,110,791,1810,791,.4)
 metric(cr,112,'PROSESOR',d.cpu..' %','BEBAN CPU')
 metric(cr,464,'MEMORI',d.ram_available..' GiB','TERSEDIA / '..d.ram..'% TERPAKAI')
 metric(cr,816,'PENYIMPANAN',d.disk_free..' GiB','KOSONG / '..d.disk..'% TERPAKAI')
 metric(cr,1168,'ZRAM',d.zram..' / '..d.zram_total..' GiB',d.zram_physical..' MiB RAM FISIK')
 metric(cr,1520,'SWAP SSD',d.ssd_swap..' / '..d.ssd_swap_total..' GiB','RUANG SWAP TERPAKAI')
 for i=1,4 do local x=112+352*i-30;rule(cr,x,822,x,925,.15)end
 for i=0,12 do ornament(cr,130+i*135,980,15)end
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
