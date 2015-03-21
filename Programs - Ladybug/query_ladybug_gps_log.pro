;INPUT: filename (location) of ladybug gps log
;OUTPUT: 64-bit Long array
;            0 - total lines
;            1 - total frames with data (from first field)
;            2 - total error lines
;            3 - number of fields per line
;            4 - sequence ID start number
;            5 - sequence ID end number
;                  '5'-'4' != '1'-1  because error lines represent more than 1


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