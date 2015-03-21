pro make_shp, filename, data, lon, lat, alt


  ;Create the new shapefile and define the entity type to Point 
  mynewshape=OBJ_NEW('IDLffShape', filename, /UPDATE, ENTITY_TYPE=1) 
   
  ;Set the attribute definitions for the new Shapefile 
  mynewshape->AddAttribute, 'SEQID', 3, 8;, PRECISION=16 
  mynewshape->AddAttribute, 'ALT', 5, 20, PRECISION=10 
  mynewshape->AddAttribute, 'UTC', 7, 20;, PRECISION=16 
  
   
  for i = 0, size(data.seqid,/N_ELEMENTS)-1 do begin 
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
    attrNew.ATTRIBUTE_0 = data.seqid[i]
    IF N_Elements(alt) EQ 0 THEN $
      attrNew.ATTRIBUTE_1 = data.alt[i] $
        ELSE attrNew.ATTRIBUTE_1 = alt[i]
    attrNew.ATTRIBUTE_2 = data.utc[i]
     
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