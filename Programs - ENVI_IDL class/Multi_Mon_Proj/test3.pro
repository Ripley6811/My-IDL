; NAME:
;       TEST3
;
; PURPOSE:
;
;       The purpose of this program is display an overlayed 3d surface image
;       for 3d display using the multiple monitor option.  Also has an optional
;       anaglyph display.
;
; AUTHOR:
;
;       Modified from 'TEXTURE_SURFACE' program from:
;       http://www.dfanning.com/programs/texture_surface.pro
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
;       Modified by Jay William Johnson to support 3D monitor and anaglyph output
;
;
; CALLING SEQUENCE:
;
;       TEST3, data(DEM), Image=image
;       or
;       TEST3  (with no arguments. default data is used)
;
;
; OPTIONAL PARAMETERS:
;
;       data: A 2D array of surface data.
;
;       IMAGE: An 8-bit or 24-bit image you wish to use for the image texture.
;
;
;
;
;******************************************************************************************;
;  Copyright (c) 2008, by Fanning Software Consulting, Inc.                                ;
;  All rights reserved.                                                                    ;
;                                                                                          ;
;  Redistribution and use in source and binary forms, with or without                      ;
;  modification, are permitted provided that the following conditions are met:             ;
;                                                                                          ;
;      * Redistributions of source code must retain the above copyright                    ;
;        notice, this list of conditions and the following disclaimer.                     ;
;      * Redistributions in binary form must reproduce the above copyright                 ;
;        notice, this list of conditions and the following disclaimer in the               ;
;        documentation and/or other materials provided with the distribution.              ;
;      * Neither the name of Fanning Software Consulting, Inc. nor the names of its        ;
;        contributors may be used to endorse or promote products derived from this         ;
;        software without specific prior written permission.                               ;
;                                                                                          ;
;  THIS SOFTWARE IS PROVIDED BY FANNING SOFTWARE CONSULTING, INC. ''AS IS'' AND ANY        ;
;  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES    ;
;  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT     ;
;  SHALL FANNING SOFTWARE CONSULTING, INC. BE LIABLE FOR ANY DIRECT, INDIRECT,             ;
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    ;
;  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;         ;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND             ;
;  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ;
;  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS           ;
;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                            ;
;******************************************************************************************;


;MAIN PROGRAM:  Test3   ----------------------------------------------
PRO Test3, surfaceData, Image=image;, x, y, _Extra=extra, $
;   Group_Leader=groupLeader, $
;   Hidden_Lines=hidden_lines, Vector=vector, Exact=exact, $
;   Colortable=colortable, $
;   ZScale=zscale



eyeDist = 1.6

   ; Import default dem data

IF N_Elements(surfaceData) EQ 0 THEN BEGIN
   surfaceFile = FILEPATH('elevbin.dat', SUBDIRECTORY = ['examples', 'data'])
   surfaceData = READ_BINARY(surfaceFile, DATA_DIMS = [64, 64])
   surfaceData = CONGRID(surfaceData, 128, 128, /INTERP)
ENDIF

   ; Import default image overlay

IF N_Elements(image) EQ 0 THEN BEGIN
   imageFile = FILEPATH('elev_t.jpg', SUBDIRECTORY = ['examples', 'data'])
   READ_JPEG, imageFile, image
ENDIF


   ; Get dimensions of the surface data.

s = Size(surfaceData, /Dimensions)

   ; Fill out X and Y vectors if necessary.

IF N_Elements(x) EQ 0 THEN x = Findgen(s[0])
IF N_Elements(y) EQ 0 THEN y = Findgen(s[1])

    ; Create a view. Use RGB color. Charcoal background.
    ; The coodinate system is chosen so that (0,0,0) is in the
    ; center of the window. This will make rotations easier.

rView = OBJ_NEW('IDLgrView', Color=[80,80,80], Viewplane_Rect=[-0.7,-0.7,1.4,1.4])
rView->SetProperty, PROJECTION = 2  
rView->SetProperty, EYE = eyeDist
lView = OBJ_NEW('IDLgrView', Color=[80,80,80], Viewplane_Rect=[-0.7,-0.7,1.4,1.4])
lView->SetProperty, PROJECTION = 2  
lView->SetProperty, EYE = eyeDist


    ; Create a model for the surface and axes and add it to the view.
    ; This model will rotate under the direction of the trackball object.

