;CREATED: May 5, 2011

;PURPOSE: separate good matches from bad matches produces by SIFT

;INPUT: SIFT output, pairs of coordinates

;OUTPUT: List of good matches
;        List of bad matches


function request_data, filename
; filename = dialog_pickfile(title=title, filter = ['*.pts'])
;filename = 'H:\ladybug_Rectified_1616x1232_00000029_Cam2.pgm_Warp.pts'

 lines = file_lines(filename) 
 print, strtrim(lines,2), " lines of data found in ", filename, "."
 x0 = fltarr(lines)
 y0 = fltarr(lines)
 x1 = fltarr(lines)
 y1 = fltarr(lines)
 dx = fltarr(lines)
 dy = fltarr(lines)

 OPENR, unit, filename, /GET_LUN 
 str = '' 
 count = 0ll
; READF, unit, str ; skip first line
 WHILE ~ EOF(unit) DO BEGIN 
    READF, unit, str 
    strTokens = strsplit(str, ' ', count=c, /EXTRACT)
    
    if c eq 4 then begin
      x0[count] = strTokens[0]
      y0[count] = strTokens[1]
      x1[count] = strTokens[2]
      y1[count] = strTokens[3]
      dx[count] = x1[count]-x0[count]
      dy[count] = y1[count]-y0[count]
      
      count = count + 1
    end
         
 ENDWHILE    
 FREE_LUN, unit 
 
 ;DELETE ZERO SETS
 if count lt lines then begin
      x0 = x0[0:count-1]
      y0 = y0[0:count-1]
      x1 = x1[0:count-1]
      y1 = y1[0:count-1]
      dx = dx[0:count-1]
      dy = dy[0:count-1]
 end

 data = { x0:x0 , y0:y0 , x1:x1 , y1:y1 , dx:dx , dy:dy }
 
 return, data
end
;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

PRO run_sift, Base_fname, Warp_fname, VMimage, win , Band;win = [x, y, dx, dy]
;GET THE CROPPED JPEG IMAGE DIMENSIONS
result = query_jpeg(Base_fname, jpg)
jpg_xsize = jpg.dimensions[0]
jpg_ysize = jpg.dimensions[1]

;CREATE NAME FOR PTS SAVE FILE, BASED ON BASE IMAGE NAME
Pts_fname = Base_fname
Pts_fname = file_dirname(Pts_fname, /mark_directory) + file_basename( Pts_fname, 'bmp')
Pts_fname = file_dirname(Pts_fname, /mark_directory) + file_basename( Pts_fname, 'pgm')
Pts_fname = file_dirname(Pts_fname, /mark_directory) + file_basename( Pts_fname, 'jpg') + 'pts'


;~~~~RUN SIFT~~~~
minwin = 40
if N_ELEMENTS(win) ne 0 then begin
;   win0 = [win[0] - minwin, $
;           win[0] + minwin, $
;           win[1] - minwin, $
;           win[1] + minwin]
;   win1 = [win[0] + win[2] - minwin, $
;           win[0] + win[2] + minwin, $
;           win[1] + win[3] - minwin, $
;           win[1] + win[3] + minwin]
;   This code expands the window by the dx and dy amount
   win0 = [win[0] - minwin - abs(win[2]), $
           win[0] + minwin + abs(win[2]), $
           win[1] - minwin - abs(win[3]), $
           win[1] + minwin + abs(win[3])]
   win1 = [win[0] + win[2] - minwin - abs(win[2]), $
           win[0] + win[2] + minwin + abs(win[2]), $
           win[1] + win[3] - minwin - abs(win[3]), $
           win[1] + win[3] + minwin + abs(win[3])]
   if win0[0] lt 0 then win0[0] = 0
   if win0[1] ge jpg_xsize then win0[1] = jpg_xsize-1
   if win0[2] lt 0 then win0[2] = 0
   if win0[3] ge jpg_ysize then win0[3] = jpg_ysize-1
   if win1[0] lt 0 then win1[0] = 0
   if win1[1] ge jpg_xsize then win1[1] = jpg_xsize-1
   if win1[2] lt 0 then win1[2] = 0
   if win1[3] ge jpg_ysize then win1[3] = jpg_ysize-1
   data = SIFT(Base_fname, Warp_fname, win0, win1, band)
