@movie_io

;This program was used to test the change in values over the length of a sedentary video

;-----------------------------------------------------------

pro peakit
DEVICE,DEC=1   ; For true-color

avi_id=AVI_OPENR(PICKFILE(),r,g,b)
frame = 50


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
image1 = avi_get(avi_id, frame)
tv, image1, /TRUE


image2 = image1

;Min initialized with high values and Max with low values
imageMin = bytarr(3,avi_id[1],avi_id[2]) + 255
imageMax = bytarr(3,avi_id[1],avi_id[2])
imageAve = ulonarr(3,avi_id[1],avi_id[2])
imageInit =  bytarr(3,avi_id[1],avi_id[2])
imageJmp =  bytarr(3,avi_id[1],avi_id[2])

;FOR i=0, avi_id(1)-1 DO BEGIN
;  FOR j=0, avi_id(2)-1 DO BEGIN
;      maxpix = max(image1[*,i,j])
;      minpix = min(image1[*,i,j])
;      FOR b = 0, 2 DO BEGIN
;        if image1[b,i,j] eq maxpix then image2[b,i,j] = 255
;        if image1[b,i,j] eq minpix then image2[b,i,j] = 0
;        if image1[b,i,j] lt maxpix and image1[b,i,j] gt minpix then image2[b,i,j] = 127
;      endfor
;  endfor
;endfor

;;OUTPUT PEAKED IMAGE
;window,2
;tv, image2, /TRUE


;FOR i=0, avi_id(1)-1 DO BEGIN
;  FOR j=0, avi_id(2)-1 DO BEGIN
;      FOR b = 0, 2 DO BEGIN
;        if image2[b,i,j] lt 255 then image2[b,i,j] = 0
;      endfor
;  endfor
;endfor

;OUTPUT PEAKED IMAGE
;window,3
;tv, image2, /TRUE
;
;image3 = dilate(image1, [1,1,1])
;;OUTPUT PEAKED IMAGE
;window,4
;image3[0,*,*] = image1[0,*,*]
;image3[1,*,*] = image1[0,*,*]
;image3[2,*,*] = image1[0,*,*]
;
;tv, image3, /TRUE


;for i=0, 10 do begin
;  image1 = avi_get(avi_id, frame + i)
;  image3[*,*,40*i:40*i + 39] = image1[*,*,230:269]
;
;endfor

count = 0
FOR fr=2, 50 DO BEGIN
  count = count + 1
  imtemp = avi_get(avi_id, fr)
  if fr eq 2 then imageInit = imtemp else imageInit = avi_get(avi_id, fr-1)
  tv, imtemp, /TRUE
  FOR i=0, avi_id(1)-1 DO BEGIN
    FOR j=0, avi_id(2)-1 DO BEGIN
      FOR b=0, 2 DO BEGIN
        if imtemp[b,i,j] gt imageMax[b,i,j] then imageMax[b,i,j] = imtemp[b,i,j]
        if imtemp[b,i,j] lt imageMin[b,i,j] then imageMin[b,i,j] = imtemp[b,i,j]
        imageAve[b,i,j] += imtemp[b,i,j]
        if abs(long(imageInit[b,i,j]) - long(imtemp[b,i,j])) gt imageJmp[b,i,j] then imageJmp[b,i,j] = abs(long(imageInit[b,i,j]) - long(imtemp[b,i,j]))
      endfor
    endfor
    print, i, '=column', systime()
  endfor
  print, fr, '=frame', systime() ;, i, '=x', j, '=y'
endfor
imageAve /= count
filename = dialog_pickfile(title='Save as...')
  WRITE_TIFF, filename + 'Min.tif', imageMin
  WRITE_TIFF, filename + 'Max.tif', imageMax
  WRITE_TIFF, filename + 'Ave.tif', imageAve
  WRITE_TIFF, filename + 'Rng.tif', imageMax-imageMin
  WRITE_TIFF, filename + 'Jmp.tif', imageJmp
end