;PROGRAMMED BY:Jay Johnson

;STEPS:
;         [[1) SELECT FIRST IMAGE OF SERIES]](not written yet)
;   2) SELECT GPS ASCII FILE
;   3) INPUT INTERVAL IN METERS OF IMAGE EXTRACTION AT COMMAND LINE
;   4) SELECT LOCATION AND NAME FOR FRAME LIST

;INPUT: ladybug gps file, interval between images (meters)

;OUTPUT: text file listing frame number and respective coordinates


;--------------------------------------------------------
;RETURNS THE FILENAME OF IMAGE FROM INDEX NUMBER
function get_filename, filename, index

length = STRLEN(filename)

;replace the image number with index number
STRPUT, filename, strtrim(index,1), length-4-STRLEN(strtrim(index,1))

;RETURN NEW FILENAME STRING
if FILE_TEST(filename) then return, filename
;ELSE
return, 'NA'
end;function get_next_filename
;----------------------------------------------------------
;SPHERICAL LAW OF COSINES
function calc_dist_cos, latlon1, latlon2

R = 6371.0d; // km
;acos(sin(lat1)*sin(lat2) + cos(lat1)*cos(lat2) * cos(lon2-lon1)) * R;
d = acos(sin(latlon1[0] * !dpi/180)*sin(latlon2[0] * !dpi/180) + cos(latlon1[0] * !dpi/180)*cos(latlon2[0] * !dpi/180) * cos(latlon2[1] * !dpi/180-latlon1[1] * !dpi/180)) * R;

return, (d * 1000) ;convert km to meters

end;function calc_dist
;----------------------------------------------------------
;HAVERSINE FORMULA
;function calc_dist_haversine, lat1, lon1, lat2, lon2
;NOT WRITTEN YET
;----------------------------------------------------------
pro ladybug_image_selector


;SELECT CORRESPONDING FRAME/GPS DATA FILE
filename = DIALOG_PICKFILE(TITLE='Select GPS data file')
lineCount = FILE_LINES(filename)
print, 'lineCount=', strtrim(lineCount,1) 


;INPUT INTERVAL DISTANCE IN METERS
interval = 10  ;default 10 meters (?)
READ, interval, PROMPT='Enter interval in whole number meters: '
PRINT, 'INTERVAL SET TO ', interval, ' meters.'


;CREATE ARRAY OF COORDINATES INDEXED BY FRAME NUMBER
data = get_log_array(filename)
data = ladybug_interp_data(data)
lineCount = size(data.seqid,/N_ELEMENTS)
coordArray = dblarr(2,lineCount)
coordArray[0,*] = data.lat
coordArray[1,*] = data.lon


;CREATE ARRAY OF TARGET FRAME NUMBERS
tgt_frame_array = lonarr(lineCount) -1   ;preset all to -1
distanceAcu = 0.0 ;meters acumulater
help, distanceAcu
lastCoord = coordArray[*,0]  ;first comparison to first frame
lastFrameCoord = coordArray[*,0]  ;coord of last frame extract
              ;for distance comparison to next frame extract
help, lastCoord
tgt_frame_array[0] = 0   ;first frame is first position
tgtCount = 1

for i=1, lineCount-1 do begin
  ; skip frames with 0 lat 0 lon
  if coordArray[0,i] eq 0.0 then continue
  
  ; find distance traveled since last calculated frame
  distF = calc_dist_cos(lastCoord, coordArray[*,i])
  
  ; accumulate distance if greater than 0
  if FINITE(distF) and abs(distF) gt 0 then begin ;20km/hr at least 2m/s
    distanceAcu += distF
    lastCoord = coordArray[*,i]
;    print, 'dist=', distanceAcu
  endif
  ; if accumulated distance if greater than interval
  if distanceAcu ge interval then begin
    distanceAcu = 0.0
;    print, 'Frame ', strtrim(i,1), ' selected'
    tgt_frame_array[tgtCount] = i
    tgtCount += 1
  endif
endfor

print, 'Selected frames:', tgt_frame_array[0:tgtCount-1]  ; tgtCount-1

;OUTPUT SELECTED FRAMES IN TEXT FILE AND UPDATE GPS/ALT DATA OF SELECTED JPEG IMAGES
saveName = DIALOG_PICKFILE(TITLE='Select first jpeg image of series')
nameArr = strarr(tgtCount-1)
writeCount = 0
help, coordArray
FILE_MKDIR, file_dirname(saveName) + '\Selected'
openw, 1, file_dirname(saveName) + '\Selected\ImageSelectionList.txt'
for i=0, tgtCount-2 do begin
  printf, 1, FORMAT='( I, ";", D, ";", D )', tgt_frame_array[i], coordArray[0,tgt_frame_array[i]],  coordArray[1,tgt_frame_array[i]]
  nameArr[i] = "" + get_filename(savename, tgt_frame_array[i])
  ;replace the GPS data with interpolated coords
  ladybug_overwrite_jpegGPS, nameArr[i], [data.lat[tgt_frame_array[i]],data.lon[tgt_frame_array[i]],data.alt[tgt_frame_array[i]]]
endfor
close, 1


;MOVES SELECTED IMAGES INTO A SUBDIRECTORY CALLED 'SELECTED'
FILE_MOVE, nameArr, file_dirname(saveName) + '\Selected'
print, 'Selected images moved to ', file_dirname(saveName), '\Selected'


end;pro