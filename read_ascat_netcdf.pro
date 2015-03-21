;CREATED: July 17, 2011
;AUTHOR: Jay W. Johnson

;PURPOSE: Easy to use method to import ASCAT NetCDF SSW data into IDL

;INPUT: filename = String of ASCAT data file location
;       /toSHP = keyword to produce an SHP file at the same location as data file
;         WARNING: the SHP file will be large and slow to load in GIS

;OUTPUT: Returns a data structure with five attributes:
;            .lat
;            .lon
;            .time   = seconds since 1990-01-01 00:00:00
;            .ssws   = SSW speed
;            .sswd   = SSW direction (0 - 360)



;____________________________________________________________________
; FROM: http://www.atmos.umd.edu/~gcm/usefuldocs/hdf_netcdf/IDL_hdf-netcdf.html
; close file added - Jay Johnson
pro ncdfread, filename, variable_name, data_variable, dims
; This procedure will read netCDF data and place it in an IDL variable 
; INPUT: filename - a string variable that includes the filepath
;        variable_name - a string that must match exactly that produced by        
;                        ncdfshow.pro
; OUTPUT: data_variable - a user supplied variable for the data
;         dims - a vector of the dimensions

; get fileID, variable ID
  fileID = ncdf_open(filename)
  varID = ncdf_varid(fileID, variable_name)

; get the data and dimensions
  ncdf_varget, fileID, varID, data_variable
  dims = size(data_variable,/dimensions)

  NCDF_Close, fileID
end


;____________________________________________________________________

pro make_shp_from_netCDF, filename, data

  ;Create the new shapefile and define the entity type to Point 
  mynewshape=OBJ_NEW('IDLffShape', filename, /UPDATE, ENTITY_TYPE=1) 
   
  ;Set the attribute definitions for the new Shapefile 
  mynewshape->AddAttribute, 'ID', 3, 8;, PRECISION=16 
  mynewshape->AddAttribute, 'SSWS', 5, 20, PRECISION=10 
  mynewshape->AddAttribute, 'SSWD', 5, 20, PRECISION=10 
  mynewshape->AddAttribute, 'TIME', 5, 20, PRECISION=10 
  
   
  for i = 0L, size(data.lon,/N_ELEMENTS)-1 do begin 
    ;Create structure for new entity 
    entNew = {IDL_SHAPE_ENTITY} 

    ; Define the values for the new entity 
    entNew.SHAPE_TYPE = 1 
    entNew.BOUNDS[0] = data.lon[i]
    entNew.BOUNDS[1] = data.lat[i]
    entNew.BOUNDS[2] = 0.00000000 
    entNew.BOUNDS[3] = 0.00000000 
    entNew.BOUNDS[4] = data.lon[i]
    entNew.BOUNDS[5] = data.lat[i]
    entNew.BOUNDS[6] = 0.00000000 
    entNew.BOUNDS[7] = 0.00000000 
    entNew.N_VERTICES = 1 ; take out of example, need as workaround 
     
    ;Create structure for new attributes 
    attrNew = mynewshape ->GetAttributes(/ATTRIBUTE_STRUCTURE) 
     
    ;Define the values for the new attributes 
    attrNew.ATTRIBUTE_0 = i
    attrNew.ATTRIBUTE_1 = data.ssws[i]
    attrNew.ATTRIBUTE_2 = data.sswd[i]
    attrNew.ATTRIBUTE_3 = data.time[i]
     
    ;Add the new entity to new shapefile 
    mynewshape -> PutEntity, entNew 
     
    ;Determine the zero-based index of the new entity 
    entity_index=i
   
    ;Add the attributes to new shapefile. 
    mynewshape -> SetAttributes, entity_index, attrNew 
    
  endfor
  
  print, 'File created:', filename
   
  ;Close the shapefile 
  OBJ_DESTROY, mynewshape 
end

;___________________________________________________________________

pro make_raster_from_NetCDF, filename, data
  ;   
  ; First restore all the base save files.  
  ;  
  envi, /restore_base_save_files  
  ;   
  ; Initialize ENVI and send all errors  
  ; and warnings to the file batch.txt  
  ;  
  envi_batch_init, log_file='batch.txt'  
  ;  
  ; Set the necessary variables  
  ;  
  x_pts = data.lon  
  y_pts = data.lat  
  z_pts = data.ssws  
  o_proj = envi_proj_create(/arbitrary)  
  pixel_size = [0.01,0.01]  
  out_name ='testimg'  
  ;  
  ; Call the doit  
  ;  
  envi_doit, 'envi_grid_doit', $  
    x_pts=x_pts, y_pts=y_pts, $  
    z_pts=z_pts, out_dt=4, $  
    pixel_size=pixel_size, $  
    o_proj=o_proj, $  
    out_name=out_name, interp=1, $  
    r_fid=r_fid  
  ;  
  ; Exit ENVI  
  ;  
  envi_batch_exit  
end

;___________________________________________________________________

function read_ASCAT_NetCDF, filename, toSHP = toSHP


NCDFread, filename, 'lon',          lon, dims
NCDFread, filename, 'lat',          lat, dims
NCDFread, filename, 'model_speed',  ssws, dims
NCDFread, filename, 'model_dir',    sswd, dims
NCDFread, filename, 'time',         time, dims

data = { $
   ssws:ssws/10.0, $
   sswd:sswd/10.0, $
   time:time, $
   lon:lon/100000.0, $
   lat:lat/100000.0 $
}

if KEYWORD_SET(toSHP) then make_shp_from_netCDF, filename + '.shp', data

return, data

end
