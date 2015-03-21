;Programmed by Jay Johnson

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