endif else begin
   if FILE_TEST(Pts_fname) then data = request_data(Pts_fname) $
   else data = SIFT(Base_fname, Warp_fname, /writePTSfile)
;   Pts_fname = dialog_pickfile(title='Pick large *.pts file')
endelse
if data.dx[0] eq 10000 then return ;Exit if no data was returned from SIFT




;~~CHECK IF THERE ARE NEIGHBORING SIMILAR VECTORS
if N_ELEMENTS(win) eq 0 then thresh = 4 $ ;how far off an acceptable vector is
else thresh = 3
    ;maybe this depends on resolution. More important than 'check' number
check = 400  ;How many neighbors to check for similar vector
    ;this seems like it can be a large number if the 'thresh' is small
if N_ELEMENTS(win) eq 0 then min_match = 4 $  ;How many neighbors must match to accept the vector
else min_match = 3
    ;2 at the very least.  The higher this number, the more reliable the results.
    
;RETRIEVE MATCH DATA FROM PTS FILE
;data = request_data(Pts_fname)
data_length = N_ELEMENTS(data.x0)
if data_length le min_match then return        ; if only one match then skip it
is_good = bytarr(data_length) * 0


if check gt data_length then check = data_length-1
for i=0, data_length-1 do begin
   ;find the closest vector origins by sorting
  origDist = FLTARR(data_length)
  origDist = sqrt((data.x0 - data.x0[i])^2 + (data.y0 - data.y0[i])^2)
  indexes = (sort(origDist))[1:check]  ;don't include the ith vector (itself)

   ;skip those vectors with the same origin.  (no confirming with itself)
  startcheckat = 0
  for j=0, check-1 do if origDist[indexes[j]] lt 1.0 then startcheckat = j+1

   ;count how many other vectors nearby have the similar x y components
   ;Later, can change this from a square thresh to circular thresh
  indexfit = where(data.dx[indexes[startcheckat:*]] gt data.dx[i] - thresh $
               and data.dx[indexes[startcheckat:*]] lt data.dx[i] + thresh $
               and data.dy[indexes[startcheckat:*]] gt data.dy[i] - thresh $
               and data.dy[indexes[startcheckat:*]] lt data.dy[i] + thresh $
               , count)
  if count ge min_match then is_good[i] = 1


end

;PRINT RESULTS FROM SIFTING THROUGH VECTORS
print, 'Good points: ' + strtrim(fix(total(is_good)),2) + ' / ' + strtrim(data_length,2) + '   (' + strtrim(100*fix(total(is_good))/data_length,2) + '%)'



;~~DISPLAY IMAGE WITH VECTORS
print, base_fname
base_fname = file_dirname(Base_fname, /mark_directory) + file_basename( base_fname, 'bmp')
base_fname = file_dirname(Base_fname, /mark_directory) + file_basename( base_fname, 'pgm')
base_fname = file_dirname(Base_fname, /mark_directory) + file_basename( base_fname, 'jpg') + 'jpg'
print, base_fname
READ_JPEG, base_fname, image0
;READ_JPEG, 'I:\ladybug_Rectified_1616x1232_00000001_Cam4.jpg', image1
xsize=N_ELEMENTS(image0[0,*,0])
ysize=N_ELEMENTS(image0[0,0,*])
window, 3, xsize=xsize, ysize=ysize
tv, image0, true=1
;stop

