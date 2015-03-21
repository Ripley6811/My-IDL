;In this program I will set up two xobjview windows 
;side by side that can be moved together
;Also set up a panel for slide controls, view separation angles



PRO EditorKilled, widgetID

   WIDGET_CONTROL, GET_UVALUE = state, widgetID, /NO_COPY

   ; If the Editor could be closed via the window manager, you would
   ; need to add a request here for the user to save any changes they
   ; might have made.  Currently the only way to close this editor
   ; is through the "Exit Editor" menu command.

   ; No need to reset the user value since it will no longer be used
END




PRO WindowEventHdlr, event

  thisEvent = Tag_Names(event, /Structure_Name)
;  print, thisEvent, event.id
;  help, event, /struct
  
     ; Get the state structure stored in the user value of the window
   WIDGET_CONTROL, GET_UVALUE = state, event.top, /NO_COPY

     ; Determine in which widget the event occurred
   CASE event.id OF

      state.wControlWindow: BEGIN ; The window has been sized
           ; Get the new size of the window
         WIDGET_CONTROL, state.wControlWindow, TLB_GET_SIZE=windowSize

           ; Determine the change in the window size
         deltaX = windowSize[0] - state.windowSize[0]
         deltaY = windowSize[1] - state.windowSize[1]


          ; Store the new size in the state structure for later comparisons
         WIDGET_CONTROL, state.wControlWindow, TLB_GET_SIZE=windowSize
         state.windowSize = windowSize
         
         ;;;;;;;;;;;;;;;
          ; Get the new position of window
         WIDGET_CONTROL, state.wControlWindow, TLB_GET_OFFSET=windowOffset
         
          ; Determine the change in the window position
         deltaXoff = windowOffset[0]
         deltaYoff = windowOffset[1]
;         print, 'new pos= ', windowOffset


         WIDGET_CONTROL, state.wPartnerWindow, TLB_SET_YOFFSET=deltaYoff, $
           TLB_SET_XOFFSET=deltaXoff + state.windowsize[0] + 20, XSIZE=state.windowSize[0], YSIZE=state.windowSize[1]
                                       ; modify ^^ when using two monitors
          
      ENDCASE



      state.draw1: BEGIN
            ;if pressed then first calculate all changes
         if(thisevent ne 'WIDGET_TRACKING') then begin
            if(event.press eq 1) then begin
               state.drag[4] = 1
               state.drag[0] = event.x
               state.drag[2] = event.y
            end
            if(event.release eq 1) then begin
               state.drag[4] = 0
               state.viewAngle[0] = (state.viewAngle[0] + state.drag[1] - state.drag[0]) mod 360
               state.viewAngle[1] = (state.viewAngle[1] + state.drag[1] - state.drag[0]) mod 360
               state.viewAngle[2] = (state.viewAngle[2] - state.drag[3] + state.drag[2]) mod 360
               print, state.viewAngle
            end
;            print, 'mousedown', state.drag[4]
            if(state.drag[4] eq 1) then begin
               state.drag[1] = event.x
               state.drag[3] = event.y
               wset, state.pixmapID
               ERASE
               SHADE_SURF, state.marbells, AZ=state.viewAngle[0] + state.drag[1] - state.drag[0], $
                                        AX=state.viewAngle[2] - state.drag[3] + state.drag[2]
               wset, state.index1
               Device, Copy=[0, 0,state.windowsize[0], state.windowsize[1], 0, 0, state.pixmapID]
               wset, state.pixmapID
               ERASE
               SHADE_SURF, state.marbells, AZ=state.viewAngle[1] + state.drag[1] - state.drag[0], $
                                        AX=state.viewAngle[2] - state.drag[3] + state.drag[2]
               wset, state.index2
               Device, Copy=[0, 0,state.windowsize[0], state.windowsize[1], 0, 0, state.pixmapID]
            end else begin
               wset, state.pixmapID
               ERASE
               SHADE_SURF, state.marbells, AZ=state.viewAngle[1], $
                                        AX=state.viewAngle[2]
               wset, state.index2
               Device, Copy=[0, 0,state.windowsize[0], state.windowsize[1], 0, 0, state.pixmapID]
            endelse
            mx = event.x
            my = event.y
            if(event.type eq 7 and event.clicks ne 0) then $
               state.cursor_offset = state.cursor_offset + event.clicks
               if( state.cursor_offset lt 0 ) then state.cursor_offset = 0
               if( state.cursor_offset gt 20 ) then state.cursor_offset = 20
