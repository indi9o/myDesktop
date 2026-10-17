require 'cairo'
require 'cairo_xlib'
local home=os.getenv('HOME')
-- Dusk over the terraces: cream, dusk amber, young rice, brick for warnings.
local p={cream='F3E6CC',amber='E9A86A',padi='9CC37A',brick='D9735B',muted='B9A99A'}
local function color(cr,hex,alpha)
 cairo_set_source_rgba(cr,tonumber(hex:sub(1,2),16)/255,tonumber(hex:sub(3,4),16)/255,tonumber(hex:sub(5,6),16)/255,alpha or 1)
end
local function face(cr,size,serif,bold)
 cairo_select_font_face(cr,serif and 'DejaVu Serif' or 'DejaVu Sans',CAIRO_FONT_SLANT_NORMAL,bold and CAIRO_FONT_WEIGHT_BOLD or CAIRO_FONT_WEIGHT_NORMAL)
 cairo_set_font_size(cr,size)
end
-- A soft drop shadow keeps lettering legible over the lit terraces.
local function text(cr,x,y,value,size,hex,serif,bold,align)
 value=tostring(value);face(cr,size,serif,bold)
 if align then
  local e=cairo_text_extents_t:create();cairo_text_extents(cr,value,e)
  x=x-e.x_advance*align;e:destroy()
 end
 cairo_move_to(cr,x+1,y+1.5);cairo_text_path(cr,value);color(cr,'0E0A12',.5);cairo_fill(cr)
 cairo_move_to(cr,x,y);cairo_text_path(cr,value);color(cr,hex);cairo_fill(cr)
end
local function title(value)
 return (value:lower():gsub('(%a)(%a*)',function(a,b)return a:upper()..b end))
end
local function minutes(value)
 local h,m=tostring(value):match('^(%d+):(%d+)$')
 return h and tonumber(h)*60+tonumber(m)
end
local function level(value)
 local v=tonumber(value)
 return not v and p.muted or v>=90 and p.brick or v>=75 and p.amber or p.padi
end
local function grain(cr,x,y)
 cairo_save(cr);cairo_translate(cr,x,y);cairo_rotate(cr,-.35);cairo_scale(cr,5.6,2.5)
 cairo_arc(cr,0,0,1,0,2*math.pi);cairo_restore(cr)
end
-- Meter as a row of twenty rice grains, five percent each.
local function meter(cr,y,label,value)
 local v=tonumber(value);local hue=level(value)
 text(cr,64,y,label,13,p.amber,false,true)
 for i=0,19 do
  grain(cr,128+i*13.5,y-5)
  if v and v>=(i+.5)*5 then color(cr,hue);cairo_fill(cr)
  else color(cr,p.cream,.28);cairo_set_line_width(cr,1);cairo_stroke(cr) end
 end
 text(cr,470,y+1,v and v..'%' or '--',21,hue,true,false,1)
end
local function row(cr,y,key,value)
 text(cr,64,y,key,14,p.muted);text(cr,470,y,value,15,p.cream,false,false,1)
end
local function divider(cr,y)
 color(cr,p.cream,.22);cairo_set_line_width(cr,1)
 cairo_move_to(cr,64,y+.5);cairo_line_to(cr,250,y+.5);cairo_move_to(cr,284,y+.5);cairo_line_to(cr,470,y+.5);cairo_stroke(cr)
 grain(cr,267,y+.5);color(cr,p.amber,.85);cairo_fill(cr)
