function ladybug_interp_data, data


for i=size(data.lon,/N_ELEMENTS)-1,1,-1 do $
   if data.lon[i] eq data.lon[i-1] then data.lon[i] = 1000.0
select = where(data.lon lt 999.0, count)


;data.Lon = SPLINE(data.seqid[select],data.lon[select],data.seqid,4)
;data.Lat = SPLINE(data.seqid[select],data.lat[select],data.seqid,4)
data.Alt = SPLINE(data.seqid[select],data.alt[select],data.seqid,4)
data.lon = SPL_INTERP(data.seqid[select],data.lon[select],SPL_INIT(data.seqid[select],data.lon[select],/DOUBLE),data.seqid)
data.Lat = SPL_INTERP(data.seqid[select],data.lat[select],SPL_INIT(data.seqid[select],data.lat[select],/DOUBLE),data.seqid)


return, data
end