;            print, mx, my, event.clicks, state.cursor_offset
            plots, [mx - 15 + state.cursor_offset,mx + 15 + state.cursor_offset], [my, my], /DEVICE, $
            COLOR = !D.N_COLORS
            plots, [mx + state.cursor_offset, mx + state.cursor_offset], [my - 15,my + 15], /DEVICE, $
            COLOR = !D.N_COLORS
            for i=-14,14,2 do begin
               plots, [mx + i + state.cursor_offset,mx + i + state.cursor_offset], [my, my], /DEVICE, $
               COLOR = !D.N_COLORS-1
               plots, [mx + state.cursor_offset, mx + state.cursor_offset], [my + i,my + i], /DEVICE, $
               COLOR = !D.N_COLORS-1
            endfor
         endif

      ENDCASE

      state.wExitButton: BEGIN
           ; If any text changed in the text editor -
           ; request that the user save the changes first
         RequestToSave, state

           ; Restore the state value before the widget app is destroyed
           ; so the KILL_NOTIFY procedure can still use it
         WIDGET_CONTROL, SET_UVALUE = state, event.top, /NO_COPY

           ; Exit the IDL Editor widget application
         WIDGET_CONTROL, event.top, /DESTROY

         RETURN

      ENDCASE






;      ELSE: $ ; We erroneously received an event for a widget we weren't expecting
;         buttonPushed = DIALOG_MESSAGE("An event occurred for a non-existent widget")
;
      ENDCASE

     ; Reset the windows user value to the updated state structure
   WIDGET_CONTROL, event.top, SET_UVALUE = state, /NO_COPY

END


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO Test2, fileName, WIDTH = WIDTH, HEIGHT = HEIGHT, FONT = font, GROUP = group

   IF LMGR(/DEMO) THEN BEGIN
      void = DIALOG_MESSAGE( $
         ['IDL is in timed demo mode.', $
          'Because IDL is in timed demo mode,', $
          'you will not be able to save changes', $
          'made with this editor.'])
   ENDIF
   
   ; Get Monitor information
   oInfo = OBJ_NEW('IDLsysMonitorInfo')
   numMons = oinfo->GetNumberOfMonitors()
   names = oinfo->GetMonitorNames()
   rects = oInfo->GetRectangles()
   primaryIndex = oInfo->GetPrimaryMonitorIndex()
;   print, rects
   OBJ_DESTROY, oInfo
   
   ; Read image for splash screen
   
   
   ; Compute splash screen parameters
   ; Just offset it based on first window
   primaryRect = [0, -1024, 1280, 1024]
   viewSize = [540,400]
;   print, 'viewSize=', viewSize
   viewLoc = [300, -1024]



     ; If keywords not set - set to defaults
   IF (NOT(KEYWORD_SET(height))) THEN $
      height = 24
   IF (NOT(KEYWORD_SET(width))) THEN $
      width = 80

     ; Create the two windows editor window
   wControlWindow = WIDGET_BASE(/COL,$
      XOFFSET=viewLoc[0], YOFFSET=viewLoc[1], $
      TLB_Size_Events = 1, $
      /TLB_Move_EVENTS, $
      TITLE='wControlWindow', $
      XSIZE=viewSize[0], YSIZE=viewSize[1])