rModel = OBJ_NEW('IDLgrModel')
rView->Add, rModel
lModel = OBJ_NEW('IDLgrModel')
lView->Add, lModel


    ; Create a trackball for surface rotations. Center it in
    ; the 400-by-400 window. Give it a 200 pixel diameter.

thisTrackball = OBJ_NEW('Trackball', [200, 200], 200)

   ; Create the image object.

   rImage = Obj_New('IDLgrImage', image, INTERLEAVE = 0, /INTERPOLATE)
   lImage = Obj_New('IDLgrImage', image, INTERLEAVE = 0, /INTERPOLATE)


   ; Create a surface object. Add the image to it as a texture map.
   ; The image is positioned with the Texture_Coord keyword and the
   ; texcoords values.

rSurface = OBJ_NEW('IDLgrSurface', surfaceData, Style=2)
 rSurface->SetProperty, Texture_Map=rImage, $  ;Cannot use same image for both displays
                        COLOR = [255, 255, 255]
lSurface = OBJ_NEW('IDLgrSurface', surfaceData, Style=2)
 lSurface->SetProperty, Texture_Map=lImage, $
                        COLOR = [255, 255, 255]

    ; Get the data ranges of the surface.

rSurface -> GetProperty, XRANGE = xrange, YRANGE = yrange, ZRANGE = zrange
xs = NORM_COORD(xrange)
xs[0] = xs[0] - 0.5
ys = NORM_COORD(yrange)
ys[0] = ys[0] - 0.5
zs = NORM_COORD(zrange)
zs[0] = zs[0] - 0.5
rSurface -> SetProperty, XCOORD_CONV = xs, YCOORD_CONV = ys, ZCOORD = zs
   
lSurface -> GetProperty, XRANGE = x2range, YRANGE = y2range, ZRANGE = z2range
x2s = NORM_COORD(x2range)
x2s[0] = x2s[0] - 0.5
y2s = NORM_COORD(y2range)
y2s[0] = y2s[0] - 0.5
z2s = NORM_COORD(z2range)
z2s[0] = z2s[0] - 0.5
lSurface -> SetProperty, XCOORD_CONV = x2s, YCOORD_CONV = y2s, ZCOORD = z2s
   

    ; Add the surface objects to the model.

rModel->Add, rSurface
lModel->Add, lSurface

    ; Rotate the surface model to the angled view.

rModel->Rotate,[1,0,0], -90  ; To get the Z-axis vertical.
rModel->Rotate,[0,1,0],  30  ; Rotate it slightly to the right.
rModel->Rotate,[1,0,0],  30  ; Rotate it down slightly.
lModel->Rotate,[1,0,0], -90  ; To get the Z-axis vertical.
lModel->Rotate,[0,1,0],  30  ; Rotate it slightly to the right.
lModel->Rotate,[1,0,0],  30  ; Rotate it down slightly.

lModel->Rotate,[0,1,0],   2  ; Rotate the left view by 2 to create eye separation view

    ; Create the widgets to view the surface. Set expose events
    ; on the draw widget so that it refreshes itself whenever necessary.
    ; Button events are on to enable trackball movement.


tlbControlWindow = Widget_Base(Title='R_eye Texture Surface Example', Column=1, $
                               XOFFSET=300, YOFFSET=10, $
                               TLB_Size_Events=1, TLB_Move_EVENTS=0)
drawID_r = Widget_Draw(tlbControlWindow, XSize=500, YSize=400, Graphics_Level=2, Retain=0, $
                       Expose_Events=1, Event_Pro='Texture_Surface_Draw_Events', Button_Events=1)
tlbPartnerWindow = Widget_Base(Title='L_eye Texture Surface Example', Column=1, $
                               XOFFSET=820, YOFFSET=10, $
                               TLB_Size_Events=1, GROUP_LEADER=tlbControlWindow)
drawID_l = Widget_Draw(tlbPartnerWindow, XSize=500, YSize=400, Graphics_Level=2, Retain=0)

    ; Create Panel with options for changing the view and exiting.

