function endian
   if fix([0B,1B],0) eq 1 then f=1 else f=0
   return, f
end

function byte4toDouble, buffer, index
   num =    double(buffer[index])*256*256*256 $
          + double(buffer[index+1])*256*256 $
          + double(buffer[index+2])*256 $
          + double(buffer[index+3])
   div =    double(buffer[index+4])*256*256*256 $
          + double(buffer[index+5])*256*256 $
          + double(buffer[index+6])*256 $
          + double(buffer[index+7])
   
   return, (num/div)
end
function DoubletoByte4, numb
   bytout = bytarr(4)
   bytout[0] = numb / long(256)^3
   bytout[1] = (numb - long(256)^3*bytout[0]) / long(256)^2
   bytout[2] = (numb - long(256)^3*bytout[0] - long(256)^2*bytout[1]) / 256
   bytout[3] = (numb - long(256)^3*bytout[0] - long(256)^2*bytout[1] - 256*bytout[2])
   
   return, bytout
end

;   0   0   0  23   0   0   0   1
;   0   0   0   0   0   0   0   1
;   0   7  87 116   0   1 134 160
;   0   0   0 120   0   0   0   1
;   0   0   0  15   0   0   0   1
;   0  87 180 108   0   1 134 160
;   0   0 131  64   0   0   3 232


function DMStoDegrees, dd, mm, ss   
   return, dd + (mm*60 + ss)/3600
end
function DegreestoDMS, dd
   outputArr = dblarr(3)
   outputArr[0] = fix(dd)
   outputArr[1] = fix(60*(dd-outputArr[0]))
   outputArr[2] = 60*((60*(dd-outputArr[0]))-outputArr[1])
   
   return, outputArr
end
   
pro write_gps_test

;SELECT image FILE
;filename = dialog_pickfile(title='select image file')
filename = 'K:\ENVI-IDL\Ladybug Programs\ladybug_panoramic_000004.jpg'
;filename = 'K:\ENVI-IDL\Ladybug Programs\DSC00564.jpg'


    ;------------  Init  ---------------------
    hend = ENDIAN()        ; Host endian (current computer).
    eflag = 1-hend         ; JPEG file values are big endian.
    Elev = 0.        ; F-number as rational.
    dt_tm = ''       ; Date/Time of original.
    
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
    gps_array = dblarr(7)
    
    for i=0, 6 do begin
      gps_array[i] =  byte4toDouble(buff,gps_start + i*8)
    endfor
    print, gps_array

    lat =  DMStoDegrees(gps_array[0], gps_array[1], gps_array[2])
    print, lat, format='(d)'
    lon = DMStoDegrees(gps_array[3], gps_array[4], gps_array[5])
    print, lon, format='(d)'
    print, gps_array[6]
    print, DegreestoDMS(lat)
    print, DegreestoDMS(lon)


    print, 'Changing this ', buff[gps_start:gps_start+7]
    buff[gps_start+3]=byte(22)
    print, 'Into this ', buff[gps_start:gps_start+7]


    sigdig = 7 ;significant digits
    temparr = DoubletoByte4((DegreestoDMS(lon))[2]*long(10)^(sigdig))
    print, temparr
    tempdiv = DoubletoByte4(long(10)^(sigdig))
    print, tempdiv
    print, byte4toDouble([temparr,tempdiv] ,0)
    
    ;--------  Open Image file  ------------
;    OPENU,lun,Filename,/get_lun
;    
;    WRITEU,lun,buff         ; All the EXIF data, many bytes.
;    CLOSE, lun
end