for i=0, data_length-1 do begin
  if is_good[i] then plots, data.x0[i], ysize-data.y0[i], /DEVICE, psym=4, symsize=0.6, color='1100FF'x;, /NORMAL
  if is_good[i] then plots, [data.x0[i],data.x1[i]], [ysize-data.y0[i],ysize-data.y1[i]], /DEVICE, color='AF00FF'x;, psym=3;, /NORMAL


  ;Write good points to image-like file  [3,xsize,ysize]
      ;layer 0 = dx
      ;layer 1 = dy
      ;layer 2 = magnitude
  ;WRITE TO vector_image ARRAY
  if is_good[i] and VMimage[2,data.x0[i],data.y0[i]] lt 0 then begin
    if N_ELEMENTS(win) eq 0 then begin
      print, count
      print, 'Running window on: (' + strtrim(data.x0[i],2) + ',' + strtrim(data.y0[i],2) + ')'
      vectormap = [data.x0[i], jpg_ysize-data.y0[i], VMimage[0,data.x0[i],data.y0[i]], 0 - VMimage[1,data.x0[i],data.y0[i]]]
;      run_sift, Base_fname, Warp_fname, VMimage, vectormap
;      run_sift, Base_fname, Warp_fname, VMimage, vectormap, [1.0,0.0,0.0]
;      run_sift, Base_fname, Warp_fname, VMimage, vectormap, [0.0,1.0,0.0]
;      run_sift, Base_fname, Warp_fname, VMimage, vectormap, [0.0,0.0,1.0]
    end
    VMimage[0,data.x0[i],data.y0[i]] = FLOAT(data.x1[i] - data.x0[i])
    VMimage[1,data.x0[i],data.y0[i]] = FLOAT(data.y1[i] - data.y0[i])
    VMimage[2,data.x0[i],data.y0[i]] = FLOAT(sqrt((data.x1[i] - data.x0[i])^2 + (data.y1[i] - data.y0[i])^2))
  end 
  
endfor


end; run_sift

;==================================================================================

pro sift_SIFT
T = systime(/SECONDS)
dir = 'H:\'
;REQUEST INPUT BMPS, TWO IMAGES IN SEQUENTIAL ORDER
Base_fname = envi_pickfile(title= 'Choose Base Image', filter = ['*.bmp', '*.jpg'])
Warp_fname = envi_pickfile(title= 'Choose Warp Image', filter = ['*.bmp', '*.jpg'])

;CROP AND CONVERT BMP TO JPG
Extension = strmid(Base_fname, 2, /reverse_offset)
if Extension eq 'bmp' then bmp2jpg, Base_fname
Extension = strmid(Warp_fname, 2, /reverse_offset)
if Extension eq 'bmp' then bmp2jpg, Warp_fname


;GET CROPPED IMAGE DIMENSIONS
result = query_jpeg(Base_fname, jpg)
jpg_xsize = jpg.dimensions[0]
jpg_ysize = jpg.dimensions[1]

;OPEN vector_image if it exists
VMimage = fltarr(3, jpg_xsize, jpg_ysize)
VMimage[2,*,*] = VMimage[2,*,*] - 1.0
vector_fname = file_dirname(Base_fname, /mark_directory) + file_basename( base_fname, '.jpg') + 'VM.tif'
if QUERY_TIFF(vector_fname) then VMimage = READ_TIFF( vector_fname )




;RUN SIFT AND WRITE GOOD RESULTS TO VMimage ARRAY
run_sift, Base_fname, Warp_fname, VMimage




;SAVE vector_image
window, 1, xsize=jpg_xsize, ysize=jpg_ysize
;tvscl, VMimage[2,*,*], 0, 0, 1, /ORDER
tvscl, VMimage[2,*,*], /ORDER
;print, VMimage[where(VMimage ne 0)]
WRITE_TIFF, vector_fname, VMimage, /FLOAT
print, 'Energy:', total(VMimage[2,*,*])
print, 'Max mag:', max(VMimage[2,*,*])
result = where( VMimage[2,*,*] ge 0.0 , count )
print, strtrim(count,2) + '/' + strtrim((jpg_xsize * jpg_ysize),2) + '  ' + strtrim(100 * count / (jpg_xsize * jpg_ysize), 2) + '%'


   ;Interp:  0=Linear  1=Quintic
;krig = KRIG2D(reform(VMimage[2,*,*]))
;tvscl, krig

print, 'Minutes ', (systime(/SECONDS)-T)/60.0
end