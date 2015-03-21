;Programmed by Jay Johnson


;This contains four conversion functions

;byte4toDouble:  Converts an 8-byte array to a double.  (first 4 divided by second set of 4)
;      for use in altering hex data in a EXIF file
;DoubletoByte4:  Converts a double number into a 4-byte array

;DMStoDegrees:  Converts Degrees,Minutes,Seconds to a Degrees double value

;DegreestoDMS:  Converts a Degrees double value to Degrees,Minutes,Seconds double array



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