;Jay William Johnson 
;L46997017

;ASSIGNMENT
;Question A:
;Please write the first IDL program "Ex1.pro" with the following functions:
;1. Allow the user to read a data file through a dialog
;2. Read the file "C:\Program Files\ITT\IDL70\products\envi45\data\cup95eff.int"
;3. Locate the bands with wavelengths between 2.3 μm and 2.4 μm and calculate the average value of these bands for each pixel.
;4. Display the output image in a new window.
;5. Find the maximum value of the output image and print this value in the console window.

pro Ex1
   ;RESTORE THE CORE FILES AND START ENVI IN BATCH
   envi, /restore_base_save_files
   envi_batch_init, log_file ='batch.log'

   ;READ DATA.  FIRST ASK USER TO PICK, OTHER USE DEFAULT DIRECTORY
   cupData = dialog_pickfile(title='Please select the file: cup95eff.int')
   if file_test(cupData) eq 0 then begin
      print, 'cup95eff.int not selected.'
      if file_test('C:\Program Files\ITT\IDL70\products\envi45\data\cup95eff.int') eq 0 then begin
         print, 'cup95eff.int not found in C:\Program Files\ITT\IDL70\products\envi45\data\'
         envi_batch_exit
      endif else begin
         print, 'cup95eff.int found!'
         cupData = 'C:\Program Files\ITT\IDL70\products\envi45\data\cup95eff.int'
      endelse
   endif
  
   ; OPEN THE INPUT FILE
   envi_open_file, cupData, r_fid = fid
   if (fid eq -1) then begin
      envi_batch_exit
      return
   endif
   
   ;QUERY THE FILE FOR NUMBER OF BANDS AND WAVELENGTH ASSOCIATED WITH EACH BAND
   envi_file_query, fid, ns = ns, nl = nl, nb = nb, wl = wl, dims = dims
      
   ;SET BAND SEARCH MAX AND MIN
   sMax = 2.4
   sMin = 2.3
   
   ;FIND (QUERY) BANDS
   qbands = where((wl GE sMin) AND (wl le sMax))
   print, string(size(qbands, /n_elements)) + ' found'
   if (qbands[0] eq -1) then begin
      print, 'No bands were found'
      envi_batch_exit
      return
   endif else begin
      print, wl[qbands]
   endelse
   
   ;CREATE AN IMAGE WHERE EACH PIXEL IS THE AVERAGE OF THE BANDS BETWEEN 2.3 AND 2.4
   print, 'processing band ' + string(1) + ' of ' + string(size(qbands, /n_elements))
   outImage = float(envi_get_data(fid = fid, dims = dims, pos = [qbands[0]]))
   for i = 1, size(qbands, /n_elements)-1 do begin
      print, 'processing band ' + string(i+1) + ' of ' + string(size(qbands, /n_elements))
      outImage = outImage + float(envi_get_data(fid = fid, dims = dims, pos = [qbands[i]]))
   endfor
   outImage = outImage / 11.0
   
   ;OUTPUT THE RED BAND TO WINDOW 3
   print, 'Outputing averaged image to window'
   window, 1, xsize = ns, ysize = nl, xpos = 0, ypos = 0, title = 'Averaged bands 2.3-2.4 micrometers'
   tvscl, outImage

   ;FIND MAX VALUE AND OUTPUT TO CONSOLE
   maxElement = max( outImage )
   print, 'Max value found in the outputed image is ' + string(maxElement)
   
   
   ;EXIT ENVI
   envi_batch_exit
end
