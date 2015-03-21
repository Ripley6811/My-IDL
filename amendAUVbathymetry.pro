;problem:  pre-setting template stores rows instead of columns. Must use ascii_template for now
;warning:  may need to alter the devHeading calculation to avoid divide by zero error (if pitch is ever zero)
;problem:  change lat, long and other important types to type double precision

;TODO:-Get rid of bad data before processing raster (can probably leave in shapefile)
;        or give the user the option to leave in or take out with feedback on errors
;     -Give option for pixel size.  Clean up code by putting repeated algorithms in a separate pro
;     -Need to search the heading for the column that holds the data.  The columns may change depending on which
;        instrument is installed.


pro amendAUVbathymetry

;SELECT THE ECOMAPPER DATA LOG TO CONVERT
filename = dialog_pickfile(title='Select an EcoMapper log file')
print, filename

;READ DATA FILE: Consider creating a template (50 data fields)
mytemplate = ascii_template(filename)
Data = read_ascii( filename, count=count, data_start=0, $
                   delimiter=';', header=header,  record_start=1, template=mytemplate)
;SAVE, myTemplate, FILENAME='EcoMapperLogTemplate.sav' 



;CREATE ADDITIONAL DATA FIELDS
columnAngle = dindgen(count)
columnHeight = dindgen(count)
surfaceDist = dindgen(count)
devHeading = dindgen(count)
bathLat = dindgen(count)
bathLong = dindgen(count)
help, columnAngle
help, columnHeight
help, surfaceDist
help, devHeading
help, bathLat

;Excel =ATAN(SQRT(POWER(TAN(L2*PI()/180),2)+POWER(TAN(M2*PI()/180),2)))*180/PI()
;saved as radians
columnAngle = atan(sqrt(tan(double(data.field12) * !dpi/180)^2 + tan(double(data.field13) * !dpi/180)^2))
;Excel =(Q2*COS(AY2*PI()/180))
;in feet
columnHeight = data.field17 * cos(columnAngle)
;Excel =(P2*SIN(AY2*PI()/180))
;in feet
surfaceDist = data.field16 * sin(columnAngle)
;=IF(L2=0,0,ATAN((M2*PI()/180)/(L2*PI()/180))*180/PI())
;=MOD(K2+BB2,360)
;0 deg is north
devHeading = (data.field11 - (atan((data.field13 *!dpi/180)/(data.field12 *!dpi/180))*180/!dpi)) mod 360
;Excel =ASIN(SIN(A2*PI()/180)*COS(BA2*0.0003048/6371) + COS(A2*PI()/180)*SIN(BA2*0.0003048/6371)*COS(BC2))*180/PI()
bathLat = ASIN(SIN(data.field01*!dpi/180)*COS(surfaceDist*0.0003048/6371) $
        + COS(data.field01*!dpi/180)*SIN(surfaceDist*0.0003048/6371)*COS(devHeading))*180/!dpi
;Excel =(B2*PI()/180 + ATAN2(COS(BA2*0.0003048/6371)-SIN(A2*PI()/180)*SIN(BD2*PI()/180)
;      , SIN(BC2*PI()/180)*SIN(BA2*0.0003048/6371)*COS(A2*PI()/180)))*180/PI()
bathLong = (data.field02*!dpi/180 + atan(SIN(devHeading*!dpi/180)*SIN(surfaceDist*0.0003048/6371)*COS(data.field01*!dpi/180), $
          COS(surfaceDist*0.0003048/6371)-SIN(data.field01*!dpi/180)*SIN(bathLat*!dpi/180)))*180/!dpi




;print, columnAngle[0:4]
;print, columnHeight[0:4]
;print, surfaceDist[0:4]
;print, devHeading[0:4]
print, bathLat[0:4]
print, bathLong[0:4]
;help, columnAngle
;help, columnHeight
;help, surfaceDist
;help, devHeading
;help, bathLat
;help, bathLong




print, header
;help, header
;help, data
;print, data.field06[650:659]
;print, data.field10[650:659]
print, count, '=count'


