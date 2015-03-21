;CHANGED: May 3, 2011
;----------------------------------------------------------
;SPHERICAL LAW OF COSINES
function calc_dist_cos, lat1, lon1, lat2, lon2

R = 6371.0d; // km
;acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2) * cos(lon2-lon1)) * R;
d = acos(sin(lat1 * !dpi/180)*sin(lat2 * !dpi/180) + cos(lat1 * !dpi/180)*cos(lat2 * !dpi/180) * cos(lon2 * !dpi/180-lon1 * !dpi/180)) * R;
;help, d
if FINITE(d) then return, (d * 1000) ;convert km to meters
return, 0.0

end;function calc_dist
;----------------------------------------------------------
;Set FRAME to the variable that will hold the index number of matching frame
pro find_frame_by_coord, log, lat, lon, frame=frame, dist=dist

matchDist = 1000.0d
match = 0ll
for i=0ll, size(log.seqid,/N_ELEMENTS)-1 do begin
;print,i
  thisMatch = calc_dist_cos(log.lat[i],log.lon[i],lat,lon)
  if thisMatch lt matchDist then begin
    match = i
    matchDist = thisMatch
  end
end

print, 'Closest match at frame <', strtrim(match,1), '> with distance of ', strtrim(matchDist,1), ' meters' 
frame = match
dist = matchDist

end