tlbControlPanel = Widget_Base(tlbControlWindow, title='Display Controls', Column=3)
tlbPartnerPanel = Widget_Base(tlbPartnerWindow, title='Display Controls', Column=3, GROUP_LEADER=tlbControlPanel)

;RIGHT
view3dB1 = widget_label(tlbControlPanel, value='3D', uvalue='Dim Button', Event_Pro='Texture_Surface_Panel_Events')
dummy = widget_slider(tlbControlPanel, /drag, uvalue='Eye Separation', $
                      title='Eye Separation', Event_Pro='Texture_Surface_Panel_events', $
                      minimum=0, maximum=10, scroll=1, $
                      value=2)
dummy = widget_button(tlbControlPanel, value='Perspective', uvalue='Push Button', Event_Pro='Texture_Surface_Panel_Events')
dummy = widget_slider(tlbControlPanel, /drag, uvalue='Eye Distance', $ 
                      title='Eye Distance', Event_Pro='Texture_Surface_Panel_events', $
                      minimum=11, maximum=150, scroll=1, $
                      value=16)
dummy = Widget_Button(tlbControlPanel, Value='Anaglyph Off', uvalue='Anaglyph', Event_Pro='Texture_Surface_Panel_events')
dummy = Widget_Button(tlbControlPanel, Value='Exit', Event_Pro='Texture_Surface_Exit')
;LEFT
view3dB2 = widget_label(tlbPartnerPanel, value='3D', uvalue='Dim Button', Event_Pro='Texture_Surface_Panel_Events')
viewSep = widget_slider(tlbPartnerPanel, title='Eye Separation', $
                      minimum=0, maximum=10, scroll=1, $
                      value=2)
viewB = widget_button(tlbPartnerPanel, value='Perspective', uvalue='Push Button')
viewDist = widget_slider(tlbPartnerPanel, title='Eye Distance', $
                      minimum=11, maximum=150, scroll=1, $
                      value=16)
anaglyphB = Widget_Button(tlbPartnerPanel, Value='Anaglyph Off')
dummy = Widget_Button(tlbPartnerPanel, Value='Exit')

   ; Realize the widgets.

Widget_Control, tlbControlWindow, /Realize
Widget_Control, tlbPartnerWindow, /Realize
;Widget_Control, tlbControlPanel, /Realize
;Widget_Control, tlbPartnerPanel, /Realize

    ; Get the window destination object, which is the value of
    ; an object draw widget. The view will be drawn in the window
    ; when the window is exposed.

Widget_Control, drawID_r, Get_Value=rWindow
Widget_Control, drawID_l, Get_Value=lWindow


   ; Create a container object to hold all the other
   ; objects. This will make it easy to free all the
   ; objects when we are finished with the program.

rContainer = Obj_New('IDL_Container')
lContainer = Obj_New('IDL_Container')

   ; Add created objects to the container. No need to add objects
   ; that have been added to the model, since a model object is
   ; a subclass of a container object. But helper objects that
   ; are NOT added to the model directly MUST be destroyed properly.

rContainer->Add, rView
rContainer->Add, thisTrackball
rContainer->Add, rModel
IF Obj_Valid(rImage) THEN rContainer->Add, rImage
IF Obj_Valid(imgpal) THEN rContainer->Add, imgpal
lContainer->Add, lView
lContainer->Add, lModel
IF Obj_Valid(lImage) THEN lContainer->Add, lImage
IF Obj_Valid(imgpal) THEN lContainer->Add, imgpal


   Window, XSize=500, YSize=400, /Pixmap, /Free
   pixmapID = !D.Window
   

   ; INFO structure to hold program information.

info = { tlbControlWindow:tlbControlWindow, $
         tlbPartnerWindow:tlbPartnerWindow, $
         rContainer:rContainer, $ ; The object container.
         lContainer:lContainer, $ ; The object container.
         rWindow:rWindow, $       ; The window object.
         lWindow:lWindow, $       ; The window object.
         rSurface:rSurface, $     ; The surface object.
         lSurface:lSurface, $     ; The surface object.
         thisTrackball:thisTrackball, $ ; The trackball object.
         rModel:rModel, $         ; The model object.
         lModel:lModel, $         ; The model object.
         rView:rView, $           ; The view object.
         lView:lView, $           ; The view object.
         eyeDist:eyeDist, $         ; eyepoint distance to viewplane
         lModelRotateValue:2, $
         view3DB1:view3DB1, $
         view3DB2:view3DB2, $
         viewB:viewB, $
         anaglyphB:anaglyphB, $
         viewSep:viewSep, $
         viewDist:viewDist, $
         drawID_r:drawID_r, $               ; The widget identifier of the draw widget.
         drawID_l:drawID_l}                ; A flag for vector output.

   ; Store the info structure in the UValue of the tlbControlWindow.