info = { $
  filename:filename, $
  data:data, $          ; A pointer to data
  count:count, $
  columnAngle:columnAngle, $
  columnHeight:columnHeight, $
  surfaceDist:surfaceDist, $
  devHeading:devHeading, $
  bathLat:bathLat, $
  bathLong:bathLong $;, $
;  wid:wid, $                       ; The window index number of the graphics window.
}

tlb = Widget_Base(Title='EcoMapper Data Processor', Column=1, $
                               XOFFSET=300, YOFFSET=10, $
                               TLB_Size_Events=1, TLB_Move_EVENTS=0)
dummy = Widget_Button(tlb, Value='Create AUV Shapefile', uvalue='AUV_shape', Event_Pro='amendAUVbathymetry_panel_events')
dummy = Widget_Button(tlb, Value='Create Bathymetry Shapefile', uvalue='bath_shape', Event_Pro='amendAUVbathymetry_panel_events')

;dummy = Widget_Button(tlb, Value='Update Bathymetry Shapefile', uvalue='bath_shape_update', Event_Pro='amendAUVbathymetry_panel_events')
;
dummy = Widget_Button(tlb, Value='Create Bathymetry Raster', uvalue='bath_rast', Event_Pro='amendAUVbathymetry_panel_events')
dummy = Widget_Button(tlb, Value='Create Temperature Raster', uvalue='temp_rast', Event_Pro='amendAUVbathymetry_panel_events')
dummy = Widget_Button(tlb, Value='Create BGA-PC RFU Raster', uvalue='bga_rast', Event_Pro='amendAUVbathymetry_panel_events')
dummy = Widget_Button(tlb, Value='Create Chl ug/L Raster', uvalue='chlug_rast', Event_Pro='amendAUVbathymetry_panel_events')
dummy = Widget_Button(tlb, Value='Create Chl RFU Raster', uvalue='chlRFU_rast', Event_Pro='amendAUVbathymetry_panel_events')
dummy = Widget_Button(tlb, Value='Create Turbid+ NTU', uvalue='turb_rast', Event_Pro='amendAUVbathymetry_panel_events')

dummy = Widget_Button(tlb, Value='Exit', Event_Pro='amendAUVbathymetry_Exit')



Widget_Control, tlb, /Realize

Widget_Control, tlb, Set_UValue=info, /No_Copy

XManager, 'amendAUVbathymetry', tlb, Cleanup='amendAUVbathymetry_Cleanup', /No_Block, $
            Group_Leader=groupLeader
end;main



pro amendAUVbathymetry_panel_events, event


end; panel_events


;--------------------------------------------------------------------
pro amendAUVbathymetry_panel_events, event
; This event handler responds to keyboard focus and resize events.
print, 'entered'
thisEvent = Tag_Names(event, /Structure_Name)
print, thisEvent
Widget_Control, event.top, Get_UValue=info, /No_Copy
Widget_Control, event.id, Get_UValue=value
CASE value OF
   
'bath_shape': Begin

  ;Create the new shapefile and define the entity type to Point 
  mynewshape=OBJ_NEW('IDLffShape', dialog_pickfile(PATH=info.filename), /UPDATE, ENTITY_TYPE=1) 
   
  ;Set the attribute definitions for the new Shapefile 
  mynewshape->AddAttribute, 'TIME', 7, 20, PRECISION=0 
  mynewshape->AddAttribute, 'DATE', 7, 20, PRECISION=0 
  mynewshape->AddAttribute, 'DEPTH', 5, 20, PRECISION=16 
  
   
  for i = 0, info.count-1 do begin 
    ;Create structure for new entity 
    entNew = {IDL_SHAPE_ENTITY} 

    ; Define the values for the new entity 
    entNew.SHAPE_TYPE = 1 
    entNew.BOUNDS[0] = info.bathLong[i] 
    entNew.BOUNDS[1] = info.bathLat[i] 
    entNew.BOUNDS[2] = 0.00000000 
    entNew.BOUNDS[3] = 0.00000000 
    entNew.BOUNDS[4] = info.bathLong[i] 
    entNew.BOUNDS[5] = info.bathLat[i] 
    entNew.BOUNDS[6] = 0.00000000 
    entNew.BOUNDS[7] = 0.00000000 
    entNew.N_VERTICES = 1 ; take out of example, need as workaround 
     
    ;Create structure for new attributes 
    attrNew = mynewshape ->GetAttributes(/ATTRIBUTE_STRUCTURE) 
     
    ;Define the values for the new attributes 
    attrNew.ATTRIBUTE_0 = info.data.field03[i]
    attrNew.ATTRIBUTE_1 = info.data.field04[i]
    attrNew.ATTRIBUTE_2 = info.columnHeight[i]
     
    ;Add the new entity to new shapefile 
    mynewshape -> PutEntity, entNew 
     
    ;Determine the zero-based index of the new entity 
    entity_index=i
   
    ;Add the Colorado attributes to new shapefile. 
    mynewshape -> SetAttributes, entity_index, attrNew 
    
  endfor
  
  print, 'Files saved'
   
  ;Close the shapefile 
  OBJ_DESTROY, mynewshape 
 
