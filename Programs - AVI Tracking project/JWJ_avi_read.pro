@movie_io

;Taken from avi_test.pro
;Edited by Jay W Johnson


PRO AVI_READ  ; Example that shows how to read true-color images from AVI

;DEVICE,DEC=0   ; For indexed image

DEVICE,DEC=1   ; For true-color

avi_id=AVI_OPENR(PICKFILE(),r,g,b)

PRINT, avi_id   ; avi_id is [bpp, xsize, ysize, nframes, ...some internal info]
nframes= avi_id(3)
help, avi_id

;;;;;;;;;;;;;;;;;;;Variance block search
;SET THE COORDINATES IN FIRST IMAGE ALONG WITH SIZE AND THRESHOLD OF THE SEARCH BLOCK
coordx = 250   ;starting corner of block
coordy = 235  ;starting corner of block 
blockx = 30   ;width of block
blocky = 30   ;height of block
thresh = 30   ;+- video color variance range widening value


;GET A FEW FRAMES FROM THE VIDEO
image10 = avi_get(avi_id, 10)
image11 = avi_get(avi_id, 11)
image12 = avi_get(avi_id, 12)

imageBlock = image10[*,coordx:(coordx+blockx-1),coordy:(coordy+blocky-1)]
imageBlockHigh = bytarr(3,blockx,blocky)
imageBlockLow  = bytarr(3,blockx,blocky) + 255
imageBack = bytarr(3,blockx+2,blocky+2)
imageBack[0,*,*] = imageBack[0,*,*] + 255
imageBackG = bytarr(3,blockx+2,blocky+2)
imageBackG[1,*,*] = imageBack[1,*,*] + 255



;SET UP THE HIGH AND LOW PASS MATRIXES
FOR b=0, 2 DO BEGIN
  FOR i=0, (blockx-2) DO BEGIN
    FOR j=0, (blocky-2) DO BEGIN
      imageBlockHigh[b,i,j] = max(imageBlock[b,i:i+1,j:j+1]) > imageBlockHigh[b,i,j]
      imageBlockHigh[b,i+1,j] = max(imageBlock[b,i:i+1,j:j+1]) > imageBlockHigh[b,i+1,j]
      imageBlockHigh[b,i,j+1] = max(imageBlock[b,i:i+1,j:j+1]) > imageBlockHigh[b,i,j+1]
      imageBlockHigh[b,i+1,j+1] = max(imageBlock[b,i:i+1,j:j+1]) > imageBlockHigh[b,i+1,j+1]
      imageBlockLow[b,i,j] = min(imageBlock[b,i:i+1,j:j+1]) < imageBlockLow[b,i,j]
      imageBlockLow[b,i+1,j] = min(imageBlock[b,i:i+1,j:j+1]) < imageBlockLow[b,i+1,j]
      imageBlockLow[b,i,j+1] = min(imageBlock[b,i:i+1,j:j+1]) < imageBlockLow[b,i,j+1]
      imageBlockLow[b,i+1,j+1] = min(imageBlock[b,i:i+1,j:j+1]) < imageBlockLow[b,i+1,j+1]
    endfor
  endfor
endfor


;PRINT THE HIGH AND LOW PASS MATRIXES
;print, 'high', imageBlockHigh
;help, imageBlockHigh
;print, 'low', imageBlockLow
;help, imageBlockLow


;SHOW THE SEARCH BLOCK AND THE HIGH AND LOW PASS IMAGES IN THE BOTTOM CORNER
window,0
tv, image11, /TRUE
window,1
tv, image11, /TRUE
tv, imageBlock, /TRUE
tvscl, imageBlockHigh, blockx+1, blocky+1, /true
tvscl, imageBlockLow, blockx+1, 0, /true
tv, imageBackG, coordx-1, coordy-1, /true


