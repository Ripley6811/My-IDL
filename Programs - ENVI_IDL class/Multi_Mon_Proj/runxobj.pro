pro runXOBJ
; Create contour object:  
oCont = OBJ_NEW('IDLgrContour', DIST(20), N_LEVELS=10)  
  
; Create surface object:  
oSurf = OBJ_NEW('IDLgrSurface', DIST(20),INDGEN(20)+20, INDGEN(20)+20)  
     
; Create model object:  
oModel = OBJ_NEW('IDLgrModel')  
  
; Add contour and surface objects to model:  
oModel->Add, oCont  
oModel->Add, oSurf  

;   image1File = 'D:\Class_ENVI_IDL\Multi_Mon_Proj\world_dem'
;   dem = READ_BINARY(image1File, DATA_DIMS = [2164, 2164])
;   device, decomposed = 0
;   window, 0, title = 'Elevation Data'
;   shade_surf, dem
;   oWindow = OBJ_NEW('IDLgrWindow', RETAIN=2, COLOR_MODEL=0)
;   oView = OBJ_NEW('IDLgrView')
;   oModel = OBJ_NEW('IDLgrModel')
;   oSurface = OBJ_NEW('IDLgrSurface', dem, STYLE=2)
;   oSurface -> GETPROPERTY, XRANGE=xr, YRANGE=yr, ZRANGE=zr, $
;   xs = NORM_COORD(xr)
;   xs[0] = xs[0] - 0.5
;   ys = NORM_COORD(yr)
;   ys[0] = ys[0] - 0.5
;   zs = NORM_COORD(zr)
;   zs[0] = zs[0] - 0.5
;   oSurface -> SETPROPERTY, XCOORD_CONV=xs, YCOORD_CONV=ys, ZCOORD=zs
   
      
  
; View model:  
;XOBJVIEW, dem, xoffset = 500
XOBJVIEW, oModel
elevation_object
print, "arrived"
elevation_object


;   xobjview, background=[0,0,0], /test




end