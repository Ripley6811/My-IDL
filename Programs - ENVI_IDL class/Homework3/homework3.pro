;Jay William Johnson
;L46997017

;HOMEWORK INSTRUCTIONS
;Write an IDL program to convert coordinates between TWD67 and TWD97 map projections
;Use the Formosat-2 image of Hualian (TWD67) as the base image.  
;Convert the following five sets of coordinates (TWD67) to their corresponding coordinates (TWD97).

;308981.0001E, 2656373.9646N
;311601.0001E, 2655053.9646N
;306363.0001E, 2654439.9646N
;311569.0001E, 2653385.9646N
;304869.0001E, 2656229.9646N

;TAIWAN DATUM:
;   Hu-Tzu-Shan, International, -634, -549, -201
;      International = 6378388.0, 6356911.9


pro Homework3
   ;RESTORE THE CORE FILE AND START ENVI IN BATCH
   envi, /restore_base_save_files
   envi_batch_init, log_file ='batch.log'


  print, '-----------------IMPORT-DATA---------------------'
  lat_lon = dblarr(2, 5);
  fname = 'D:\Class_ENVI_IDL\Homework3\latlonHW3.txt';
  if file_test(fname) eq 0 then begin
      print, 'latlonHW3.txt not found.  Please select file to be converted.'
      fname = dialog_pickfile(title='Select the data file to be converted.')
  endif
  OpenR, unit, fname, /Get_LUN;
  ReadF, unit, lat_lon;
  Free_LUN, unit;
  
  for i=0, 4 do print, lat_lon[*,i], format='(4(F15.5))
  print, '-------------------------------------------------'
  
  
  print, '---------GET-PROJECTION-DATA-FROM-IMAGE----------'
  ENVI_OPEN_FILE, dialog_pickfile(title='Select the Hualian file'), r_fid = H_fid
  map_infor = ENVI_GET_MAP_INFO(fid=H_fid)
    
  print, 'Projection = ', map_infor.proj.type, ' ~ ',ENVI_TRANSLATE_PROJECTION_NAME(map_infor.proj.type)
  print, 'Pixel sizes = ', map_infor.ps
  print, 'Units = ', ENVI_TRANSLATE_PROJECTION_UNITS(map_infor.proj.units)
  print, '-------------------------------------------------'
  
  
  print, '------------CREATE-TWD97-PROJECTION--------------'
  TWD97_params = dblarr(6)
  TWD97_params[0:5] = [6378388.0, 6356911.9, 23, 121, 500000, 500000]
  
  TWD97_proj = ENVI_PROJ_CREATE( $
      type=10, $
      params=TWD97_params, $
      name='TWD97 Polyconic', $
      datum='Hu-Tzu-Shan'   $
      )
  print, '* HUALIAN MAP PROJECTION STRUCTURE'
  help, /struct, map_infor.proj
  print, '* TWD97 PROJECTION STRUCTURE'
  help, /struct, TWD97_proj
  print, '-------------------------------------------------'


   print, '-------------CONVERT-COORDINATES----------------'
  ENVI_CONVERT_PROJECTION_COORDINATES, lat_lon[0,*], lat_lon[1,*], map_infor.proj, mapX, mapY, TWD97_proj
  for i=0, 4 do print, lat_lon[*,i], mapX[i], mapY[i], format='(4(F15.5))'

   ;exit envi
   envi_batch_exit
   
end;pro