;SEARCH ENTIRE IMAGE OF THE NEXT FRAME FOR MATCHES AND PRINT OUT RESULTS
count = 0
FOR tt=thresh, 0, -1 DO BEGIN
   print, tt, '=thresh'
   FOR i=0, avi_id(1)-blockx DO BEGIN
     FOR j=0, avi_id(2)-blocky DO BEGIN
       found = 1
       bandsMatch = 0
       FOR b=0, 2 DO BEGIN
          FOR ii=0, (blockx-1) DO BEGIN
            FOR jj=0, (blocky-1) DO BEGIN
             if image11[b,i+ii,j+jj] le imageBlockHigh[b,ii,jj] + tt and $
                image11[b,i+ii,j+jj] ge imageBlockLow[b,ii,jj] - tt then begin
               if ii eq (blockx-1) and jj eq (blocky-1) and found eq 1 then begin
                 bandsMatch = bandsMatch+1
               endif
             endif else found = 0 
             if found eq 0 then break
           endfor;jj
           if found eq 0 then break
         endfor;ii
         if found eq 0 then break
       endfor;b
       if bandsMatch gt 0 then begin
           print, ++count, ') Found at (',i,',',j,')', i-coordx, '=dx', j-coordy, '=dy', bandsMatch, '=bands matching'
           tv, imageBack, i-1, j-1, /true
           tv, imageBlock, i, j, /TRUE
       endif
    endfor;j
  endfor;i
