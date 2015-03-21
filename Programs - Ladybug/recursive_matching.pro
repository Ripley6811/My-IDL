function get_vectors, vector_fname
   if QUERY_TIFF(vector_fname, tif) then VMimage = READ_TIFF( vector_fname ) $
   else VMimage = READ_TIFF( DIALOG_PICKFILE(title='Could not find VM.tif.  Please select it.') )

   arraysize = tif.dimensions[0] * tif.dimensions[1] / 100
   x = fltarr(arraysize)
   y = fltarr(arraysize)
   dx = fltarr(arraysize)
   dy = fltarr(arraysize)
   m = fltarr(arraysize)
   empty_slot = 0L
   for i=0, tif.dimensions[0]-1 do for j=0, tif.dimensions[1]-1 do begin
      if VMimage[2,i,j] ne -1 then begin
         x[empty_slot] = i
         y[empty_slot] = j
         dx[empty_slot] = VMimage[0,i,j]
         dy[empty_slot] = VMimage[1,i,j]
         m[empty_slot] = VMimage[2,i,j]
;         if m[empty_slot] lt 130 then 
empty_slot += 1   ; getting rid of a bad vector, maybe change later
      end
   end

   data = { $
      x:x[0:empty_slot-1], $
      y:y[0:empty_slot-1], $
      dx:dx[0:empty_slot-1], $
      dy:dy[0:empty_slot-1], $
      m:m[0:empty_slot-1] $
   }
   
   return, data
end
;------------------------------------------------------------------
;INPUT:
;   win = window boundary array [left, right, bottom, top]
;   h = height of original image, because vector coord origin is top left corner
;   data = structure containing all vectors
;OUTPUT:
;   an array of indexes that can be used to sort the data structure
function get_closest_vector, win, h, data, distance=distance
   x = (win[1]+win[0])/2
   y = h-(win[3]+win[2])/2
   closest = fltarr(N_ELEMENTS(data.x))
   for i=0l, N_ELEMENTS(data.x)-1 do closest[i] = sqrt((data.x[i]-x)^2 + (data.y[i]-y)^2)
   distance = closest(sort(closest))
   return, sort(closest)
end
;------------------------------------------------------------------
;INPUT:
;   vector = structure of vector data
;OUTPUT:
;   min boundaries, [left, right, bottom, top]
function get_boundary, w, h, data   ;w and h are the index of last elements
   bounds = [0, 0, 0, 0]   
   for i=0l, N_ELEMENTS(data.x)-1 do begin
      if data.dx[i] lt bounds[0] then bounds[0] = data.dx[i]
      if data.dx[i] gt bounds[1] then bounds[1] = data.dx[i]
      if data.dy[i] lt bounds[2] then bounds[2] = data.dy[i]
      if data.dy[i] gt bounds[3] then bounds[3] = data.dy[i]
;      print, i, data.m[i]
   end
   bounds = bounds * (-1)
   bounds[1] = bounds[1] + w
   bounds[3] = bounds[3] + h
   
   return, bounds
end
;------------------------------------------------------------------
;THIS IS THE MAIN RECURSIVE METHOD

;INPUT:
;   win = the window to fit into place
;   p_vec = the vector of the parent window fitting
;   vector = structure for all vectors
;   save_array = save matrix for pixel mapping
;   onto_array = shows if the pixel at target has already been mapped from base
;OUTPUT:

pro shift_and_match, image0, image1, win, p_vec, vector, save_array, onto_array
maxi_min = 15        ;The maximum value to accept when taking diff of images
col_min = 50         ;difference in absolute color to accept
vec_check = 500      ;How many vectors from list of neighbors to check
resolution = 0      ;pixel width of smallest window to match
seed = systime(1)
;print, 'p_vec', p_vec
;print, win
;stop

;FIND VECTORS CLOSEST TO CENTER
h = N_ELEMENTS(save_array[0,0,*])
order = get_closest_vector(win, h, vector, distance=distance)


;SHIFT WINDOW BY LIST OF VECTORS AND STORE BEST VALUE. 
;CHECK THE PARENT VECTOR FIRST.  IF BEST FIT THEN STORE TO ALL VALUES AND RETURN
maxi = max(abs(fix(image0[*,win[0]:win[1],win[2]:win[3]])-fix(image1[*,win[0]+p_vec[0]:win[1]+p_vec[0],win[2]+p_vec[1]:win[3]+p_vec[1]])))
if maxi le maxi_min then begin
   save_array[0,win[0]:win[1],win[2]:win[3]] = p_vec[0]
   save_array[1,win[0]:win[1],win[2]:win[3]] = p_vec[1]
   save_array[2,win[0]:win[1],win[2]:win[3]] = sqrt((float(p_vec[0]))^2 + (float(p_vec[1]))^2)
   return
