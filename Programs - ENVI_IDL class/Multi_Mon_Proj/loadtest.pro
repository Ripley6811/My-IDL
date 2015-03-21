pro loadtest
IF N_Params() EQ 0 THEN BEGIN
   filename = Filepath(SubDir=['examples', 'data'], 'worldelv.dat')
   OpenR, lun, filename, /Get_LUN
   image = BytArr(359,360)
   yrange = [-90, 90]
   xrange = [0, 360]
   plottitle='World Elevation'
   xtitle = 'Longitude'
   ytitle='Latitude'
   colortable = 33
   ReadU, lun, image
   Free_Lun, lun
ENDIF
s = SIZE(image)
IF s(0) LT 2 THEN Message, 'Must pass a 2D or 3D image data set.'
IF s(0) EQ 2 THEN BEGIN
   xsize = s(1)
   ysize = s(2)
   interleave = 0
   IF N_Elements(trueColor) EQ 0 THEN trueColor = 0
ENDIF
help, xsize
help, ysize
help, image
;   surfaceFile = FILEPATH('C:\Program Files\ITT_ENVI\IDL70\examples\data\clouds3d.dat')
   surfaceData = READ_BINARY('C:\Program Files\ITT_ENVI\IDL70\products\envi45\data\world_dem', $
                             DATA_DIMS = [3600,1800])
;   surfaceData = CONGRID(surfaceData,/INTERP)
   help, surfaceData

   test3, surfaceData



end