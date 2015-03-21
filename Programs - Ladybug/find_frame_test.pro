;CREATED: May 3, 2011
;OUTPUT A LIST THAT FINDS THE RELATED IMAGES FROM TWO LOG FILES
;Recommend picking the shorter log first, but not necessary (loop based on first log length)
;          (I can pick the shorter one within the program)

pro find_frame_test

log1 = ladybug_interp_data(get_log_array("H:\Data - Ladybug3\20101210 - Suhua - PGR original\ladybug_frame_gps_info_6982.txt"))
log2 = ladybug_interp_data(get_log_array("H:\Data - Ladybug3\20110422 - Suhua - PGR original\ladybug_frame_gps_info_25936.txt"))
make_shp, DIALOG_PICKFILE(), log1
make_shp, DIALOG_PICKFILE(), log2

saveName = DIALOG_PICKFILE(TITLE='Enter save file name')
openw, 1, saveName

length = N_ELEMENTS(log1.lat)
for i=0, length-1 do begin

  find_frame_by_coord, log2, log1.lat[i], log1.lon[i], frame=frame_number, dist=distance
  printf, 1, log1.frame[i], frame_number, distance
  
end
close, 1



end