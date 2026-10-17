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
local function data()
 local d={};local f=io.open(home..'/.cache/conky-garuda-orbit/metrics.txt')
 if f then for l in f:lines() do local k,v=l:match('^([^=]+)=(.*)$');if k then d[k]=v end end;f:close()end
 return setmetatable(d,{__index=function()return '--'end})
end
local function metric(cr,x,label,value,h)
 text(cr,x,37,label,13,p.gold,true);text(cr,x+53,37,value,20,h,true)
end
-- A time-of-day illustration, not an astronomical Moon ephemeris.
local function daycycle(cr,d)
 local day=rawget(d,'solar_phase')=='day'
 local progress=tonumber(rawget(d,'clock_progress'))
 local current=tonumber(rawget(d,'curve_now'))
 local values={}
 for v in (rawget(d,'curve_points') or ''):gmatch('[^,]+') do
  local n=tonumber(v);if n then values[#values+1]=n end
 end
 -- Old or missing collector output: wait for valid curve data instead of inventing a position.
 if not progress or not current or #values~=97 then
  text(cr,57,500,'SIKLUS BELUM TERSEDIA',11,p.muted);return
 end
 progress=math.max(0,math.min(1,progress))
 local left,width,horizon,amplitude=65,282,503,45
 local function segment(finish)
  cairo_new_path(cr)
  for i=0,96 do
   local f=i/96
   if f>finish then break end
   local x,y=left+f*width,horizon-values[i+1]*amplitude
   if i==0 then cairo_move_to(cr,x,y) else cairo_line_to(cr,x,y) end
  end
  if finish<1 then cairo_line_to(cr,left+finish*width,horizon-current*amplitude) end
  cairo_stroke(cr)
 end
 color(cr,p.muted,.4);cairo_set_line_width(cr,.7)
 cairo_move_to(cr,left,horizon);cairo_line_to(cr,left+width,horizon);cairo_stroke(cr)
 for i=0,4 do
  local x=left+width*i/4
  cairo_move_to(cr,x,horizon-3);cairo_line_to(cr,x,horizon+3);cairo_stroke(cr)
  text(cr,x-6,545,string.format('%02d',i*6),10,p.muted)
  color(cr,p.muted,.4)
 end
 color(cr,p.gold,.23);cairo_set_line_width(cr,1.2);segment(1)
 color(cr,p.gold,.95);cairo_set_line_width(cr,1.6);segment(progress)
 local x,y=left+progress*width,horizon-current*amplitude
 if day then
  color(cr,p.gold);cairo_new_path(cr);cairo_arc(cr,x,y,5,0,2*math.pi);cairo_fill(cr)
  for i=0,7 do
   local angle=i*math.pi/4
   cairo_move_to(cr,x+8*math.cos(angle),y+8*math.sin(angle))
   cairo_line_to(cr,x+11*math.cos(angle),y+11*math.sin(angle));cairo_stroke(cr)
  end
 else
  -- Cut the crescent inside a group so the wallpaper remains transparent.
  cairo_save(cr);cairo_push_group(cr);color(cr,p.ivory)
  cairo_new_path(cr);cairo_arc(cr,x,y,8,0,2*math.pi);cairo_fill(cr)
  cairo_set_operator(cr,CAIRO_OPERATOR_DEST_OUT);cairo_set_source_rgba(cr,0,0,0,1)
  cairo_new_path(cr);cairo_arc(cr,x+4,y-3,7,0,2*math.pi);cairo_fill(cr)
  cairo_set_operator(cr,CAIRO_OPERATOR_OVER);cairo_pop_group_to_source(cr);cairo_paint(cr);cairo_restore(cr)
 end
 local estimated=rawget(d,'solar_source')~='open-meteo'
 if estimated then text(cr,180,445,'ESTIMASI',10,p.muted) end
 local rise=rawget(d,'sunrise_label') or '--.--'
 local setting=rawget(d,'sunset_label') or '--.--'
 text(cr,57,490,'TERBIT '..rise,10,p.muted)
 text(cr,265,490,'TERBENAM '..setting,10,p.muted)

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
 -- Reference layout: large clock, vertical weekday, date/month/weather beside it.
 pixels(cr,54,78,os.date('%H:%M'),14,p.red)
 local days={'MIN','SEN','SEL','RAB','KAM','JUM','SAB'}
 local months={'JAN','FEB','MAR','APR','MEI','JUN','JUL','AGU','SEP','OKT','NOV','DES'}
 local day=days[tonumber(os.date('%w'))+1]
 for i=1,3 do text(cr,58,250+(i-1)*63,day:sub(i,i),35,p.jade,true)end
 pixels(cr,158,213,os.date('%d'),9,p.red)
 text(cr,159,320,months[tonumber(os.date('%m'))],36,p.jade,true)
 text(cr,159,379,d.temperature..'°C',34,p.jade,true)
 text(cr,57,423,'MALANG / '..d.weather,12,p.muted)
 daycycle(cr,d)
 cairo_save(cr);cairo_translate(cr,0,100)
 line(cr,57,459,355,459)
 text(cr,57,492,'MEMORI TERSEDIA',12,p.gold)
 text(cr,57,524,d.ram_available..' GiB',24,p.ivory,true)
 text(cr,57,567,'ZRAM',12,p.jade,true)
 text(cr,180,567,d.zram..' / '..d.zram_total..' GiB',13,p.ivory)
 text(cr,57,599,'SWAP SSD',12,p.red,true)
 text(cr,180,599,d.ssd_swap..' / '..d.ssd_swap_total..' GiB',13,p.ivory)
 text(cr,57,629,'ZRAM DI RAM  '..d.zram_physical..' MiB',11,p.muted)
 line(cr,57,657,355,657)
 text(cr,57,691,'PENYIMPANAN KOSONG',12,p.gold)
 text(cr,57,723,d.disk_free..' GiB',24,p.ivory,true)
 text(cr,57,767,'SUHU CPU  '..d.cpu_temp..'°C',12,p.jade)
 cairo_restore(cr)
 cairo_destroy(cr);cairo_surface_destroy(cs)
end
