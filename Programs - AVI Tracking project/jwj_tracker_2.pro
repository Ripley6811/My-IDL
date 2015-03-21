@movie_io







;-----------------------------------------------------------

function RUN_SANDWICH_SEARCH, avi_id, frame, coordx, coordy, blockx, blocky, thresh




;GET A FEW FRAMES FROM THE VIDEO
image1 = avi_get(avi_id, frame)
image2 = avi_get(avi_id, frame+1)
;image3 = avi_get(avi_id, frame+2)

imageBlock = image1[*,coordx:(coordx+blockx-1),coordy:(coordy+blocky-1)]
imageBlockHigh = bytarr(3,blockx,blocky)
imageBlockLow  = bytarr(3,blockx,blocky) + 255
imageBack = bytarr(3,blockx+2,blocky+2)
imageBack[0,*,*] = imageBack[0,*,*] + 255
imageBackG = bytarr(3,blockx+2,blocky+2)
imageBackG[1,*,*] = imageBack[1,*,*] + 255



;SET UP THE HIGH AND LOW PASS MATRIXES BY DILATING THE HIGH AND LOW VALUES
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

if max(imageBlockHigh) eq 0 then return, -1
if min(imageBlockLow) eq 255 then return, -1


;PRINT THE HIGH AND LOW PASS MATRIXES
;print, 'high', imageBlockHigh
;help, imageBlockHigh
;print, 'low', imageBlockLow
;help, imageBlockLow


;SHOW THE SEARCH BLOCK AND THE HIGH AND LOW PASS IMAGES IN THE BOTTOM CORNER
;window,0
;tv, image2, /TRUE
;window,1
;tv, image2, /TRUE
;tv, imageBlock, /TRUE
;tvscl, imageBlockHigh, blockx+1, blocky+1, /true
;tvscl, imageBlockLow, blockx+1, 0, /true
;tv, imageBackG, coordx-1, coordy-1, /true


;SEARCH WITHIN 200 PIXEL DISTANCE OF THE NEXT FRAME FOR MATCHES AND PRINT OUT RESULTS
count = 0
outputCoord = bytarr(2)
FOR tt=0, thresh DO BEGIN
   ttContinue = 0
   print, tt, '=thresh'
   outputCoord = [-10,-10]
   FOR i=0, avi_id(1)-blockx DO IF abs(i-coordx) lt 50 then BEGIN
     FOR j=0, avi_id(2)-blocky DO IF abs(j-coordy) lt 50 then BEGIN
       found = 1
       bandsMatch = 0
       FOR b=0, 2 DO BEGIN
          FOR ii=0, (blockx-1) DO BEGIN
            FOR jj=0, (blocky-1) DO BEGIN
             if image2[b,i+ii,j+jj] le imageBlockHigh[b,ii,jj] + tt and $
                image2[b,i+ii,j+jj] ge imageBlockLow[b,ii,jj] - tt then begin
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
       if bandsMatch gt 1 then begin
           print, ++count, ') Found at (',i,',',j,')', i-coordx, '=dx', j-coordy, '=dy', bandsMatch, '=bands matching'
;           tv, imageBack, i-1, j-1, /true
;           tv, imageBlock, i, j, /TRUE
           if abs(i-coordx) lt abs(outputCoord[0]-coordx) and $
              abs(j-coordy) lt abs(outputCoord[1]-coordy) then $
              outputCoord[0] = i & outputCoord[1] = j
           if count ge 20 then ttContinue = 1
       endif
       if ttContinue eq 1 then break
    endif;j
    if ttContinue eq 1 then break
  endif;i
  if ttContinue eq 1 then break
endfor;tt

return, outputCoord

end


;-----------------------------------------------------------

pro JWJ_tracker_2
DEVICE,DEC=1   ; For true-color

avi_id=AVI_OPENR(PICKFILE(),r,g,b)
frame = 600


PRINT, avi_id   ; avi_id is [bpp, xsize, ysize, nframes, ...some internal info]
nframes= avi_id(3)
help, avi_id

;;;;;;;;;;;;;;;;;;;Variance block search
;SET THE COORDINATES IN FIRST FRAME ALONG WITH SIZE AND THRESHOLD OF THE SEARCH BLOCK
;coordx = 93   ;starting corner of block
;coordy = 235  ;starting corner of block 
blockx = 30   ;width of block
blocky = 30   ;height of block
thresh = 30   ;+- video color variance range widening value



window,0
tv, avi_get(avi_id, frame), /TRUE
PLOTS, [0,0], [20,20], /DEVICE , COLOR=255



FOR i=0, avi_id(1)-blockx-1, blockx DO BEGIN
  FOR j=0, avi_id(2)-blocky-1, blocky DO BEGIN
      newCoord = RUN_SANDWICH_SEARCH( avi_id, frame, i, j, blockx, blocky, thresh )
      if max(newCoord) ge 0 then begin
         PLOTS, [i + blockx/2 -1, i + blockx/2 +1, i + blockx/2 +1, i + blockx/2 -1, i + blockx/2 -1], [j + blocky/2 -1, j + blocky/2 -1, j + blocky/2 +1, j + blocky/2 +1, j + blocky/2 -1], /DEVICE, COLOR=200
         PLOTS, [i + blockx/2, newCoord[0] + blockx/2], [j + blocky/2, newCoord[1] + blocky/2], /DEVICE , COLOR=255
      endif
  endfor
endfor

end