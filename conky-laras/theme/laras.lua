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
local function data()
 local d={};local f=io.open(home..'/.cache/conky-laras/metrics.txt')
 if f then for l in f:lines() do local k,v=l:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close()end
 return setmetatable(d,{__index=function()return '--'end})
end
local function hue(value)
 local n=tonumber(value)
 return n and (n>=90 and p.red or n>=75 and p.amber or p.gold) or p.muted
end
local function sun_icon(cr,x,y,active)
 color(cr,'09251B',active and .35 or .3)
 cairo_new_path(cr);cairo_arc(cr,x+1,y+1,10,0,math.pi*2);cairo_fill(cr)
 color(cr,p.gold,active and .14 or .025)
 cairo_new_path(cr);cairo_arc(cr,x,y,16,0,math.pi*2);cairo_fill(cr)
 color(cr,p.gold,active and 1 or .45)
 cairo_new_path(cr);cairo_arc(cr,x,y,7,0,math.pi*2);cairo_fill(cr)
 for i=0,7 do
  local a=i*math.pi/4
  line(cr,x+math.cos(a)*11,y+math.sin(a)*11,x+math.cos(a)*15,y+math.sin(a)*15,active and .95 or .45,p.gold,1.3)
 end
end
local function moon_icon(cr,x,y,active)
 cairo_save(cr);cairo_push_group(cr)
 color(cr,p.ivory,active and 1 or .45)
 cairo_new_path(cr);cairo_arc(cr,x,y,10,0,math.pi*2);cairo_fill(cr)
 cairo_set_operator(cr,CAIRO_OPERATOR_DEST_OUT)
 cairo_set_source_rgba(cr,0,0,0,1)
 cairo_new_path(cr);cairo_arc(cr,x+5,y-3,9,0,math.pi*2);cairo_fill(cr)
 cairo_set_operator(cr,CAIRO_OPERATOR_OVER);cairo_pop_group_to_source(cr);cairo_paint(cr);cairo_restore(cr)
 if active then
  line(cr,x+16,y-12,x+16,y-6,.8,p.ivory)
  line(cr,x+13,y-9,x+19,y-9,.8,p.ivory)
 end
end
local function small_icon(cr,x,y,fn,active)
 cairo_save(cr);cairo_translate(cr,x,y);cairo_scale(cr,.55,.55)
 fn(cr,0,0,active);cairo_restore(cr)
end
local function dial(cr,cx,cy,d)
 local minute=tonumber(os.date('%M'))
 local phase=rawget(d,'solar_phase') or 'night'
 local progress=tonumber(rawget(d,'solar_progress')) or 0
 local sun=tonumber(rawget(d,'sun_angle')) or 0
 local moon=tonumber(rawget(d,'moon_angle')) or math.pi
 local radius=94
 for i=0,59 do
  local a=-math.pi/2+i*math.pi/30
  local inner=i%5==0 and 100 or 103
  line(cr,cx+math.cos(a)*inner,cy+math.sin(a)*inner,cx+math.cos(a)*105,cy+math.sin(a)*105,i==minute and .8 or .18,i==minute and p.ivory or p.gold,.8)
 end
 color(cr,phase=='day' and p.gold or p.ivory,.28);cairo_set_line_width(cr,.8)
 cairo_new_path(cr);cairo_arc(cr,cx,cy,radius,math.pi,2*math.pi);cairo_stroke(cr)
 color(cr,p.sage,.16);cairo_set_dash(cr,{1,4},2,0)
 cairo_new_path(cr);cairo_arc(cr,cx,cy,radius,0,math.pi);cairo_stroke(cr);cairo_set_dash(cr,{},0,0)
 if progress>0 then
  color(cr,phase=='day' and p.gold or p.ivory,.7);cairo_set_line_width(cr,1.2)
  cairo_new_path(cr);cairo_arc(cr,cx,cy,radius,math.pi,math.pi+progress*math.pi);cairo_stroke(cr)
 end
 small_icon(cr,cx+math.cos(sun)*radius,cy+math.sin(sun)*radius,sun_icon,phase=='day')
 small_icon(cr,cx+math.cos(moon)*radius,cy+math.sin(moon)*radius,moon_icon,phase=='night')
 centered(cr,cx,cy-25,phase=='day' and 'SIANG' or 'MALAM',12,p.sage)
 centered(cr,cx,cy+23,os.date('%H.%M'),56,p.ivory,'DejaVu Serif')
 if rawget(d,'solar_source')~='open-meteo' then
  centered(cr,cx,cy+46,'SIKLUS PERKIRAAN',12,p.gold)
 end
end
function conky_laras()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local scale=math.min((tonumber(os.getenv('LARAS_WIDTH')) or 1920)/1920,(tonumber(os.getenv('LARAS_HEIGHT')) or 1080)/1080)
 cairo_scale(cr,scale,scale);cairo_translate(cr,64,64)
 local d=data()
 -- All visible widgets occupy one 300 x 350 reference area, leaving the landscape clear.
 dial(cr,150,110,d)
 local days={'MINGGU','SENIN','SELASA','RABU','KAMIS','JUMAT','SABTU'}
 local months={'JAN','FEB','MAR','APR','MEI','JUN','JUL','AGU','SEP','OKT','NOV','DES'}
 centered(cr,150,230,days[tonumber(os.date('%w'))+1]..', '..os.date('%d')..' '..months[tonumber(os.date('%m'))]..' '..os.date('%Y'),13,p.sage)
 centered(cr,150,257,'MALANG  '..d.temperature..'°C',15,p.ivory)
 centered(cr,150,279,d.weather,13,p.gold)
 line(cr,20,296,280,296,.22)
 local metrics={{'CPU',d.cpu},{'RAM',d.ram},{'SSD',d.disk}}
 for i,row in ipairs(metrics)do
  local x=55+(i-1)*95
  centered(cr,x,319,row[1],12,p.muted)
  centered(cr,x,343,row[2]..'%',16,hue(row[2]))
 end
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
