;Jay William Johnson
;L46997017

;Write an IDL code to 
;  Read CR1000_ms700 data file 
;  Plot the spectra of reflectance R(λ)  
;  Try different keywords of Plot command 
;  Make the best output of your plot

;Note:  
;  There are 533 Fields in the file CR1000_ms700.dat
;  Ed(λ): FIELD022~FIELD277  (256 bands of downwelling)
;  Eu(λ): FIELD278~FIELD533 (256 bands of upwelling)
;  R(λ) = Eu(λ) /Ed(λ)
;  λ: 350nm~1050nm
;  There are 256 bands with the same interval of (1050-350)/256

;  Red bands are Ed = FIELD132 and Eu = FIELD388
;  Blue bands are Ed = FIELD067 and Eu = FIELD323
;  Green bands are Ed = FIELD085 and Eu = FIELD345 

pro homework2

   ;RESTORE THE CORE FILE AND START ENVI IN BATCH
   envi, /restore_base_save_files
   envi_batch_init, log_file ='batch.log'
   
   ;SET DIRECTORY OF DATA AND TEST FOR EXISTENCE OF FILES
   fileDir = dialog_pickfile(/directory, title='Select the location of data files')
   if file_test(fileDir + 'CR1000_ms700.dat') eq 0 then begin
      print, 'CR1000_ms700.dat not found'
      envi_batch_exit
   endif
   if file_test(fileDir + 'CR1000_ms700_template') eq 0 then begin
      print, 'CR1000_ms700_template not found'
      envi_batch_exit
   endif
   

;READ DATA FILE
   ;USE SAVED TEMPLATE TO READ IN DATA.  TEMPLATE WAS SAVED AS MyTemplate
   restore, fileDir + 'CR1000_ms700_template',/verbose
   Data = read_ascii( fileDir + 'CR1000_ms700.dat',      $
      template = MyTemplate)

help, data

;ORGANIZE DATA
   ;CREATE LABEL ARRAY FOR X AXIS, 35 TIME PERIODS EACH DAY
   xAxisLabel = lindgen(256)
   for i = 0, 256-1 do begin
      xAxisLabel[i] = ((i) mod 35) +1
   endfor
   ;print, xAxisLabel
   

   
   
   ;CLEAN UP DATA
   ;GET RID OF BAD DATA.  DELETE VALUES BELOW ZERO AND OVER 2000
   size = size(data.field067, /n_elements)
   for i = 0, size-1 do begin
      if data.field067[i] lt 0 or data.field067[i] gt 2000 then data.field067[i] = !Values.F_NAN
      if data.field132[i] lt 0 or data.field132[i] gt 2000 then data.field132[i] = !Values.F_NAN
      if data.field388[i] lt 0 or data.field388[i] gt 2000 then data.field388[i] = !Values.F_NAN
      if data.field323[i] lt 0 or data.field323[i] gt 2000 then data.field323[i] = !Values.F_NAN
      if data.field085[i] lt 0 or data.field085[i] gt 2000 then data.field085[i] = !Values.F_NAN
      if data.field345[i] lt 0 or data.field345[i] gt 2000 then data.field345[i] = !Values.F_NAN
      if data.field040[i] lt 0 or data.field040[i] gt 2000 then data.field040[i] = !Values.F_NAN
   endfor
   print, 'mean is '
   print, mean(data.field067, /NaN)
   ;help, data.field067
   


;PLOT SPECTRA OF REFLECTANCE
   ;PLOTTING TWO WAVELENGTHS (Ed/Eu) WITH EACH DAY OVERLAYED
   window, 0, title = 'Practice with "mod 34" to plot 37 days of two wavelengths over eachother'
   

   plot, xAxisLabel, data.field040, /noclip, psym = 1,   $
      title = 'Ed on top - Eu on bottom', $
      xtitle = 'Daily Recording Sequence (37 days of 2 pairs of bands plotted over 35 intervals)  + = 372nm, x = 386nm', $
      ytitle = 'W/m^2', charsize = 0.6
   oplot, xAxisLabel, data.field296, psym = 1
   oplot, xAxisLabel, data.field045, psym = 7, color = 'FFCC66'x
   oplot, xAxisLabel, data.field301, psym = 7, color = 'FFCC66'x



;TRYING A DIFFERENT VIEW WITH CONTIGUOUS DATA
   window, 1, title = 'All data for the 372nm Ed Eu bands plotted'
   plot, data.field040,    $
      title = 'Ed on top - Eu on bottom', $
      xtitle = 'Daily Recording Sequence (37 days)', $
      ytitle = 'W/m^2',      $
      /xstyle, font = 0, charsize = 0.6
   oplot, data.field296



;PLOT YOUR BEST OUTPUT
   window, 2, title = 'BEST PLOT: RGB irradiance  (Sept 9-12, 2008)'

   ;INITIATING A GRAPH WITHOUT DATA
   plot, xAxisLabel, [0.0,0.1], /nodata,   $
            title = 'R(lambda) = Eu(lambda) /Ed(lambda) - Red, Green, and Blue centered bands',    $
            xtitle = 'Daily Recording Sequence (4 days overlayed)  White line is the green-blue difference',    $
            ytitle = 'R(lambda)',   $
            /xstyle, font = -1, charsize = 0.8
   ;ADDING DATA. RGB BANDS FOR 4 DAYS.  AND THE LINE SHOWING THE DIFFERENCE BETWEEN GREEN AND BLUE
   for d = 20, 23 do begin
      datag = data.field345[d*35:d*35+34]/data.field085[d*35:d*35+34]
      oplot, xAxisLabel, datag, color = '00FF00'x
      datab = data.field323[d*35:d*35+34]/data.field067[d*35:d*35+34]
      oplot, xAxisLabel, datab, color = '0000FF'x
      datar = data.field388[d*35:d*35+34]/data.field132[d*35:d*35+34]
      oplot, xAxisLabel, datar, color = 'FF0000'x
      oplot, xAxisLabel, datag-datab, linestyle = 1, color = 'FFFFFF'x
   endfor



   ;exit envi
   ;envi_batch_exit

end