end
if win[1]-win[0] le resolution or win[3]-win[2] eq 0 then begin
   save_array[0,win[0]:win[1],win[2]:win[3]] = p_vec[0]
   save_array[1,win[0]:win[1],win[2]:win[3]] = p_vec[1]
   save_array[2,win[0]:win[1],win[2]:win[3]] = sqrt((float(p_vec[0]))^2 + (float(p_vec[1]))^2)
   return
END


;CHOOSE BASE VECTOR TO TRY
if distance[0] lt win[3]-win[2] then passdown = [vector.dx[order[0]],vector.dy[order[0]]] $
else passdown = p_vec
;ELSE USE PARENT PASSDOWN


;METHOD 1
;low_tot = 10000000l
;low_tot_index = 0
;;PRINT, 'ENTERED'
;for i=0, vec_check-1 do begin
;   dx = fix(passdown[0] + randomn(seed) * 2)
;   dy = fix(-passdown[1] + randomn(seed) * 2)
;   toti = total(abs(fix(image0[*,win[0]:win[1],win[2]:win[3]])-fix(image1[*,win[0]+dx:win[1]+dx,win[2]+dy:win[3]+dy])))
;   
;
;   if toti lt low_tot then begin
;      print, 'closer found'
;      low_tot = toti
;      low_tot_index = i
;      p_vec2 = [dx,dy]
;   end
;;   print, dx, dy
;   tvscl, fix(image1), /true
;   tvscl, abs(bytscl(fix(image0[*,win[0]:win[1],win[2]:win[3]])-fix(image1[*,win[0]+dx:win[1]+dx,win[2]+dy:win[3]+dy]))), win[0]+dx, win[2]+dy, /true
;stop
;   ;PLOT A SQUARE AROUNG ROI
;;   plots, [win[0],win[1],win[1],win[0],win[0]], [win[2],win[2],win[3],win[3],win[2]], /CONTINUE, /DEVICE
;
;;   stop
;;   wait, 0.2
;end
;METHOD 1 END

;METHOD 2
low_tot = 10000000l
low_tot_index = 0
for i=0, vec_check-1 do begin
   dx = fix(vector.dx[order[i]])
   dy = -fix(vector.dy[order[i]])
   ;CHECK COLOR CLASS OF VECTOR. COMPARE COLOR WHERE THE VECTOR ORIGINATED TO THE ORIGIN OF APPLICATION
   ;USE ONLY THE VECTORS THAT DESCRIBE MOVEMENT OF SIMILARLY COLORED REGIONS
;   xxx = vector.x[i]
;   yyy = h-vector.y[i]
;   red0 = fix(mean(image0[0,xxx-1:xxx+1,yyy-1:yyy+1]))
;   gre0 = fix(mean(image0[1,xxx-1:xxx+1,yyy-1:yyy+1]))
;   blu0 = fix(mean(image0[2,xxx-1:xxx+1,yyy-1:yyy+1]))
;   xxx = (win[1]+win[0])/2
;   yyy = h-(win[3]+win[2])/2
;   red1 = fix(mean(image0[0,xxx-1:xxx+1,yyy-1:yyy+1]))
;   gre1 = fix(mean(image0[1,xxx-1:xxx+1,yyy-1:yyy+1]))
;   blu1 = fix(mean(image0[2,xxx-1:xxx+1,yyy-1:yyy+1]))
;   if abs(red1-red0) gt col_min or abs(gre1-gre0) gt col_min or abs(blu1-blu0) gt col_min then continue
;   print, red0, red1, gre0, gre1, blu0, blu1
   
   
   toti = total(abs(fix(image0[*,win[0]:win[1],win[2]:win[3]])-fix(image1[*,win[0]+dx:win[1]+dx,win[2]+dy:win[3]+dy])))

   if toti lt low_tot then begin
      low_tot = toti
      low_tot_index = i
   end
;   tvscl, fix(image1), /true
;   tvscl, abs(fix(image0[*,win[0]:win[1],win[2]:win[3]])-fix(image1[*,win[0]+dx:win[1]+dx,win[2]+dy:win[3]+dy])), win[0]+dx, win[2]+dy, /true

   ;PLOT A SQUARE AROUNG ROI
