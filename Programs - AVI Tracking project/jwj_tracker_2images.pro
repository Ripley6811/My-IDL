
;-----------------------------------------------------------
;INPUT: (4) Image1, Image2, Sampling(skip size), Threshold(jump size)
;OUTPUT: byte array showing location matches to sampling
;function RUN_SANDWICH_SEARCH2, image1, image2, sampskip, threshjump
;
;end
;-----------------------------------------------------------
;-----------------------------------------------------------
;INPUT: (4) Image1, x coord, y coord, Threshold(jump size)
;OUTPUT: byte array showing location matches to sampling
function RUN_SANDWICH_SEARCH2_BITMAP, image1, image2, x, y, threshjump
sized = size(image1, /DIMENSIONS)
help, image1
output = bytarr(2, sized[1], sized[2])

;SEARCH2D() ???

for i=0, sized[1]-1 do begin
  for j=0, sized[2]-1 do begin
    if image1[0,x,y] + threshjump ge image1[0,i,j] and $
       image1[0,x,y] - threshjump le image1[0,i,j] and $
       image1[1,x,y] + threshjump ge image1[1,i,j] and $
       image1[1,x,y] - threshjump le image1[1,i,j] and $
       image1[2,x,y] + threshjump ge image1[2,i,j] and $
       image1[2,x,y] - threshjump le image1[2,i,j] then output[0,i,j] = 1
  endfor
endfor 
for i=0, sized[1]-1 do begin
  for j=0, sized[2]-1 do begin
    if image1[0,x,y] + threshjump ge image2[0,i,j] and $
       image1[0,x,y] - threshjump le image2[0,i,j] and $
       image1[1,x,y] + threshjump ge image2[1,i,j] and $
       image1[1,x,y] - threshjump le image2[1,i,j] and $
       image1[2,x,y] + threshjump ge image2[2,i,j] and $
       image1[2,x,y] - threshjump le image2[2,i,j] then output[1,i,j] = 1
  endfor
endfor 

return, output

end


;-----------------------------------------------------------;-----------------------------------------------------------

function RUN_SANDWICH_SEARCH1, image1, image2, coordx, coordy, blockx, blocky, thresh





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
   FOR i=0, 300 DO IF abs(i-coordx) lt 50 then BEGIN
     FOR j=0, 500 DO IF abs(j-coordy) lt 50 then BEGIN
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

pro JWJ_tracker_2images
DEVICE,DEC=1   ; For true-color


image1 = read_png('H:\Ladybug3\NCKU_Steps_GPS_Test_Video\car1.png',r,g,b)
image2 = read_png('H:\Ladybug3\NCKU_Steps_GPS_Test_Video\car2.png',r,g,b)

sized = size(image1, /DIMENSIONS)
print, sized
;;;;;;;;;;;;;;;;;;;Variance block search
;SET THE COORDINATES IN FIRST FRAME ALONG WITH SIZE AND THRESHOLD OF THE SEARCH BLOCK
;coordx = 93   ;starting corner of block
;coordy = 235  ;starting corner of block 
blockx = 1   ;width of block
blocky = 1   ;height of block
thresh = 60   ;+- video color variance range between frames
x = 200
y = 185


window,0, xsize=3*sized[1], ysize=sized[2]
tv, image1/3, 0, 0,/TRUE
tv, image2/3, sized[1], 0,/TRUE



car1m = RUN_SANDWICH_SEARCH2_BITMAP( image1, image2, x, y, thresh)

;DILATE MASK
radius = 2
dims = SIZE(car1m[0,*,*], /DIMENSION)
strucElem = SHIFT(DIST(2*radius+1), radius, radius) LE radius
dilateImg = REPLICATE(0B, dims[1]+2, dims[2]+2) 
;print, dilateImg
car1mbit = replicate(car1m[0,*,*],1)
dilateImg [1,1] = car1mbit
print, dilateImg
help, dilateImg
help, car1mbit
dilateImg = DILATE(dilateImg, strucElem, /GRAY) 

;print, dilateImg

;car1morph = DILATE(car1m, REPLICATE(1,3,3)) 

;
;tvscl, car1m[0,*,*]
;plots, [x, x], [y-10, y+10], /DEVICE , COLOR=255
;plots, [x-10, x+10], [y, y], /DEVICE , COLOR=255
;tvscl, car1morph[1,*,*], sized[1]*2, 0
;plots, [x + sized[1]*2, x + sized[1]*2], [y-10, y+10], /DEVICE , COLOR=255
;plots, [x-10 + sized[1]*2, x+10 + sized[1]*2], [y, y], /DEVICE , COLOR=255
;
FOR i=0, sized[1]-1 DO BEGIN
  FOR j=0, sized[2]-1 DO BEGIN
;      newCoord = RUN_SANDWICH_SEARCH1( image1, image2, i, j, blockx, blocky, thresh )
;      if max(newCoord) ge 0 then begin
;         PLOTS, [i, i, i, i, i], [j, j + blocky/2 -1, j + blocky/2 +1, j + blocky/2 +1, j + blocky/2 -1], /DEVICE, COLOR=200
         if car1m[0,i,j] gt 0 then PLOTS, [i, i], [j, j], /DEVICE , COLOR=255*255
         if car1m[1,i,j] gt 0 then PLOTS, [i + sized[1], i + sized[1]], [j, j], /DEVICE , COLOR=255*255
         if dilateImg[i,j] gt 0 then PLOTS, [i + sized[1]*2, i + sized[1]*2], [j, j], /DEVICE , COLOR=255*255

  endfor
endfor

;TVSCL, dilateImg, 2 
end