Widget_Control, tlbControlWindow, Set_UValue=info, /No_Copy
;Widget_Control, tlbControlPanel, Set_UValue=info, /No_Copy

   ; Call XManager. Set a cleanup routine so the objects
   ; can be freed upon exit from this program.

XManager, 'texture_surface', tlbControlWindow, Cleanup='Texture_Surface_Cleanup', /No_Block, $
   Event_Handler='Texture_Surface_Resize', Group_Leader=groupLeader
END
;END PRO: TEST 3   -------------------------------------------------------------------




;EVENT HANDLER: Texture_Surface_Draw_Events   ----------------------------------------
PRO Texture_Surface_Draw_Events, event

     ; Draw widget events handled here: expose events and trackball
     ; events. The trackball uses RSI-supplied TRACKBALL oject.
   
   Widget_Control, event.top, Get_UValue=info, /No_Copy
   
   drawTypes = ['PRESS', 'RELEASE', 'MOTION', 'SCROLL', 'EXPOSE']
   thisEvent = drawTypes(event.type)
   
   CASE thisEvent OF
   
      'EXPOSE':  ; Nothing required except to draw the view.
      'PRESS': Widget_Control, event.id, Draw_Motion_Events=1 ; Motion events ON.
      'RELEASE': Widget_Control, event.id, Draw_Motion_Events=0 ; Motion events OFF.
      'MOTION':  ; Just update trackball.
      ELSE:
   
   ENDCASE
   
      ; Does the trackball need updating? If so, update.
   needUpdate = info.thisTrackball->Update(event, Transform=thisTransform)
   IF needUpdate THEN BEGIN
      info.rModel->GetProperty, Transform=rmodelTransform
      info.rModel->SetProperty, Transform=rmodelTransform # thisTransform
      info.lModel->GetProperty, Transform=lmodelTransform
      info.lModel->SetProperty, Transform=lmodelTransform # thisTransform
   ENDIF
   
       ; Draw the view.
   info.rWindow->Draw, info.rView
   info.lWindow->Draw, info.lView
   showAnaglyph, info
   
       ;Put the info structure back.
   
   Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;EVENT HANDLER: Texture_Surface_Draw_Events   ------------------------------------------




;EVENT HANDLER: Texture_Surface_Resize   -------------------------------------------
PRO Texture_Surface_Resize, event

   Widget_Control, event.top, Get_UValue=info, /No_Copy
   
   
   WIDGET_CONTROL, info.tlbControlWindow, TLB_GET_SIZE=windowSize
   WIDGET_CONTROL, info.tlbControlWindow, TLB_GET_OFFSET=lWindowOffset
   WIDGET_CONTROL, info.tlbPartnerWindow, TLB_SET_YOFFSET=lWindowOffset[1], $
              TLB_SET_XOFFSET=lWindowOffset[0] + windowsize[0] + 20, XSIZE=windowSize[0], YSIZE=windowSize[1] + 25
                                          ; modify ^^ when using two monitors
   info.rWindow->SetProperty, Dimension=[event.x - 6, event.y - 58]
   info.lWindow->SetProperty, Dimension=[event.x - 6, event.y - 58]
   
       ; Redisplay the graphic.
   
   info.rWindow->Draw, info.rView
   info.lWindow->Draw, info.lView
   showAnaglyph, info, event.x - 6, event.y - 58
   
       ; Update the trackball objects location in the center of the
       ; window.
   
   info.thisTrackball->Reset, [event.x/2, event.y/2], $
       (event.y/2) < (event.x/2)
   
       ;Put the info structure back.
   
   Widget_Control, event.top, Set_UValue=info, /No_Copy
END
;EVENT HANDLER: Texture_Surface_Resize   -------------------------------------------