;   plots, [win[0],win[1],win[1],win[0],win[0]], [win[2],win[2],win[3],win[3],win[2]], /CONTINUE, /DEVICE
;   print, dx, dy
;   stop
;   wait, 1
end

;print, vector.m[order[low_tot_index]]
for i=low_tot_index, low_tot_index do begin
   dx = fix(vector.dx[order[i]])
   dy = -fix(vector.dy[order[i]])
;   tvscl, abs(fix(image0[*,win[0]:win[1],win[2]:win[3]])-fix(image1[*,win[0]+dx:win[1]+dx,win[2]+dy:win[3]+dy])), win[0]+dx, win[2]+dy, /true
;   print, 'Fitted at displacement of dx=' + strtrim(dx,2) + '  dy=' + strtrim(dy,2)
;   print, 'Toti = ', low_tot
   p_vec2 = [dx,dy]
;   stop
end
;METHOD TWO END

;MAKE SUBDIVISIONS. 4 SECTIONS: NW NE SE SW
nw_win = [win[0],(win[0]+win[1])/2,1+(win[2]+win[3])/2,win[3]]
ne_win = [1+(win[0]+win[1])/2,win[1],1+(win[2]+win[3])/2,win[3]]
se_win = [1+(win[0]+win[1])/2,win[1],win[2],(win[2]+win[3])/2]
sw_win = [win[0],(win[0]+win[1])/2,win[2],(win[2]+win[3])/2]
shift_and_match, image0, image1, nw_win, p_vec2, vector, save_array, onto_array
shift_and_match, image0, image1, ne_win, p_vec2, vector, save_array, onto_array
shift_and_match, image0, image1, se_win, p_vec2, vector, save_array, onto_array
shift_and_match, image0, image1, sw_win, p_vec2, vector, save_array, onto_array

;



end
;=================================================================================
pro recursive_matching
T = systime(/seconds)
print, T
dir = 'i:\work_area\'

;LOAD SEQUENTIAL IMAGES. IMAGE0 AND IMAGE1
if QUERY_JPEG( dir + 'ladybug_color_00000000_Cam4.jpg' ) then $
   image0_fname = dir + 'ladybug_color_00000000_Cam4.jpg' $
else image0_fname = DIALOG_PICKFILE(title='Select first jpeg')
if QUERY_JPEG( dir + 'ladybug_color_00000001_Cam4.jpg' ) then $
   image1_fname = dir + 'ladybug_color_00000001_Cam4.jpg' $
else image1_fname = DIALOG_PICKFILE(title='Select second jpeg')
READ_JPEG, image0_fname, image0
READ_JPEG, image1_fname, image1
result = QUERY_JPEG( image0_fname, jpg )
;STORE THE BOUNDARY INDEXES
w = jpg.dimensions[0]-1
h = jpg.dimensions[1]-1

;LOAD VECTOR LIST.  SIFT PRODUCE VECTORS THAT EXIST WITHIN THE IMAGE
;THE LIST OF VECTORS (PROBABLY) COVERS ALL POSSIBLE MOVEMENT FROM ONE IMAGE TO THE NEXT
vector = get_vectors( dir + 'ladybug_color_00000000_Cam4VM.tif' )

;CREATE A BORDER BASED ON THE LIST OF VECTORS
;THIS WILL BE THE PORTION OF THE ORIGINAL IMAGE THAT IS MAPPED TO THE SECOND IMAGE
b = get_boundary(w,h,vector)
extra_b = 20
b[0] = b[0]+extra_b
b[1] = b[1]-extra_b
b[2] = b[2]+extra_b
b[3] = b[3]-extra_b

;REDUCE DIFF VALUE OF FULL IMAGE
nw_win = [b[0],b[1]/2,1+b[3]/2,b[3]]
ne_win = [1+b[1]/2,b[1],1+b[3]/2,b[3]]
se_win = [1+b[1]/2,b[1],b[2],b[3]/2]
sw_win = [b[0],b[1]/2,b[2],b[3]/2]
;print, 'NW', nw_win
;print, 'NE', ne_win
;print, 'SE', se_win
;print, 'SW', sw_win



window, 3, xsize=500, ysize=500
plots, 250, 250, /DEVICE, psym=4, symsize=3, color='1100FF'x;, /NORMAL
plots, 250 + vector.dx, 250 - vector.dy, psym=3, /DEVICE


WINDOW, 11, xsize=w+1, ysize=h+1
tvscl, roberts(reform(image0[0,*,*]))
WINDOW, 12, xsize=w+1, ysize=h+1
tvscl, sobel(reform(image0[1,*,*]))
WINDOW, 13, xsize=w+1, ysize=h+1
tvscl, prewitt(reform(image0[2,*,*]))



