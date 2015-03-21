;PROGRAMMED BY:Jay Johnson

;BEFORE RUNNING PROGRAM: Create a folder with jpeg image series and gps data log
;INPUT:
;   1) SELECT GPS ASCII FILE
;   2) INPUT INTERVAL IN METERS OF IMAGE EXTRACTION AT COMMAND LINE
;   3) SELECT FIRST IMAGE OF SERIES

;OUTPUT: text file listing frame number and respective coordinates

;A subdirectory called 'Selected' is created and all selected images are first
;   updated with new GPS data and then moved to this folder





;--------------------------------------------------------------------------------------
;INPUT: image filename, double array length 3 (lat, lon, alt)
;OUTPUT: None

;DESCRIPTION: This program replaces the GPS coordinate data of a LadybugCapPro produced jpeg image

;WARNING: The jpeg must already have pre-existing GPS info.
;   This program 'replaces GPS data', it does not 'add' data.

function DoubletoByte4, numb
   bytout = bytarr(4)
   bytout[0] = numb / long(256)^3
   bytout[1] = (numb - long(256)^3*bytout[0]) / long(256)^2
   bytout[2] = (numb - long(256)^3*bytout[0] - long(256)^2*bytout[1]) / 256
   bytout[3] = (numb - long(256)^3*bytout[0] - long(256)^2*bytout[1] - 256*bytout[2])
   
   return, bytout
end


function DegreestoDMS, dd
   outputArr = dblarr(3)
   outputArr[0] = fix(dd)
   outputArr[1] = fix(60*(dd-outputArr[0]))
   outputArr[2] = 60*((60*(dd-outputArr[0]))-outputArr[1])
   
   return, outputArr
end
   
pro ladybug_overwrite_jpegGPS, filename, latlonalt
  
    ;--------  Open Image file  ------------
    OPENR,lun,Filename,/get_lun

    ;--------------------------------------------------------------
    ; Check for and read Exif data
    ; JPEG uses Markers to indicate pieces
    ; of data.  Every JPEg file starts with the
    ; Marker SOI (start of Image) which is the
    ; 2 bytes 255,216 = FF,D8
    ; Markers FFE0 to FFEF are "Application Markers" (=APPn)
    ; used by applications but not needed to decode JPEG.
    ; Digital Cameras use the EXIF data structure
    ; with marker FFE1=APP1 (older cameras used JFIF with
    ; marker FFE0=APP0).
    ; So the APP1 marker is FFE0.  The length in bytes
    ; of the APP1 data follows in the next 2 bytes (including
    ; the 2 length bytes).  Next the APP1 data itself follows.
    ; The APP1 data (EXIF data) may be thousands of bytes long.
    ;--------------------------------------------------------------
    buff = BYTARR(283)      ; App data buffer size.
    READU,lun,buff         ; All the EXIF data, many bytes.
    FREE_LUN, lun

    gps_start = 227
    

    sigdig = 7 ;significant digits for lat lon
    
    
    newlat = DegreestoDMS(latlonalt[0])
    newlon = DegreestoDMS(latlonalt[1])
    newalt = latlonalt[2]
;    print, newlat, newlon, newalt
    
    buff[gps_start+ 3] = byte(newlat[0])
    buff[gps_start+11] = byte(newlat[1])
    buff[gps_start+16:gps_start+19] = DoubletoByte4(newlat[2]*long(10)^(sigdig))
    buff[gps_start+20:gps_start+23] = DoubletoByte4(long(10)^(sigdig))
    buff[gps_start+27] = byte(newlon[0])
    buff[gps_start+35] = byte(newlon[1])
    buff[gps_start+40:gps_start+43] = DoubletoByte4(newlon[2]*long(10)^(sigdig))
    buff[gps_start+44:gps_start+47] = DoubletoByte4(long(10)^(sigdig))
    buff[gps_start+48:gps_start+51] = DoubletoByte4(newalt*long(10)^(3)) ;alt set to 3 significant digits
    buff[gps_start+52:gps_start+55] = DoubletoByte4(long(10)^(3))
    
    
    ;PRINT OUT GPS BYTE ARRAY
;    for i=0, 6 do begin
;      print, buff[gps_start + i*8: gps_start + i*8 + 7]
;    endfor
    
    ;--------  Open Image for writing  ------------
    OPENU,lun,Filename,/get_lun
    
    WRITEU,lun,buff         ; All the EXIF data, many bytes.
    CLOSE, lun
end
;----------------------------------------------------------------------------
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
;-----------------------------------------------------------------------
function query_ladybug_gps_log, filename
   output = LON64ARR(6)

   OPENR, unit, filename, /GET_LUN 
   str = '' 
   count = 0ll
   countErr = 0ll
   WHILE ~ EOF(unit) DO BEGIN 
      READF, unit, str 
      
      if count eq 0 then begin
        output[3] = SIZE(STRSPLIT(str, ','),/N_ELEMENTS)
        seqidStartPos = STRPOS(str,'SEQID')
        seqidEndPos = STRPOS(str,',',seqidStartPos)
        output[4] = LONG64(STRMID(str, seqidStartPos+6, seqidEndPos-(seqidStartPos+6)))
      endif
      
      if STRLEN(str) lt 50 then countErr = countErr + 1
      
      count = count + 1 
   ENDWHILE 
   output[0] = count
   output[1] = count - countErr
   output[2] = countErr
   seqidStartPos = STRPOS(str,'SEQID')
   seqidEndPos = STRPOS(str,',',seqidStartPos)
   output[5] = LONG64(STRMID(str, seqidStartPos+6, seqidEndPos-(seqidStartPos+6)))
   
   FREE_LUN, unit 
   RETURN, output
end
;-----------------------------------------------------------------------
function get_log_array, filename
   dataCount = (query_ladybug_gps_log(filename))[1]
   
   seqid = lonarr(dataCount)
   lat = dblarr(dataCount)
   lon = dblarr(dataCount)
   alt = dblarr(dataCount)
   utc = strarr(dataCount)

   OPENR, unit, filename, /GET_LUN 
   str = '' 
   count = 0ll
   WHILE ~ EOF(unit) DO BEGIN 
      READF, unit, str 
      
      if SIZE(STRSPLIT(str, ','),/N_ELEMENTS) gt 5 then begin  ;Skip error lines
        seqidStartPos = STRPOS(str,'SEQID')
        seqidEndPos = STRPOS(str,',',seqidStartPos)
        seqid[count] = LONG(STRMID(str, seqidStartPos+6, seqidEndPos-(seqidStartPos+6)))
        
        lat[count] = DOUBLE(STRMID(str, STRPOS(str,'LAT')+4, 11))
        lon[count] = DOUBLE(STRMID(str, STRPOS(str,'LON')+4, 12))
        alt[count] = DOUBLE(STRMID(str, STRPOS(str,'ALT')+4, 7))
        
        utc[count] = STRMID(str, STRPOS(str,'UTC')+4)
         
        count = count + 1
      endif      
   ENDWHILE    
   FREE_LUN, unit 
   
   info = {$
      seqid:seqid,  $
      lat:lat,  $
      lon:lon,  $
      alt:alt,  $
      utc:utc  $    
   }
   RETURN, info
end
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
pro ladybug_image_series_selector


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