;EVENT HANDLER: Texture_Surface_Panel_Events   ---------------------------------------------
PRO Texture_Surface_Panel_Events, event

   Widget_Control, event.top, Get_UValue=info, /No_Copy
   
   Widget_Control, event.id, Get_UValue=value
   CASE value OF
   
      'Eye Separation': Begin
         info.lModel->Rotate,[0,1,0], event.value - info.lModelRotateValue
         info.lModelRotateValue = event.value
         Widget_Control, info.viewSep, Set_value=event.value
         Widget_Control, info.view3dB1, Get_value=text
         if event.value eq 0 then begin
            Widget_Control, info.view3DB1, Set_value = '2D'
            Widget_Control, info.view3DB2, Set_value = '2D'
         end else begin
            Widget_Control, info.view3DB1, Set_value = '3D'
            Widget_Control, info.view3DB2, Set_value = '3D'
         endelse
      ENDCASE
      'Push Button': Begin
         Widget_Control, event.id, Get_Value=buttonText
         If buttonText EQ 'Perspective' then begin
            Widget_Control, event.id, Set_Value='Parallel'
            info.rView->SetProperty, PROJECTION = 1  
            info.lView->SetProperty, PROJECTION = 1  
            Widget_Control, info.viewB, Set_value='Parallel'
         endif else begin
            Widget_Control, event.id, Set_Value='Perspective'
            info.rView->SetProperty, PROJECTION = 2  
            info.lView->SetProperty, PROJECTION = 2  
            Widget_Control, info.viewB, Set_value='Perspective'
         endelse
      ENDCASE
      'Eye Distance': Begin
         info.eyeDist = event.value / 10.0
         info.lView->SetProperty, EYE = info.eyeDist
         info.rView->SetProperty, EYE = info.eyeDist
         Widget_Control, info.viewDist, Set_value=event.value
      ENDCASE
      'Anaglyph': Begin
         Widget_Control, event.id, Get_Value=buttonText
         If buttonText EQ 'Anaglyph Off' then begin
            Widget_Control, event.id, Set_Value='Anaglyph On'
            info.rWindow->GetProperty, Image_Data=snapshot
            window,1,xsize=N_ELEMENTS(snapshot[0,*,0]),ysize=N_ELEMENTS(snapshot[0,0,*])
            Widget_Control, info.anaglyphB, Set_value='Anaglyph On'
         endif else begin
            Widget_Control, event.id, Set_Value='Anaglyph Off'
            wdelete,1
            Widget_Control, info.anaglyphB, Set_value='Anaglyph Off'
         endelse
      ENDCASE
      
   ENDCASE
   
   info.rWindow->Draw, info.rView
   info.lWindow->Draw, info.lView
   showAnaglyph, info
   
   Widget_Control, event.top, Set_UValue=info, /No_Copy

END
;EVENT HANDLER: Texture_Surface_Panel_Events   ---------------------------------------------




;EVENT HANDLER: Texture_Surface_Exit   ---------------------------------------------
PRO Texture_Surface_Exit, event
   Widget_Control, event.top, /Destroy      
END
;EVENT HANDLER: Texture_Surface_Exit   ---------------------------------------------




;CLEANUP-------------------------------------------------------------------
Pro Texture_Surface_Cleanup, tlb
   Widget_Control, tlb, Get_UValue=info
   IF N_Elements(info) NE 0 THEN Obj_Destroy, info.rContainer
END
;CLEANUP-------------------------------------------------------------------




;SHOWANAGLYPH-------------------------------------------------------------------
Pro showAnaglyph, info, x, y ;X and Y are optional for resizing window
   Widget_Control, info.anaglyphB, Get_Value=buttonText
   if buttonText eq 'Anaglyph On' then begin

      ;CREATE ANAGLYPH IMAGE IN SEPARATE WINDOW
      info.rWindow->GetProperty, Image_Data=snapshot ;Add buffering of image later for crosshair display
      info.lWindow->GetProperty, Image_Data=snapshotRed ;Add buffering of image later for crosshair display
      ;help, snapshot
      snapshot[0,*,*] = snapshotRed[0,*,*]
      
      IF N_Elements(x) gt 0 THEN window,1,xsize=x,ysize=y

      tv, snapshot, true=1
   endif
END
;END SHOWANAGLYPH-------------------------------------------------------------------