order = get_closest_vector(sw_win, h, vector)
;print, vector.x[order[0]], vector.y[order[0]]
window, 0, xsize=w+1, ysize=h+1
tvscl, abs(fix(image0[0,*,*])-fix(image1[0,*,*]))
stop
;print, max(abs(fix(image0[0,*,*])-fix(image1[0,*,*])))
;print, total(abs(fix(image0[0,*,*])-fix(image1[0,*,*])))



s = -1
dx = 1
dy = 1
;print, 'ne', max(abs(fix(image0[0,0-s:w+s,0-s:h+s])-fix(image1[0,0-s+dx:w+s+dx,0-s+dy:h+s+dy])))
;print, total(abs(fix(image0[0,0-s:w+s,0-s:h+s])-fix(image1[0,0-s+dx:w+s+dx,0-s+dy:h+s+dy])))

low_max = 500
low_max_index = 0
low_tot = 10000000l
low_tot_index = 0
;for i=0, 20 do begin
;;   s = 0 - fix((abs(vector.dx[i]) gt abs(vector.dy[i])) ? abs(vector.dx[i]) : abs(vector.dy[i]))
;   dx = fix(vector.dx[i])
;   dy = -fix(vector.dy[i])
;   maxi = max(abs(fix(image0[0,b[0]:b[1],b[2]:b[3]])-fix(image1[0,b[0]+dx:b[1]+dx,b[2]+dy:b[3]+dy])))
;   toti = total(abs(fix(image0[0,b[0]:b[1],b[2]:b[3]])-fix(image1[0,b[0]+dx:b[1]+dx,b[2]+dy:b[3]+dy])))
;   if maxi lt low_max then begin
;      low_max = maxi
;      low_max_index = i
;   end
;   if toti lt low_tot then begin
;      low_tot = toti
;      low_tot_index = i
;   end
;   print, maxi
;   print, toti
;   tvscl, abs(fix(image0[0,b[0]:b[1],b[2]:b[3]])-fix(image1[0,b[0]+dx:b[1]+dx,b[2]+dy:b[3]+dy])), b[0], b[2]
;   
;end
;print, low_max_index, low_tot_index

print, w, h
print, b
print, vector.x[1172], vector.y[1172]

for i=0, N_ELEMENTS(vector.x)-1 do begin
plots, vector.x[i], h-vector.y[i], /DEVICE, psym=4, symsize=0.6, color='1100FF'x;, /NORMAL
plots, [vector.x[i],vector.x[i]+vector.dx[i]], [h-vector.y[i],h-vector.y[i]-vector.dy[i]], /DEVICE, color='AF00FF'x;, psym=3;, /NORMAL
end
plots, vector.x[order[0:10]], h-vector.y[order[0:10]], /DEVICE, psym=4, symsize=0.6, color='FFFF00'x;, /NORMAL



VMimage = fltarr(3, w+1, h+1)
VMimage[2,*,*] = VMimage[2,*,*] - 1.0
onto_array = bytarr(w+1, h+1)



;stop
;RUN THE MAIN RECURSIVE PROCESS
shift_and_match, image0, image1, nw_win, [0,0], vector, VMimage, onto_array
shift_and_match, image0, image1, ne_win, [0,0], vector, VMimage, onto_array
shift_and_match, image0, image1, se_win, [0,0], vector, VMimage, onto_array
shift_and_match, image0, image1, sw_win, [0,0], vector, VMimage, onto_array

;shift_and_match, image0, image1, nw_win, [vector.dx[order[0]],vector.dy[order[0]]], vector, VMimage, onto_array
;shift_and_match, image0, image1, ne_win, [vector.dx[order[0]],vector.dy[order[0]]], vector, VMimage, onto_array
;shift_and_match, image0, image1, se_win, [vector.dx[order[0]],vector.dy[order[0]]], vector, VMimage, onto_array
;shift_and_match, image0, image1, sw_win, [vector.dx[order[0]],vector.dy[order[0]]], vector, VMimage, onto_array


;SAVE vector_image
window, 1, xsize=w, ysize=h
;tvscl, VMimage[2,*,*], 0, 0, 1, /ORDER
tvscl, VMimage[2,*,*];, /ORDER
;print, VMimage[where(VMimage ne 0)]
WRITE_TIFF, dir + 'recursive_out_nocolor_000.tif', reverse(VMimage, 3), /FLOAT

print, (systime(/seconds) - T)/60, ' minutes'
end