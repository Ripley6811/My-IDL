pro ladybug_DMA  ;Data Manipulation App

;SELECT GPS LOG FILE
filename = dialog_pickfile(title='select data file')
;filename = 'F:\ENVI-IDL\Ladybug Programs\ladybug_frame_gps_info_6982.txt'


;USE FUNCTION TO GET DATA STRUCTURE
data = get_log_array(filename)


;DISPLAY SOME GRAPHS
;window,0, xsize=1000, ysize=800
;plot, data.lon, data.lat, yrange=[24.52,24.58], xrange=[121.83,121.87], psym=3
;plot, data.seqid, data.lon, yrange=[121.83,121.87], psym=3
;plot, data.seqid, data.lat, yrange=[24.52,24.59], psym=3
window,2
plot, data.lon, data.lat, yrange=[24.531,24.532], xrange=[121.863,121.866], psym=1, /NODATA


;CREATE ARRAY OF NEW GPS READINGS (SKIP REPETITIONS)
print, data.lon[0:100]
data = ladybug_interp_data(data)
print, data.lon[0:100]



;PLOT OF NEW GPS READINGS OVER ORIGINAL USING DIAMONDS
wset, 2
oplot, data.lon, data.lat, psym=4, color='FF0000'x


oplot, data.Lon, data.Lat, psym=3


;MAKE SHAPEFILE
;make_shp, filename, data, interpLon, interpLat, interpAlt
;make_shp, strMid(filename,0,strlen(filename)-4) + 'old', data.lon, data.lat, data.alt

;CALCULATE BEARING AND CREATE ARRAY
bearing = dblarr(size(data.seqid,/N_ELEMENTS))
for i=0, size(data.seqid,/N_ELEMENTS)-2 do begin
   bearing[i] = get_bearing(interpLat[i],interpLon[i],interpLat[i+1],interpLon[i+1])
   if bearing[i] lt 0.0 then bearing[i] = bearing[i] + 360.0
   
end
;PRINT, BEARING[0:1000]
window,4,xsize=1800

plot, data.seqid, bearing, psym=3, xrange=[14000,19000]

find_frame_by_coord, data, 24.538830, 121.866513
find_frame_by_coord, data, 24.539851, 121.866936
find_frame_by_coord, data, 24.58150464, 121.861185
end;pro