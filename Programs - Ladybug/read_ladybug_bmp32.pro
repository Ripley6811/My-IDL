;CREATED: MAY 15, 2011

;PURPOSE: TO CONVERT THE 32-BIT BMP LADYBUG IMAGES TO 24-BIT BMP
;      LADYBUG 32-BIT IMAGE IS SIDEWAYS. THIS PROCESS OVERWRITES THIS IMAGE,
;      REPLACING IT WITH AN UPRIGHT 24-BIT BMP FILE.



function READ_LADYBUG_BMP32, filename, OVERWRITE=overwrite

if ~ FILE_TEST(filename) then filename = DIALOG_PICKFILE() 
OPENR,lun,Filename,/get_lun


fhdr = { BITMAPFILEHEADER, $
    bftype: bytarr(2), $        ;A two char string
    bfsize: 0L, $
    bfreserved1: 0, $
    bfreserved2: 0, $
    bfoffbits: 0L $
  }
readu, lun, fhdr           ;Read the bitmapfileheader
;print, fhdr



garbage = BYTARR(40)
READU,lun,garbage   ;UNUSED DATA



buff = BYTARR(7963648)      ; 1232 x 1616 x 4 = 7963648 bytes
READU,lun,buff   
CLOSE, /ALL

      
;CREATE IMAGE ARRAY
image = BYTARR(3,1232,1616)
count = 0ul
for j=0, 1231 do   for i=0, 1615 do   for b=0, 3 do begin
   if b ne 3 then image[b,j,i] = buff[count]
   count++
end

image = reverse(image,3)

if KEYWORD_SET(overwrite) then write_bmp, filename, image

return, image
END
