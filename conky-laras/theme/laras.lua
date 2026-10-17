require 'cairo'
require 'cairo_xlib'
local home=os.getenv('HOME')
local p={ivory='F3EBDD',gold='D9B985',sage='BED0BA',muted='A4B7A7',amber='E8B26C',red='DA8266'}
local function color(cr,hex,alpha)
 cairo_set_source_rgba(cr,tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,alpha or 1)
end
local function text(cr,x,y,value,size,hex,family)
 cairo_select_font_face(cr,family or 'DejaVu Sans',CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size)
 cairo_set_source_rgba(cr,.025,.06,.035,.8);cairo_move_to(cr,x+1,y+1);cairo_show_text(cr,tostring(value))
 color(cr,hex);cairo_move_to(cr,x,y);cairo_show_text(cr,tostring(value))
end
local function centered(cr,x,y,value,size,hex,family)
 cairo_select_font_face(cr,family or 'DejaVu Sans',CAIRO_FONT_SLANT_NORMAL,CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size)
 local e=cairo_text_extents_t:create();cairo_text_extents(cr,tostring(value),e)
 text(cr,x-e.width/2-e.x_bearing,y,value,size,hex,family)
end
local function line(cr,x,y,x2,y2,alpha,hex,width)
 color(cr,hex or p.gold,alpha or .3);cairo_set_line_width(cr,width or 1)
 cairo_move_to(cr,x,y);cairo_line_to(cr,x2,y2);cairo_stroke(cr)
end
local function ellipse(cr,x,y,r,angle,hex,alpha)
 cairo_new_path(cr);cairo_save(cr);cairo_translate(cr,x,y);cairo_rotate(cr,angle)
 cairo_scale(cr,1,.4);cairo_arc(cr,0,0,r,0,math.pi*2);cairo_restore(cr)
 color(cr,hex,alpha);cairo_fill(cr)
end
local function sprig(cr,x,y)
 color(cr,p.gold,.8);cairo_set_line_width(cr,1)
 cairo_move_to(cr,x,y);cairo_curve_to(cr,x+20,y-22,x+26,y-48,x+22,y-64);cairo_stroke(cr)
 for i=0,5 do
  ellipse(cr,x+7+i*3,y-13-i*7,5,-.7,p.gold,.9)
  ellipse(cr,x+17+i*2,y-16-i*7,5,.4,p.sage,.65)
 end
end
local function data()
 local d={};local f=io.open(home..'/.cache/conky-laras/metrics.txt')
 if f then for l in f:lines() do local k,v=l:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close()end
 return setmetatable(d,{__index=function()return '--'end})
end
local function hue(value)
 local n=tonumber(value)
 return n and (n>=90 and p.red or n>=75 and p.amber or p.gold) or p.muted
end
local function rice_meter(cr,x,y,label,value,detail)
 local n=tonumber(value);local h=hue(value)
 text(cr,x,y,label,12,p.sage)
 line(cr,x+93,y-4,x+389,y-4,.24,p.sage)
 for i=0,19 do
  local on=n and n>=(i+.5)*5
  ellipse(cr,x+100+i*15,y-4,6,i%2==0 and -.6 or .6,on and h or p.sage,on and .95 or .17)
 end
 text(cr,x+414,y+2,(n and tostring(n) or '--')..'%',22,h,'DejaVu Serif')
 text(cr,x+94,y+24,detail,10,p.muted)
end
local function dial(cr,cx,cy)
 local minute=tonumber(os.date('%M'));local hour=tonumber(os.date('%H'))+minute/60
 for i=0,59 do
  local a=-math.pi/2+i*math.pi/30
  local r=i%5==0 and 172 or 179
  local active=i<=minute
  line(cr,cx+math.cos(a)*r,cy+math.sin(a)*r,cx+math.cos(a)*185,cy+math.sin(a)*185,active and .85 or .2,active and p.gold or p.sage,i%5==0 and 1.5 or 1)
 end
 color(cr,p.gold,.25);cairo_set_line_width(cr,1)
 cairo_new_path(cr);cairo_arc(cr,cx,cy,159,0,math.pi*2);cairo_stroke(cr)
 if minute>0 then
  color(cr,p.gold,.85);cairo_set_line_width(cr,2)
  cairo_new_path(cr);cairo_arc(cr,cx,cy,159,-math.pi/2,-math.pi/2+minute/60*math.pi*2);cairo_stroke(cr)
 end
 local a=-math.pi/2+hour/24*math.pi*2
 color(cr,p.ivory);cairo_new_path(cr);cairo_arc(cr,cx+math.cos(a)*159,cy+math.sin(a)*159,4,0,math.pi*2);cairo_fill(cr)
 centered(cr,cx,cy-55,'WAKTU SETEMPAT',10,p.sage)
 centered(cr,cx,cy+30,os.date('%H.%M'),82,p.ivory,'DejaVu Serif')
 centered(cr,cx,cy+73,'JEDA DI ANTARA KESIBUKAN',9,p.gold)
