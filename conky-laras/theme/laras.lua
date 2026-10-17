require 'cairo'
require 'cairo_xlib'
local home=os.getenv('HOME')
local p={ivory='F3EBDD',gold='D9B985',sage='BED0BA',muted='A4B7A7'}
local function color(cr,hex,alpha)
 cairo_set_source_rgba(cr,tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,alpha or 1)
end
local function text(cr,x,y,value,size,hex,family)
 cairo_select_font_face(cr,family or 'DejaVu Sans',CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size)
 if y>=750 then
  cairo_set_source_rgba(cr,.025,.06,.035,.95);cairo_move_to(cr,x+1,y+1);cairo_show_text(cr,tostring(value))
 end
 color(cr,hex);cairo_move_to(cr,x,y);cairo_show_text(cr,tostring(value))
end
local function centered(cr,x,y,value,size,hex,family)
 cairo_select_font_face(cr,family or 'DejaVu Sans',CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size)
 local e=cairo_text_extents_t:create();cairo_text_extents(cr,tostring(value),e)
 text(cr,x-e.width/2-e.x_bearing,y,value,size,hex,family)
end
local function line(cr,x,y,x2,y2,alpha)
 color(cr,p.gold,alpha or .3);cairo_set_line_width(cr,1)
 cairo_move_to(cr,x,y);cairo_line_to(cr,x2,y2);cairo_stroke(cr)
end
local function data()
 local d={};local f=io.open(home..'/.cache/conky-laras/metrics.txt')
 if f then for l in f:lines() do local k,v=l:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close()end
 return setmetatable(d,{__index=function()return '--'end})
end
local function meter(cr,x,label,value,detail,percent)
 text(cr,x,850,label,11,p.sage)
 text(cr,x,896,value,33,p.ivory,'DejaVu Serif')
 text(cr,x,926,detail,10,p.muted)
 line(cr,x,947,x+248,947,.2)
 if percent then
  color(cr,p.gold,.85);cairo_set_line_width(cr,2)
  cairo_move_to(cr,x,947);cairo_line_to(cr,x+248*math.max(0,math.min(100,percent))/100,947);cairo_stroke(cr)
 end
end
function conky_laras()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local scale=(tonumber(os.getenv('LARAS_WIDTH')) or 1920)/1920;cairo_scale(cr,scale,scale)
 local d=data()
 text(cr,88,83,'L A R A S',19,p.ivory)
 text(cr,89,110,'RUANG UNTUK MELAMBAT',9,p.sage)
 text(cr,1515,83,'MENYALA  '..d.uptime,12,p.sage)
 -- A small abstract rice sprig, drawn natively rather than baked into the wallpaper.
 color(cr,p.gold,.75);cairo_set_line_width(cr,1)
 cairo_move_to(cr,96,148);cairo_curve_to(cr,105,138,108,126,108,118);cairo_stroke(cr)
 for i=0,2 do
  cairo_new_path(cr);cairo_save(cr);cairo_translate(cr,104+i,138-i*6)
  cairo_rotate(cr,-.5);cairo_scale(cr,1,.4);cairo_arc(cr,0,0,3.5,0,math.pi*2);cairo_restore(cr);cairo_fill(cr)
 end
 local days={'MINGGU','SENIN','SELASA','RABU','KAMIS','JUMAT','SABTU'}
 local months={'JANUARI','FEBRUARI','MARET','APRIL','MEI','JUNI','JULI','AGUSTUS','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER'}
 centered(cr,960,137,days[tonumber(os.date('%w'))+1]..', '..os.date('%d')..' '..months[tonumber(os.date('%m'))]..' '..os.date('%Y'),13,p.sage)
 centered(cr,960,289,os.date('%H.%M'),138,p.ivory,'DejaVu Serif')
 line(cr,922,324,998,324,.7)
 centered(cr,960,367,'MALANG  /  '..d.temperature..'°C  /  '..d.weather,12,p.gold)
 meter(cr,100,'PROSESOR',d.cpu..' %','SUHU CPU  '..d.cpu_temp..'°C',tonumber(d.cpu))
 meter(cr,446,'MEMORI TERSEDIA',d.ram_available..' GiB',d.ram..'% TERPAKAI',tonumber(d.ram))
 meter(cr,792,'PENYIMPANAN KOSONG',d.disk_free..' GiB',d.disk..'% TERPAKAI',tonumber(d.disk))
 meter(cr,1138,'ZRAM',d.zram..' / '..d.zram_total..' GiB',d.zram_physical..' MiB RAM FISIK',nil)
 meter(cr,1484,'SWAP SSD',d.ssd_swap..' / '..d.ssd_swap_total..' GiB','ALOKASI SWAP TERPAKAI',nil)
 text(cr,100,988,'SENJA DI PERSAWAHAN NUSANTARA',10,p.sage)
 text(cr,1484,988,'TENANG DALAM KESEHARIAN',10,p.sage)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