end
-- A 24-hour sun path: daylight above the horizon, night below, marker at the current time.
local function sun(cr,d)
 local left,w,base,up,down=64,406,328,70,28
 local rise,set=minutes(d.sunrise),minutes(d.sunset)
 local valid=rise and set and set>rise
 local function pos(t)
  local x=left+w*t/1440
  if not valid then return x,base end
  if t>=rise and t<=set then return x,base-up*math.sin(math.pi*(t-rise)/(set-rise)) end
  return x,base+down*math.sin(math.pi*((t-set)%1440)/(1440-(set-rise)))
 end
 local function path(t0,t1)
  cairo_new_path(cr)
  for t=t0,t1,6 do cairo_line_to(cr,pos(t)) end
  cairo_line_to(cr,pos(t1))
 end
 color(cr,p.cream,.3);cairo_set_line_width(cr,1)
 cairo_move_to(cr,left,base+.5);cairo_line_to(cr,left+w,base+.5)
 for h=0,24,6 do
  local x=left+w*h/24
  cairo_move_to(cr,x+.5,base-3);cairo_line_to(cr,x+.5,base+4)
 end
 cairo_stroke(cr)
 for h=0,24,6 do text(cr,left+w*h/24,base+down+24,string.format('%02d',h),11,p.muted,false,false,h==0 and 0 or h==24 and 1 or .5) end
 path(0,1440);color(cr,p.cream,.35);cairo_set_dash(cr,{2,5},2,0);cairo_stroke(cr);cairo_set_dash(cr,{},0,0)
 local now=tonumber(os.date('%H'))*60+tonumber(os.date('%M'))
 path(0,now);color(cr,p.amber,.85);cairo_set_line_width(cr,2);cairo_stroke(cr)
 local x,y=pos(now)
 if valid and now>=rise and now<=set then
  local halo=cairo_pattern_create_radial(x,y,0,x,y,22)
  cairo_pattern_add_color_stop_rgba(halo,0,.98,.86,.6,.55);cairo_pattern_add_color_stop_rgba(halo,1,.98,.86,.6,0)
  cairo_set_source(cr,halo);cairo_arc(cr,x,y,22,0,2*math.pi);cairo_fill(cr);cairo_pattern_destroy(halo)
  cairo_arc(cr,x,y,6.5,0,2*math.pi);color(cr,'FBE4B6');cairo_fill(cr)
 else
  -- Crescent moon: the disc minus an offset disc, clipped to the disc.
  cairo_save(cr);cairo_arc(cr,x,y,6.5,0,2*math.pi);cairo_clip(cr)
  cairo_set_fill_rule(cr,CAIRO_FILL_RULE_EVEN_ODD)
  cairo_arc(cr,x,y,6.5,0,2*math.pi);cairo_new_sub_path(cr);cairo_arc(cr,x+3.2,y-2.2,5.6,0,2*math.pi)
  color(cr,p.cream,.92);cairo_fill(cr);cairo_restore(cr)
 end
 text(cr,left,base-10,'TERBIT '..d.sunrise,11,p.muted)
 text(cr,left+w,base-10,'TERBENAM '..d.sunset,11,p.muted,false,false,1)
end
local function data()
 local d={};local f=io.open(home..'/.cache/conky-sawah/metrics.txt')
 if f then for l in f:lines() do local k,v=l:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close()end
 return setmetatable(d,{__index=function()return '--'end})
end
function conky_sawah()
 if not conky_window then return end
 local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual,conky_window.width,conky_window.height)
 local cr=cairo_create(cs)
 local scale=(tonumber(os.getenv('SAWAH_WIDTH')) or 1920)/1920;cairo_scale(cr,scale,scale)
 local d=data()
 local days={'Minggu','Senin','Selasa','Rabu','Kamis','Jumat','Sabtu'}
 local months={'Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'}
 text(cr,56,150,os.date('%H:%M'),128,p.cream,true)
 text(cr,64,200,days[tonumber(os.date('%w'))+1]..', '..tonumber(os.date('%d'))..' '..months[tonumber(os.date('%m'))]..' '..os.date('%Y'),26,p.amber,true)
 text(cr,64,234,'Malang  ·  '..d.temperature..'°C  ·  '..title(d.weather),16,p.cream)
 sun(cr,d)
 divider(cr,412)
 meter(cr,456,'CPU',d.cpu)
 meter(cr,494,'RAM',d.ram)
 meter(cr,532,'SSD',d.disk)
 divider(cr,566)
 row(cr,604,'Memori tersedia',d.ram_available..' GiB')
 row(cr,634,'Zram',d.zram..' / '..d.zram_total..' GiB')
 row(cr,664,'Zram di RAM',d.zram_physical..' MiB')
 row(cr,694,'Swap SSD',d.ssd_swap..' / '..d.ssd_swap_total..' GiB')
 row(cr,724,'SSD kosong',d.disk_free..' GiB')
 row(cr,754,'Suhu CPU',d.cpu_temp..'°C')
 row(cr,784,'Menyala',d.uptime)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