ENDCASE
'bath_rast': Begin
  pixel_size = [0.000005,0.000005]  

  create_raster, DIALOG_PICKFILE(PATH=info.filename), $
                 info.bathLong, info.bathLat, $
                 info.columnHeight, pixel_size
ENDCASE
'bath_shape_update': Begin



ENDCASE
'temp_rast': Begin
  pixel_size = [0.000005,0.000005]  

  create_raster, DIALOG_PICKFILE(PATH=info.filename), $
                 info.data.field02, info.data.field01, $
                 info.data.field44, pixel_size   ;  44 = temp
ENDCASE
'bga_rast': Begin
  pixel_size = [0.000005,0.000005]  

  create_raster, DIALOG_PICKFILE(PATH=info.filename), $
                 info.data.field02, info.data.field01, $
                 info.data.field47, pixel_size   ;  47 = bga
ENDCASE
'chlug_rast': Begin
  pixel_size = [0.000005,0.000005]  

  create_raster, DIALOG_PICKFILE(PATH=info.filename), $
                 info.data.field02, info.data.field01, $
                 info.data.field48, pixel_size   ;  48 = 
ENDCASE
'chlRFU_rast': Begin
  pixel_size = [0.000005,0.000005]  

  create_raster, DIALOG_PICKFILE(PATH=info.filename), $
                 info.data.field02, info.data.field01, $
                 info.data.field49, pixel_size   ;  49 = 
ENDCASE
'turb_rast': Begin
  pixel_size = [0.000005,0.000005]  

  create_raster, DIALOG_PICKFILE(PATH=info.filename), $
                 info.data.field02, info.data.field01, $
                 info.data.field50, pixel_size   ;  50 = 
ENDCASE
'AUV_shape': Begin

