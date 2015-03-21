
pro Earthquake_DMA
;   filename = 'C:\Users\Jay\Desktop\2005_earthquakes.dat'
   filename = 'C:\Users\tutu\Desktop\ARTCHOY.dat'
;   filename = dialog_pickfile(title='select data file')

   lines = file_lines(filename)
   print, lines
   
   lon = dblarr(lines)
   lat = dblarr(lines)
   depth = dblarr(lines)
   ml = dblarr(lines)
   err = strarr(lines)
   
   linfit_lbound = 2.5
   binsize = 0.2

   OPENR, unit, filename, /GET_LUN 
   str = '' 
   count = 0ll
   WHILE ~ EOF(unit) DO BEGIN 
      READF, unit, str 
      
      strA = strsplit(str, ' ', /EXTRACT)
      
      lat[count] = double(strA[1])
      lon[count] = double(strA[0])
      depth[count] = double(strA[2])
      ml[count] = double(strA[3])
      err[count] = strA[4]
       
      count = count + 1
   ENDWHILE    
   FREE_LUN, unit 
   histo = histogram(ml, binsize=binsize)
   x = findgen(size(histo,/N_ELEMENTS))/5
   histo[where(histo le 0)] = 1
   print, histo
   lineData = linfit(x[linfit_lbound/binsize:*],alog(histo[linfit_lbound/binsize:*]))
plot, x[linfit_lbound/binsize:*],alog(histo[linfit_lbound/binsize:*])
stop
   window,0
   title = 'b-value = ' +  strtrim(abs((linedata[1])),1)
   plot, x, histo[0:*], /YLOG, xrange=[0,10], psym=4, $
            xtitle='Magnitude', ytitle='Number of earthquakes', $
            title=title
   oplot, x, exp(linedata[0] + linedata[1]*x)
   print, exp(linedata[1])
   
end