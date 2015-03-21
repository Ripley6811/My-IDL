pro jwj_Earth_area

window,0, xsize=1600, ysize=800

;DISPLAY MAP WITHOUT BORDER
map_set,/cylindrical, /NOBORDER
map_continents,color=130,/fill, /NOBORDER;, /hires  ;HIRES decreases the land pixels
img=tvrd(true=1)   

;THERE IS STILL A BLANK AREA AROUND IMAGE.  THIS REMOVES THE BLANK AREA FROM IMAGE
img = reform((img gt 0)[0,*,*])
img = img[12:N_ELEMENTS(img[*,0])-13,13:N_ELEMENTS(img[0,*])-14]

;stop
;OUTPUT CROPPED IMAGE
window,0, xsize=N_ELEMENTS(img[*,0]), ysize=N_ELEMENTS(img[0,*])
tvscl, img

;CREATE LONGITUDE WIDTH RATIO GRAPH
;FROM -90 (INDEX 0) TO +90 (INDEX 181)
lat = indgen(181)-90
dlon = fltarr(181)
for i=-90, 90 do dlon[i+90] = (MAP_2POINTS( 0, i, 1, i))[0]

;EXTEND THE RATIO ARRAY TO THE HEIGHT OF THE IMAGE. A LONGITUDE WIDTH FOR EACH PIXEL Y-DIR
im_h = N_ELEMENTS(img[0,*])
dlon = CONGRID(dlon, im_h, /INTERP, /MINUS_ONE)   ;/MINUS_ONE keeps the last element as last (no repeated zeros)
;plot, dlon

;FIND PERCENTAGE OF LAND FOR EACH ROW IN Y-DIR
y_landpix = intarr(im_h)
y_totalpix = intarr(im_h)
for i=0, im_h-1 do begin
   y_totalpix[i] = N_ELEMENTS(img[*,i])*dlon[i]   ;x width times longitude ratio (weighting)
   y_landpix[i] = total(img[*,i])*dlon[i]         ;land pixels in row times long ratio
end
print, 'Surface estimates from image:'
print, N_ELEMENTS(img), ' total pixels in the image.'
print, ulong(total(y_totalpix)), ' total pixels after scaling to the equator.'
print, ulong(total(y_landpix)), ' total land pixels in image after scaling to the equator.'
print, 100*total(y_landpix)/total(y_totalpix), '% of area is land.'

;OUTPUT WIKIPEDIA DATA FOR COMPARISON
print, 'WIKIPEDIA Earth Data:
print, '      5.10072e8 km2 total surface area
print, '      1.48940e8 km2 land (29.2 %)
print, '      3.61132e8 km2 water (70.8 %)

;MONTE CARLO: ESTIMATE PERCENTAGE OF LAND AND WATER SURFACES
seed = systime(/seconds)
n_trials = 100   ;number of sample groups
n = 1000   ;number of times to run random coordinate per trial
trials_land = fltarr(n_trials)
for j=1, n_trials do begin 
   land_total = 0.0d
   water_total = 0.0d
   for i=1ul, n do begin
      xp = RANDOMU(seed)*N_ELEMENTS(img[*,0])
      yp = RANDOMU(seed)*N_ELEMENTS(img[0,*])
      is_land = img[xp,yp]
      if is_land then land_total += dlon[yp] $
      else water_total += dlon[yp]
      XYOUTS, xp, yp, '.', color=(is_land)?'00AA00'x:'FF2222'x, /DEVICE, ALIGNMENT=0.5
   end
   trials_land[j-1] = 100*land_total/(land_total+water_total)
;   print, 'Trial ' + strtrim(j,2) + ': ', trials_land[j-1], '% of area is land.'
end
print, 'Monte Carlo surface estimates:'
print, n_trials, ' sample groups of ', strtrim(n,2), ' points.'
print, MEAN(trials_land), '% of area is land (average of all groups).'
print, 100-MEAN(trials_land), '% of area is water.'

print, ''
print, 'The Monte Carlo results are close to the surface estimates from image pixels.'
print, 'Difference in land percentage: ', abs(100*total(y_landpix)/total(y_totalpix) - MEAN(trials_land)), '%'



end