;Make a shapefile for all data collected by AUV
;ArcGIS can be used later to combine data from multiple missions 

  ;Create the new shapefile and define the entity type to Point 
  mynewshape=OBJ_NEW('IDLffShape', info.filename + 'data', /UPDATE, ENTITY_TYPE=1) 
   
  ;Set the attribute definitions for the new Shapefile 
  mynewshape->AddAttribute, 'TIME', 7, 20, PRECISION=0 
  mynewshape->AddAttribute, 'DATE', 7, 20, PRECISION=0 
  mynewshape->AddAttribute, 'DFS', 5, 20, PRECISION=16 
  mynewshape->AddAttribute, 'TEMP', 5, 10, PRECISION=5 
  mynewshape->AddAttribute, 'SPCOND', 5, 10, PRECISION=5 
  mynewshape->AddAttribute, 'SAL_PPT', 5, 10, PRECISION=5 
  mynewshape->AddAttribute, 'BGA-PC', 5, 10, PRECISION=5 
  mynewshape->AddAttribute, 'CHL', 5, 10, PRECISION=5 
  mynewshape->AddAttribute, 'CHL_RFU', 5, 10, PRECISION=5 
  mynewshape->AddAttribute, 'TURBID_NTU', 5, 10, PRECISION=5 
  
   
  for i = 0, info.count-1 do begin 
    ;Create structure for new entity 
    entNew = {IDL_SHAPE_ENTITY} 

    ; Define the values for the new entity 
    entNew.SHAPE_TYPE = 1 
    entNew.BOUNDS[0] = info.data.field02[i] 
    entNew.BOUNDS[1] = info.data.field01[i] 
    entNew.BOUNDS[2] = 0.00000000 
    entNew.BOUNDS[3] = 0.00000000 
    entNew.BOUNDS[4] = info.data.field02[i] 
    entNew.BOUNDS[5] = info.data.field01[i] 
    entNew.BOUNDS[6] = 0.00000000 
    entNew.BOUNDS[7] = 0.00000000 
    entNew.N_VERTICES = 1 ; take out of example, need as workaround 
     
    ;Create structure for new attributes 
    attrNew = mynewshape ->GetAttributes(/ATTRIBUTE_STRUCTURE) 
     
    ;Define the values for the new attributes 
    attrNew.ATTRIBUTE_0 = info.data.field03[i]
    attrNew.ATTRIBUTE_1 = info.data.field04[i]
    attrNew.ATTRIBUTE_2 = info.data.field15[i]
    attrNew.ATTRIBUTE_3 = info.data.field44[i]
    attrNew.ATTRIBUTE_4 = info.data.field45[i]
    attrNew.ATTRIBUTE_5 = info.data.field46[i]
    attrNew.ATTRIBUTE_6 = info.data.field47[i]
    attrNew.ATTRIBUTE_7 = info.data.field48[i]
    attrNew.ATTRIBUTE_8 = info.data.field49[i]
    attrNew.ATTRIBUTE_9 = info.data.field50[i]
     
    ;Add the new entity to new shapefile 
    mynewshape -> PutEntity, entNew 
     
    ;Determine the zero-based index of the new entity 
    entity_index=i
   
    ;Add the Colorado attributes to new shapefile. 
    mynewshape -> SetAttributes, entity_index, attrNew 
    
  endfor
  
  print, 'Files saved as ', info.filename, '.shp'
   
  ;Close the shapefile 
  OBJ_DESTROY, mynewshape 


ENDCASE
ELSE: print, 'not routed'
ENDCASE


Widget_Control, event.top, Set_UValue=info, /No_Copy
   
end;amendAUVbathymetry_panel_events

;EVENT HANDLER: amendAUVbathymetry_Exit   ---------------------------------------------
PRO amendAUVbathymetry_Exit, event
   Widget_Control, event.top, /Destroy      
END
;EVENT HANDLER: amendAUVbathymetry_Exit   ---------------------------------------------



;CLEANUP-------------------------------------------------------------------
Pro amendAUVbathymetry_Cleanup, tlb
   Widget_Control, tlb, Get_UValue=info, /No_Copy
   IF N_Elements(info) eq 0 THEN return
END
;CLEANUP-------------------------------------------------------------------

Pro create_raster, filenameStr, long_array, lat_array, data_array, pixel_size
  o_proj = envi_proj_create(/arbitrary, /MAP_BASED)  

   ;Interp:  0=Linear  1=Quintic
  ENVI_DOIT, 'ENVI_GRID_DOIT', /IN_MEMORY, INTERP=0, OUT_DT=4, $
         o_proj=o_proj, pixel_size=pixel_size, $
         x_pts=long_array, y_pts=lat_array, z_pts=data_array, $ 
         r_fid=fid, /NO_REALIZE
  envi_file_query, fid, dims = dims
  interpImage = envi_get_data(fid = fid, dims = dims, pos = 0) 

  WRITE_TIFF, filenameStr + '.tif', interpImage, /FLOAT
  OPENW, 1, filenameStr + '.tfw'
  PRINTF, 1, FORMAT='(D)', pixel_size[0]
  PRINTF, 1, double(0.0)
  PRINTF, 1, double(0.0)
  PRINTF, 1, FORMAT='(D)', 0 - pixel_size[1]
  PRINTF, 1, FORMAT='(D)', min(Long_array)
  PRINTF, 1, FORMAT='(D)', max(Lat_array)
  CLOSE, 1

end