;   wControlWindow -> OnMouseMotion, 
;   xobjview, /test, TLB=wControlWindow1, /modal, group = wControlWindow
   draw1 = WIDGET_DRAW(wControlWindow, /MOTION_EVENTS, /WHEEL_EVENTS, $
      /BUTTON_EVENTS, /TRACKING_EVENTS, $
      XSIZE=viewSize[0], YSIZE=viewSize[1])
   wPartnerWindow = WIDGET_BASE(/COL, $
      GROUP_LEADER=wControlWindow, $
      XOFFSET=viewLoc[0]+viewsize[0]+20, YOFFSET=viewLoc[1], $
      TITLE='wPartnerWindow', $
      XSIZE=viewSize[0], YSIZE=viewSize[1])
   draw2 = WIDGET_DRAW(wPartnerWindow, $
      XSIZE=viewSize[0], YSIZE=viewSize[1])
   
; CREATE OBJ AND VIEW
demFile = FILEPATH('elevbin.dat', $
   SUBDIRECTORY = ['examples', 'data'])

; Importing data.
dem = READ_BINARY(demFile, DATA_DIMS = [64, 64])
dem = CONGRID(dem, 128, 128, /INTERP)
   MARBELLS=CONGRID(dem,35,45)


; Put up splash
   WIDGET_CONTROL, wControlWindow, /REALIZE
   WIDGET_CONTROL, draw1, GET_VALUE=index1   ;create a name to refer to the window
   WIDGET_CONTROL, wPartnerWindow, /REALIZE
   WIDGET_CONTROL, draw2, GET_VALUE=index2
   LOADCT, 0
   WSET, index1   ;Set the output window
;   DEVICE, GET_DECOMPOSED=decomp

   viewAngle = [0,2, 20]
   DEVICE, RETAIN=2, DECOMPOSED=0
   SHADE_SURF, MARBELLS, AZ=viewAngle[0], AX=viewAngle[2]


   WSET, index2
;   DEVICE, GET_DECOMPOSED=decomp
   DEVICE, RETAIN=2, DECOMPOSED=0
   SHADE_SURF, MARBELLS, AZ=viewAngle[1], AX=viewAngle[2]
   
   Window, XSize=viewsize[0], YSize=viewsize[1], /Pixmap, /Free
   pixmapID = !D.Window
 


     ; Save the widget ids and other parameters to be accessed throughout
     ; this widget application.  This state structure will be stored
     ; in the user value of the window and can be retreived through the
     ; GET_UVALUE keyword of the IDL WIDGET_CONTROL procedure
   state = { $
             wControlWindow : wControlWindow, $
             wPartnerWindow : wPartnerWindow, $
             draw1 : draw1, $
             draw2 : draw2, $
             index1 : index1, $
             marbells : marbells, $
             viewAngle : viewAngle, $  ;azRight, azLeft, axBoth
             index2 : index2, $
             cursor_offset : 3, $
             pixmapID : pixmapID, $
             rects : rects, $
             windowSize : [viewsize[0],viewsize[1]], $
             windowOffset : [0,0], $
             drag : [0,0,0,0,0] $     ;az0, az1, ax0, ax1, on/off
           }

     ; Make the window visible
   WIDGET_CONTROL, wControlWindow, /REALIZE



     ; Get the current window size to be used when the user resizes the window
   WIDGET_CONTROL, wControlWindow, TLB_GET_SIZE=windowSize

     ; Save it in the state structure
   state.windowSize = windowSize
;   print, 'WindowSize= ',windowsize

     ; Get the current window offset
   WIDGET_CONTROL, wControlWindow, TLB_GET_OFFSET=windowOffset
   state.windowOffset = windowOffset
;   print, 'Offset= ',windowOffset

     ; Save the state structure in the window's user value
   WIDGET_CONTROL, wControlWindow, SET_UVALUE=state

     ; Register this widget application with the widget manager
   Xmanager, "Editor", wControlWindow, GROUP_LEADER=group, $
     EVENT_HANDLER="WindowEventHdlr", CLEANUP="EditorKilled", /NO_BLOCK

END  ;--------------------- procedure ----------------------------