end
local function trace(cr,x,y,w,h,history)
 local values={}
 for v in (history or ''):gmatch('[^,]+') do
  local n=tonumber(v);if n then values[#values+1]=math.max(0,math.min(100,n))end
 end
 -- Honest 0..100% scale; the initial chart expands the samples available so far.
 for i=0,2 do line(cr,x,y+i*h/2,x+w,y+i*h/2,.1,p.sage)end
 if #values<2 then text(cr,x,y+h/2,'MENUNGGU DENYUT PERTAMA...',11,p.muted);return end
 local step=w/(#values-1)
 cairo_new_path(cr)
 for i,v in ipairs(values)do
  local px,py=x+(i-1)*step,y+h-v/100*h
  if i==1 then cairo_move_to(cr,px,py)else cairo_line_to(cr,px,py)end
 end
 local path=cairo_copy_path(cr)
 cairo_line_to(cr,x+w,y+h);cairo_line_to(cr,x,y+h);cairo_close_path(cr)
 color(cr,p.gold,.07);cairo_fill(cr)
 cairo_append_path(cr,path);cairo_path_destroy(path)
 cairo_set_line_join(cr,CAIRO_LINE_JOIN_ROUND)
 color(cr,p.gold,.1);cairo_set_line_width(cr,5);cairo_stroke_preserve(cr)
 color(cr,p.gold,.9);cairo_set_line_width(cr,1.5);cairo_stroke(cr)
 local last=values[#values]
 color(cr,hue(last));cairo_new_path(cr);cairo_arc(cr,x+w,y+h-last/100*h,3,0,math.pi*2);cairo_fill(cr)
 text(cr,x,y+h+20,tostring((#values-1)*3)..' DETIK TERAKHIR',9,p.muted)
 text(cr,x+w-29,y+h+20,'KINI',9,p.sage)
end
local function weather_icon(cr,x,y)
 -- A neutral cloud silhouette accompanies the text; it is not a forecast glyph.
 color(cr,p.sage,.65);cairo_set_line_width(cr,1.3)
 cairo_new_path(cr);cairo_move_to(cr,x,y+17)
 cairo_curve_to(cr,x-12,y+17,x-12,y+3,x,y+3)
 cairo_curve_to(cr,x-2,y-12,x+23,y-14,x+26,y+1)
 cairo_curve_to(cr,x+45,y-2,x+49,y+17,x+35,y+17)
 cairo_line_to(cr,x,y+17);cairo_stroke(cr)
end
function conky_laras()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local scale=(tonumber(os.getenv('LARAS_WIDTH')) or 1920)/1920;cairo_scale(cr,scale,scale)
 local d=data()
 text(cr,87,75,'L A R A S',20,p.ivory)
 text(cr,88,100,'CATATAN SENJA / NUSANTARA',9,p.sage)
 dial(cr,310,305)
 local days={'MINGGU','SENIN','SELASA','RABU','KAMIS','JUMAT','SABTU'}
 local months={'JANUARI','FEBRUARI','MARET','APRIL','MEI','JUNI','JULI','AGUSTUS','SEPTEMBER','OKTOBER','NOVEMBER','DESEMBER'}
 centered(cr,310,533,days[tonumber(os.date('%w'))+1]..', '..os.date('%d')..' '..months[tonumber(os.date('%m'))],17,p.ivory,'DejaVu Serif')
 centered(cr,310,560,os.date('%Y'),11,p.gold)
 line(cr,606,178,606,373,.3)
 weather_icon(cr,654,193)
 text(cr,650,241,'MALANG',11,p.gold)
 text(cr,644,308,d.temperature..'°',65,p.ivory,'DejaVu Serif')
 text(cr,650,340,d.weather,11,p.sage)
 text(cr,650,366,'SUHU UDARA / CELSIUS',9,p.muted)
 text(cr,1120,111,'DENYUT MESIN',12,p.gold)
 text(cr,1494,111,'CPU / 0–100%',10,p.muted)
 trace(cr,1120,132,530,91,rawget(d,'cpu_hist'))
 rice_meter(cr,1120,302,'CPU',d.cpu,'SUHU  '..d.cpu_temp..'°C')
 rice_meter(cr,1120,369,'RAM',d.ram,d.ram_available..' GiB TERSEDIA')
 rice_meter(cr,1120,436,'SSD',d.disk,d.disk_free..' GiB KOSONG')
 -- A small field-notebook footer rather than five identical dashboard columns.
 sprig(cr,88,956)
 text(cr,145,889,'CADANGAN MEMORI',10,p.gold)
 text(cr,145,922,'ZRAM  '..d.zram..' / '..d.zram_total..' GiB',21,p.ivory,'DejaVu Serif')
 text(cr,145,951,d.zram_physical..' MiB RAM FISIK',10,p.sage)
 text(cr,542,922,'SWAP SSD  '..d.ssd_swap..' / '..d.ssd_swap_total..' GiB',19,p.ivory,'DejaVu Serif')
 text(cr,542,951,'RUANG SWAP TERPAKAI',10,p.sage)
 line(cr,145,976,803,976,.3)
 text(cr,1390,921,'WAKTU MENYALA',10,p.gold)
 text(cr,1390,952,d.uptime,24,p.ivory,'DejaVu Serif')
 text(cr,1390,981,'PELAN, NAMUN TETAP BERJALAN.',9,p.sage)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
