









function crop_ASCAT_location, data, lon_bounds=lon_bounds, lat_bounds=lat_bounds

n = N_ELEMENTS(data.lon)

c = 0 ; count

for i=0l, n-1 do begin
   print, data.lon[i]
   if data.lon[i] ge lon_bounds[0] and data.lon[i] le lon_bounds[1] $
      and data.lat[i] ge lat_bounds[0] and data.lat[i] le lat_bounds[1] $
         then c += 1
end

indices = where( data.lon ge lon_bounds[0] and data.lon le lon_bounds[1] $
      and data.lat ge lat_bounds[0] and data.lat le lat_bounds[1], count )

print, 'count ', count, '/', n
print, 'c ', c

return, { $
   lon:data.lon[indices], $
   lat:data.lat[indices], $
   time:data.time[indices], $
   ssws:data.ssws[indices], $
   sswd:data.sswd[indices] $
   }


end