endfor;tt



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;CAN I DO SOMETHING LIKE THIS??
;FOR i=0, avi_id(1)-12 DO BEGIN
;  FOR j=0, avi_id(2)-5 DO BEGIN
;    if image11[0,i:i+11,j:j+4] le imageBlockHigh[0,*,*] then begin
;      if image11[0,i:i+11,j:j+4] ge imageBlockLow[0,*,*] then begin
;            print, 'Found at (',i,',',j,')'
;;            window, 2
;;            tv, image11[
;      endif
;    endif
;  endfor
;endfor




;;;;;;;;;;;Difference on two contiguous images

;image10 = avi_get(avi_id, 10)
;image11 = avi_get(avi_id, 11)
;image12 = avi_get(avi_id, 12)
;
;window,1
;tv, abs(image11-image10), /TRUE
;window,2
;tv, abs(image12-image11), /TRUE
;
;
;for i=0, 255 DO BEGIN
;  image10 = image10 mod 10
;endfor
;
;
;result = DIALOG_WRITE_IMAGE(image10-image11)



;;;;;;;;;;;;;;;;;;;;;Make image from a vertical line position from all frames

;image = bytarr(3,avi_id(3),avi_id(2))
;
;FOR i=0, nframes-1 DO BEGIN
;  imageTemp = avi_get(avi_id, i)
;  help, imageTemp
;  image(*,i,*) = imageTemp(1:3,200,*)
;endfor
;
;window, 1
;TV, image, /TRUE
;
;band = 0
;frame0 = 0
;frameEnd = 30
;vary = 0
;FOR i=0, avi_id(2)-1 DO BEGIN
;  pixMax = MAX(image(band,frame0:frameEnd,i)) & pixMin = MIN(image(band,frame0:frameEnd,i))
;  print, 'Y=', i, '  ', pixMax, '/', pixMin, '  D=', pixMax-pixMin 
;  vary = pixMax-pixMin > vary
;endfor 
;print, vary  ;largest variance of all lines


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;;Make image from lowest and highest values
;imageMin = avi_get(avi_id, 0)
;imageMax = avi_get(avi_id, 0)
;
;FOR i=1L, nframes-1 DO BEGIN
;  imageF = avi_get(avi_id, i)
;  FOR j=0L, avi_id(1) - 1 DO BEGIN
;    FOR k=0L, avi_id(2) - 1 DO BEGIN
;      FOR band=0, 2 DO BEGIN
;        if imageF(band, j, k) lt imageMin(band, j, k) then imageMin(band, j, k) = imageF(band, j, k)
;        if imageF(band, j, k) gt imageMax(band, j, k) then imageMax(band, j, k) = imageF(band, j, k)
;      endfor
;    endfor
;  endfor
;endfor
;
;window, 1
;TV, imageMax, /TRUE
;window, 2
;TV, imageMin, /TRUE
;window, 3
;TV, imageMax - imageMin, /TRUE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;







;;;;;;;;;;;;;;;;;Sample pixel test
;pixel1xy = [100,100]
;pixel1 = bytarr(nframes)
;pixel2xy = [200,200]
;pixel2 = bytarr(nframes)
;pixel3xy = [300,300]
;pixel3 = bytarr(nframes)
;pixel4xy = [400,400]
;pixel4 = bytarr(nframes)
;
;help, pixel1
;
;FOR i=0, nframes-1 DO BEGIN
;  image = avi_get(avi_id, i)
;  pixel1[i] = image[0,pixel1xy[0],pixel1xy[1]]
;  pixel2[i] = image[0,pixel2xy[0],pixel2xy[1]]
;  pixel3[i] = image[0,pixel3xy[0],pixel3xy[1]]
;  pixel4[i] = image[0,pixel4xy[0],pixel4xy[1]]
;endfor
;print, pixel1
;print, pixel2
;print, pixel3
;print, pixel4
;
;print, 'Max=', max(pixel1), '  Min=', min(pixel1), '  Range=', max(pixel1)-min(pixel1)
;print, 'Max=', max(pixel2), '  Min=', min(pixel2), '  Range=', max(pixel2)-min(pixel2)
;print, 'Max=', max(pixel3), '  Min=', min(pixel3), '  Range=', max(pixel3)-min(pixel3)
;print, 'Max=', max(pixel4), '  Min=', min(pixel4), '  Range=', max(pixel4)-min(pixel4)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;Averaging all frames
;imageAve = LONG(avi_get(avi_id, 0))
;FOR i=1, nframes-1 DO BEGIN
;  imageAve += LONG(avi_get(avi_id, i))
;endfor
;imageAve /= nframes
;window, 2
;TV, imageAve, /TRUE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;image3 = LONG(avi_get(avi_id, 3))
;image4 = LONG(avi_get(avi_id, 33))
;image5 = LONG(avi_get(avi_id, 63))
;image6 = LONG(avi_get(avi_id, 93))
;image7 = LONG(avi_get(avi_id, 123))
;image8 = LONG(avi_get(avi_id, 153))
;image9 = LONG(avi_get(avi_id, 183))
;image10 = LONG(avi_get(avi_id, 213))
;image11 = LONG(avi_get(avi_id, 243))
;image12 = LONG(avi_get(avi_id, 273))
;image13 = LONG(avi_get(avi_id, 303))
;image14 = LONG(avi_get(avi_id, 333))
;help, image10
;image43 = (image3+image4)/2
;imageAve = (image3+image4+image5+image6+image7+image8+image9+image10+image11+image12+image13+image14)/12
;window, 1
;TV, image3, /TRUE
;window, 2
;TV, imageAve, /TRUE


;;USE XINTERANIMATE TO DISPLAY FRAMES AND SAVE AS .MPG
;XINTERANIMATE, SET=[avi_id(1),avi_id(2),nframes], /SHOWLOAD
;PRINT,SYSTIME()   ; for speed test
;FOR i=0, nframes-1 DO BEGIN
; data=AVI_GET(avi_id, i+0)   ; read true-color data from AVI
; TV, data, /TRUE
;
; ;data=COLOR_QUAN(data,1,r,g,b) ; Quantization to indexed colors
; ;TVLCT,r,g,b ; Loading color tables after quantization
; ;TV, data ; Showing indexed image
;
; XINTERANIMATE, FRAME=i, WINDOW=!d.window
;ENDFOR
;PRINT,SYSTIME()
;AVI_CLOSER, avi_id   ; close our AVI file
;XINTERANIMATE
;data=0
END