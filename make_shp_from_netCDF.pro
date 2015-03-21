pro make_shp_from_netCDF, filename, data, lon, lat, alt


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
    IF N_Elements(lon) EQ 0 THEN $
      entNew.BOUNDS[0] = data.lon[i] $
        else ent.BOUNDS[0] = lon[i]
    IF N_Elements(lat) EQ 0 THEN $
      entNew.BOUNDS[1] = data.lat[i] $
        else ent.BOUNDS[1] = lat[i]
    entNew.BOUNDS[2] = 0.00000000 
    entNew.BOUNDS[3] = 0.00000000 
    IF N_Elements(lon) EQ 0 THEN $
      entNew.BOUNDS[4] = data.lon[i] $
        else ent.BOUNDS[4] = lon[i]
    IF N_Elements(lat) EQ 0 THEN $
      entNew.BOUNDS[5] = data.lat[i] $
        else ent.BOUNDS[5] = lat[i]
    entNew.BOUNDS[6] = 0.00000000 
    entNew.BOUNDS[7] = 0.00000000 
    entNew.N_VERTICES = 1 ; take out of example, need as workaround 
     
    ;Create structure for new attributes 
    attrNew = mynewshape ->GetAttributes(/ATTRIBUTE_STRUCTURE) 
     
    ;Define the values for the new attributes 
    attrNew.ATTRIBUTE_0 = i
    IF N_Elements(alt) EQ 0 THEN $
      attrNew.ATTRIBUTE_1 = data.ssws[i] $
        ELSE attrNew.ATTRIBUTE_1 = alt[i]
    attrNew.ATTRIBUTE_2 = data.sswd[i]
    attrNew.ATTRIBUTE_3 = data.time[i]
     
    ;Add the new entity to new shapefile 
    mynewshape -> PutEntity, entNew 
     
    ;Determine the zero-based index of the new entity 
    entity_index=i
   
    ;Add the Colorado attributes to new shapefile. 
    mynewshape -> SetAttributes, entity_index, attrNew 
    
  endfor
  
  print, 'File created:', filename
   
  ;Close the shapefile 
  OBJ_DESTROY, mynewshape 
  
  
end