;Jay W. Johnson
;Homework 1

;ASSIGNMENT
; Write an IDL pro file to 
;  –Open the file 'bhtmref.img' 
;  –Locate the band between 0.6 and 0.7 mm 
;  –Show the band in a new window 
;  –NDVI = (NIR – Red) / (NIR + Red)
;  –Show the result of NDVI in a new window

pro homework1

  ;DATA DIRECTORY
  dataDir = 'e:\IDL70\products\envi45\data\'
    ;The range in micrometers for the desired band
  redLow = 0.6;
  redHigh = 0.7;
  nirHigh = 1.4;
  

  ; RESTORE THE CORE FILE AND START ENVI IN BATCH
  envi, /restore_base_save_files
  envi_batch_init, log_file ='batch.log'


  ; OPEN THE INPUT FILE
  envi_open_file, 'e:\IDL70\products\envi45\data\bhtmref.img', r_fid = fid
  if (fid eq -1) then begin
  envi_batch_exit
  return
  endif

  ;QUERY THE FILE FOR NUMBER OF BANDS AND WAVELENGTH ASSOCIATED WITH EACH BAND
  envi_file_query, fid, ns = ns, nl = nl, nb = nb, wl = wl, dims = dims

  ;PRINT THE NUMBER OF BANDS, FOLLOWED BY AN ARRAY OF THE RESPECTIVE WAVELENGTHS
  ;return IF BANDS ARE NOT FOUND
  print,nb
  print,wl
  redBand = where((wl LE redHigh) AND (wl GE redLow))
  if (redBand eq -1) then begin
  print, 'Red band not found'
  envi_batch_exit
  return
  endif
  print, format = '(A0, "~", A1," band found at index ", I2)', redLow, redHigh, redBand
  print, wl[redBand]
  nirBand = where((wl LE nirHigh) AND (wl GE redHigh))
  if (nirBand eq -1) then begin
  print, 'NIR band not found'
  envi_batch_exit
  return
  endif
  print, format = '(A0, "~", A1," band found at index ", I2)', redHigh, nirHigh, nirBand
  print, wl[nirBand]



  ;OUTPUT THE RED BAND TO WINDOW 3
  window, 3, xsize = ns, ysize = nl, xpos = 0, ypos = 0, title = string(wl[redBand] * 1000) + ' nm'
  redImage = float(envi_get_data(fid = fid, dims = dims, pos = [redBand]))
  tvscl, redImage
  
  ;OUTPUT THE NIR BAND TO WINDOW 4
  window, 4, xsize = ns, ysize = nl, xpos = 50, ypos = 200, title = string(wl[nirBand] * 1000) + ' nm'
  nirImage = float(envi_get_data(fid = fid, dims = dims, pos = [nirBand]))
  tvscl, nirImage

  ;OUTPUT THE NDVI TO WINDOW 5
  window, 5, xsize = ns, ysize = nl, xpos = 100, ypos = 400, title = 'NDVI'
  ndvi = (nirImage - redImage)/(nirImage + redImage)
  tvscl, ndvi
  




  ; remember to exit envi
  envi_batch_exit
end