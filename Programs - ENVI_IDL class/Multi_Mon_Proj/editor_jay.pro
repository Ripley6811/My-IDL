; $Id: //depot/idl/IDL_70/idldir/examples/widgets/editor.pro#1 $
;
; Copyright (c) 1995-2007, ITT Visual Information Solutions. All
;       rights reserved.
;+
; NAME: Editor Jay
;
; PURPOSE: display a matching window bound to the position of the first
;
; MAJOR TOPICS: Multiple monitor example
;
; CALLING SEQUENCE: Editor [, filename]
;
; INPUTS:
;
; KEYWORD PARAMETERS:
;
; PROCEDURE: 
;
; MAJOR FUNCTIONS and PROCEDURES:
;
; COMMON BLOCKS and STRUCTURES:
;
; SIDE EFFECTS:
;   Triggers the XMANAGER if it is not already in use.
;
; MODIFICATION HISTORY:  Written by:  WSO, RSI, January 1995
;                        Modified by: Jay W Johnson
;-





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
  print, thisEvent
  
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
         WIDGET_CONTROL, state.splash2, TLB_GET_OFFSET=windowOffset2
         
          ; Determine the change in the window position
         deltaXoff = windowOffset[0]
         deltaYoff = windowOffset[1]
         print, 'new pos= ', windowOffset

         WIDGET_CONTROL, state.wControlWindow, TLB_SET_YOFFSET=windowOffset[1], $
           TLB_SET_XOFFSET=windowOffset[0]
           ;print, 'hello', rects[*,1]
         WIDGET_CONTROL, state.splash2, TLB_SET_YOFFSET=state.rects[1,1] + deltaYoff, $
           TLB_SET_XOFFSET=state.rects[0,1] + deltaXoff
          
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






      ELSE: $ ; We erroneously received an event for a widget we weren't expecting
         buttonPushed = DIALOG_MESSAGE("An event occurred for a non-existent widget")

      ENDCASE

     ; Reset the windows user value to the updated state structure
   WIDGET_CONTROL, SET_UVALUE = state, event.top, /NO_COPY

END

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PRO editor_jay, fileName, WIDTH = WIDTH, HEIGHT = HEIGHT, FONT = font, GROUP = group

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
   OBJ_DESTROY, oInfo
   
   ; Read image for splash screen
   image1File = 'D:\Class_ENVI_IDL\Multi_Mon_Proj\world_dem'
   image2File = 'D:\Class_ENVI_IDL\Multi_Mon_Proj\world_dem'
   ;image1File = 'C:\Users\Jay\Desktop\im_left.JPG'
   ;image2File = 'C:\Users\Jay\Desktop\im_right.JPG'
;   READ_JPEG,image1File, image1
;   READ_JPEG,image2File, image2
   dem = READ_BINARY(image1File, DATA_DIMS = [2164, 2164])
   ;dem = CONGRID( dem, 128,128, /INTERP)   ; Enlarges the elevation for better display
   
   device, decomposed = 0
   window, 0, title = 'Elevation Data'
   shade_surf, dem
   
   
   ; Compute splash screen parameters
   primaryRect = rects[*, primaryIndex]
   secondRect = rects[*, primaryIndex+1]
   splash1Size = SIZE(image1, /DIMENSIONS)
   print, 'splash1Size=', splash1Size
   splash2Size = SIZE(image2, /DIMENSIONS)
   splash1Loc = primaryRect[0:1] + primaryRect[2:3] $  ;2-digit array for monitor location
      / 2 - splash1Size[1:2] / 2
   splash2Loc = secondRect[0:1] + secondRect[2:3] $
      / 2 - splash2Size[1:2] / 2



     ; If keywords not set - set to defaults
   IF (NOT(KEYWORD_SET(height))) THEN $
      height = 24
   IF(NOT(KEYWORD_SET(width))) THEN $
      width = 80

     ; Create the two windows editor window with a menu bar
   wControlWindow = WIDGET_BASE(/COL, DISPLAY_NAME=names[primaryIndex], $
      XOFFSET=splash1Loc[0], YOFFSET=splash1Loc[1], $
      TLB_Size_Events = 1, $
      /TLB_Move_EVENTS, $
      TITLE='Splash Screen 1')
   draw1 = WIDGET_DRAW(wControlWindow, $
      XSIZE=splash1Size[1], YSIZE=splash1Size[2])
   ; Set up splash screen 2
   splash2 = WIDGET_BASE(/COL, DISPLAY_NAME=names[primaryIndex+1], $
      GROUP_LEADER=wControlWindow, $
      XOFFSET=splash2Loc[0], YOFFSET=splash2Loc[1], $
      TITLE='Splash Screen 2')
   draw2 = WIDGET_DRAW(splash2, $
      XSIZE=splash2Size[1], YSIZE=splash2Size[2])
      


; Put up splash
   WIDGET_CONTROL, wControlWindow, /REALIZE
   WIDGET_CONTROL, draw1, GET_VALUE=index1   ;create a name to refer to the window
   WIDGET_CONTROL, splash2, /REALIZE
   WIDGET_CONTROL, draw2, GET_VALUE=index2
   WSET, index1   ;Set the output window
   DEVICE, GET_DECOMPOSED=decomp
   DEVICE, DECOMPOSED=0
   ;TVLCT, r, g, b
   ;order = 0
   ;IF orientation EQ 0 OR orientation EQ 4 THEN $
   ;   order = 1
   TV, image1[0,*,*];, ORDER=order
   WSET, index2
   DEVICE, GET_DECOMPOSED=decomp
   DEVICE, DECOMPOSED=0
   ;TVLCT, r, g, b
   ;order = 0
   ;IF orientation EQ 0 OR orientation EQ 4 THEN $
   ;   order = 1
   TV, image2[0,*,*];, ORDER=order
 


     ; Save the widget ids and other parameters to be accessed throughout
     ; this widget application.  This state structure will be stored
     ; in the user value of the window and can be retreived through the
     ; GET_UVALUE keyword of the IDL WIDGET_CONTROL procedure
   state = { $
             wControlWindow : wControlWindow, $
             splash2 : splash2, $
             rects : rects, $
             windowSize : [0,0], $
             windowOffset : [0,0], $
             fileName : "Untitled" $
           }

     ; Make the window visible
   WIDGET_CONTROL, wControlWindow, /REALIZE



     ; Get the current window size to be used when the user resizes the window
   WIDGET_CONTROL, wControlWindow, TLB_GET_SIZE=windowSize

     ; Save it in the state structure
   state.windowSize = windowSize
   print, 'WindowSize= ',windowsize

     ; Get the current window offset
   WIDGET_CONTROL, wControlWindow, TLB_GET_OFFSET=windowOffset
   state.windowOffset = windowOffset
   print, 'Offset= ',windowOffset

     ; Save the state structure in the window's user value
   WIDGET_CONTROL, wControlWindow, SET_UVALUE=state

     ; Register this widget application with the widget manager
   Xmanager, "Editor", wControlWindow, GROUP_LEADER=group, $
     EVENT_HANDLER="WindowEventHdlr", CLEANUP="EditorKilled", /NO_BLOCK

END  ;--------------------- procedure Editor ----------------------------
