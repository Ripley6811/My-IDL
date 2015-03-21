;CHANGED: May 3, 2011
;INPUT
;OUTPUT: info structure
;          seqid = sequence ID number  (long)
;          lat = latitude  (double)
;          lon = longitude  (double)
;          alt = altitude  (double)
;          utc = utc time  (str)
function get_log_array, filename
   dataCount = (query_ladybug_gps_log(filename))[1]
   
   frame = lonarr(dataCount)
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

        frame[count] = (STRSPLIT(str, ',', /EXTRACT))[0]
      
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
      frame:frame,  $
      seqid:seqid,  $
      lat:lat,  $
      lon:lon,  $
      alt:alt,  $
      utc:utc  $    
   }
   RETURN, info
end