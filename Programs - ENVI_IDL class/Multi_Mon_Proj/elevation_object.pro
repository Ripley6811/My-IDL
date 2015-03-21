;  $Id: //depot/idl/IDL_70/idldir/examples/doc/image/elevation_object.pro#1 $

;  Copyright (c) 2005-2007, ITT Visual Information Solutions. All
;       rights reserved.
; 
PRO Elevation_Object

; Obtaining path to image file.
imageFile = FILEPATH('elev_t.jpg', $
   SUBDIRECTORY = ['examples', 'data'])

; Importing image file.
READ_JPEG, imageFile, image

; Obtaining path to DEM data file.
demFile = FILEPATH('elevbin.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Importing data.
dem = READ_BINARY(demFile, DATA_DIMS = [64, 64])
dem = CONGRID(dem, 128, 128, /INTERP)

; Initialize the display.
;DEVICE, DECOMPOSED = 0, RETAIN = 2

; Displaying original DEM elevation data.
;WINDOW, 0, TITLE = 'Elevation Data'
;SHADE_SURF, dem

; Initialize the  display objects.
oModel = OBJ_NEW('IDLgrModel')
oView = OBJ_NEW('IDLgrView')
oWindow = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   COLOR_MODEL = 0)
oSurface = OBJ_NEW('IDLgrSurface', dem, STYLE = 2)
oImage = OBJ_NEW('IDLgrImage', image, $
   INTERLEAVE = 0, /INTERPOLATE)
o2Model = OBJ_NEW('IDLgrModel')
o2View = OBJ_NEW('IDLgrView')
o2Window = OBJ_NEW('IDLgrWindow', RETAIN = 2, $
   COLOR_MODEL = 0)
o2Surface = OBJ_NEW('IDLgrSurface', dem, STYLE = 2)
o2Image = OBJ_NEW('IDLgrImage', image, $
   INTERLEAVE = 0, /INTERPOLATE)
   
oWindow->SetProperty, Title='1'
oView->SetProperty, EYE=5.
oView->SetProperty, ZCLIP = [2.0, -3.0]   
oView->SetProperty, DEPTH_CUE=[1,2]
oWindow->GetProperty, IDENTIFIER=hillo
print, hillo

; Calculating normalized conversion factors and
; shifting -.5 in every direction to center object
; in the window.
; Keep in mind that your view default coordinate
; system is [-1,-1], [1, 1]
oSurface -> GetProperty, XRANGE = xr, $
   YRANGE = yr, ZRANGE = zr
xs = NORM_COORD(xr)
xs[0] = xs[0] - 0.5
ys = NORM_COORD(yr)
ys[0] = ys[0] - 0.5
zs = NORM_COORD(zr)
zs[0] = zs[0] - 0.5
oSurface -> SetProperty, XCOORD_CONV = xs, $
   YCOORD_CONV = ys, ZCOORD = zs
   
o2Surface -> GetProperty, XRANGE = x2r, $
   YRANGE = y2r, ZRANGE = z2r
x2s = NORM_COORD(x2r)
x2s[0] = x2s[0] - 0.5
y2s = NORM_COORD(y2r)
y2s[0] = y2s[0] - 0.5
z2s = NORM_COORD(z2r)
z2s[0] = z2s[0] - 0.5
o2Surface -> SetProperty, XCOORD_CONV = x2s, $
   YCOORD_CONV = y2s, ZCOORD = z2s

; Applying image to surface (texture mapping).
oSurface -> SetProperty, TEXTURE_MAP = oImage, $
   COLOR = [255, 255, 255]
o2Surface -> SetProperty, TEXTURE_MAP = o2Image, $
   COLOR = [255, 255, 255]

; Adding objects to model,then adding model to view.
oModel -> Add, oSurface
oView -> Add, oModel
o2Model -> Add, o2Surface
o2View -> Add, o2Model

; Rotating model for better display of surface
; in the object window.
oModel -> ROTATE, [1, 0, 0], -90
;oModel -> ROTATE, [0, 1, 0], 30
oModel -> ROTATE, [1, 0, 0], 30

; Drawing the view of the surface (Displaying the
; results).
oWindow -> Draw, oView
o2Window -> Draw, o2View
help, oWindow, /struct

; Displaying results in XOBJVIEW utility to allow
; rotation
XOBJVIEW, oModel, SCALE = 1, yoffset=-1024, xsize=600, xoffset=600
;  XOBJVIEW_ROTATE, [0, 1, 0], 5;, /PREMULTIPLY;       
;XOBJVIEW, oModel, SCALE = 1, yoffset=-1024, xsize=600
;for i = 0, 60 do begin
  oModel -> ROTATE, [1,0,0], 10
  wait,1
  oModel -> ROTATE, [1,0,0], 10
oWindow -> Draw, oView
  
;  endfor

;XOBJVIEW, oModel, /Block, scale = 1

; Destroying object references, which are no longer
; needed.
;OBJ_DESTROY, [oView, oImage]

END