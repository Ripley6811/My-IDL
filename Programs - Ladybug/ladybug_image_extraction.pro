@movie_io

;ATTENTION:Make sure movie_io.pro is compiled first 
;          before running this program

;PROGRAMMED BY:Jay Johnson

;STEPS:
;   1) SELECT FIRST AVI OF SERIES
;   2) SELECT GPS ASCII FILE
;   3) INPUT INTERVAL IN METERS OF IMAGE EXTRACTION AT COMMAND LINE
;   4) SELECT LOCATION AND NAME FOR IMAGE SERIES



;--------------------------------------------------------
;RETURNS THE NEXT FILENAME OF AVI SERIES
function get_next_filename, filename, currNumber

length = STRLEN(filename)
vidNumber = STRMID(filename, length-8, 4)

nextVidNumber = STRTRIM(LONG(currNumber),1)
print, vidNumber, ' skip to ', nextVidNumber

STRPUT, filename, nextVidNumber, length-4-STRLEN(nextVidNumber)


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
;----------------------------------------------------------
pro ladybug_image_extraction


DEVICE,DEC=1   ; For true-color


;SELECT *.AVI LADYBUG VIDEO FILE
vidname = DIALOG_PICKFILE(TITLE='Select AVI file (first of series)', FILTER='*.avi')
avi_id = AVI_OPENR(vidname,r,g,b)
print, 'avi_id:', avi_id
framesPerAVI = avi_id[3]    ;Should be the same number of frames in each AVI of sequence
AVI_CLOSER, avi_id


;SELECT CORRESPONDING FRAME/GPS DATA FILE
filename = DIALOG_PICKFILE(TITLE='Select GPS data file')
lineCount = FILE_LINES(filename)
print, 'lineCount=', strtrim(lineCount,1) 
OPENR, 1, filename


;INPUT INTERVAL DISTANCE IN METERS
interval = 10  ;default 10 meters (?)
READ, interval, PROMPT='Enter interval in whole number meters: '
PRINT, 'INTERVAL SET TO ', interval, ' meters.'


;CREATE ARRAY OF COORDINATES INDEXED BY FRAME NUMBER
coordArray = dblarr(2,lineCount)
for i=0, lineCount-1 do begin
  line = ''
  READF, 1, line
;  print, line
  if STRLEN(line) gt 50 then begin
    frame = FIX(STRMID(line, 0, 6))  ;STRMID(Expression, First_Character [, Length] [, /REVERSE_OFFSET])
    coordArray[0,frame] = DOUBLE(STRMID(line, STRPOS(line,'LAT')+4, 11))
    coordArray[1,frame] = DOUBLE(STRMID(line, STRPOS(line,'LON')+4, 12))
;    print, frame, FORMAT='(D)', coordArray[0,frame], coordArray[1,frame]
  endif
endfor
CLOSE, 1


;CREATE ARRAY TO MATCH FRAME TO CORRESPONDING AVI SERIES NUMBER
;AN ARRAY OF NUMBERS THAT REPEAT MODULUS TOTAL FRAMES IN ONE FILE
aviIndex = intarr(lineCount)
for i=0, lineCount-1 do begin
   aviIndex[i] = i mod framesPerAVI
endfor


;CREATE ARRAY OF TARGET FRAME NUMBERS FOR IMAGE EXTRACTION
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
  distF = calc_dist_cos(lastCoord, coordArray[*,i])
  
  if FINITE(distF) and abs(distF) gt 0 then begin ;20km/hr at least 2m/s
    distanceAcu += distF
    lastCoord = coordArray[*,i]
;    print, 'dist=', distanceAcu
  endif
  if distanceAcu ge interval then begin
    distanceAcu = 0.0
;    print, 'Frame ', strtrim(i,1), ' selected'
    tgt_frame_array[tgtCount] = i
    tgtCount += 1
  endif
endfor

print, 'Selected frames:', tgt_frame_array[0:tgtCount-1]  ; tgtCount-1


;EXTRACT SELECTED FRAMES AND SAVE AS IMAGES
saveName = DIALOG_PICKFILE(TITLE='Create a name for image series')
currVidNumber = 0

avi_id = AVI_OPENR(vidname,r,g,b)
writeCount = 0
for i=0, tgtCount-2 do begin
  if (tgt_frame_array[i]/framesPerAVI) gt currVidNumber then begin
    AVI_CLOSER, avi_id
    currVidNumber = tgt_frame_array[i]/framesPerAVI
    avi_id = AVI_OPENR(get_next_filename(vidname,currVidNumber),r,g,b)
  endif
  imageN = avi_get(avi_id, (tgt_frame_array[i] mod framesPerAVI))
  print, Strtrim(currVidNumber,1), tgt_frame_array[i], framesPerAVI, tgt_frame_array[i] mod framesPerAVI
  

  WRITE_TIFF, saveName + string(tgt_frame_array[i]) + '.tif', reverse(imageN,3), orientation=2
  writeCount += 1
  OPENW, 1, saveName + string(tgt_frame_array[i]) + '.tfw'
  PRINTF, 1, double(0.0)
  PRINTF, 1, double(0.0)
  PRINTF, 1, double(0.0)
  PRINTF, 1, double(0.0)
  PRINTF, 1, FORMAT='(D)', coordArray[1,tgt_frame_array[i]]
  PRINTF, 1, FORMAT='(D)', coordArray[0,tgt_frame_array[i]]
  CLOSE, 1

endfor
help, coordArray
openw, 1, saveName + 'gps.txt'
for i=0, tgtCount-2 do printf, 1, FORMAT='( D, ";", D )', coordArray[0,tgt_frame_array[i]],  coordArray[1,tgt_frame_array[i]]
close, 1
for i=1, tgtCount-2 do begin
  print, calc_dist_cos(coordArray[*,tgt_frame_array[i-1]], coordArray[*,tgt_frame_array[i]])
endfor
;print, size(tgt_frame_array[0:tgtCount-2])


end;pro