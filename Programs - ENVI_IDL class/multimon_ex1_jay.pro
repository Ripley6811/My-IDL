; Event handler for shutdown.
PRO multimon_ex1_event, ev
  thisEvent = Tag_Names(ev, /Structure_Name)
  print, thisEvent
   WIDGET_CONTROL, ev.top, GET_UVALUE=pState
   WIDGET_CONTROL, ev.id, GET_UVALUE=uval
   CASE uval OF
      "EXIT": BEGIN
         DEVICE, DECOMPOSED=(*pState).decomp
         base = (*pState).wBase
         PTR_FREE, pState
         WIDGET_CONTROL, base, /DESTROY
      ENDCASE
      "WIDGET_BASE": BEGIN
         print,'yay'
      ENDCASE
   ELSE :
   ENDCASE
END


PRO multimon_ex1_Jay

   ; Get Monitor information
   oInfo = OBJ_NEW('IDLsysMonitorInfo')
   help, oInfo
   print, oInfo
   numMons = oinfo->GetNumberOfMonitors()
   print, numMons, ' monitors'
   names = oinfo->GetMonitorNames()
   help, names
   print, names
   rects = oInfo->GetRectangles()
   help, rects
   print, rects
   primaryIndex = oInfo->GetPrimaryMonitorIndex()
   help, primaryIndex
   print, primaryIndex
   print, oInfo->IsExtendedDesktop()
   OBJ_DESTROY, oInfo

   ; Read image for splash screen
   image1File = 'C:\Users\Jay\Desktop\im_left.JPG'
   image2File = 'C:\Users\Jay\Desktop\im_right.JPG'
   READ_JPEG,image1File, image1
   READ_JPEG,image2File, image2
   help, image1
   
   ;window, 1
   ;tvscl, image1[0,*,*]

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

   ; Define a message to display int he "main" GUI
   textblock = [" This example application displays a splash screen", $
                " on the system's primary monitor and this interface", $
                " on the highest numbered monitor available."]

   ; Set up "main" GUI to display at [100,100] on the nth monitor
;   main = WIDGET_BASE(/COL, DISPLAY_NAME=names[numMons-1], $
;      XOFFSET=rects[0, numMons-1] + 100, $
;      YOFFSET=rects[1, numMons-1] + 100, $
;      TLB_Size_Events = 1, $
;      /TLB_Move_EVENTS, $
;      TITLE='Main')
;   text = WIDGET_TEXT(main, VALUE=textblock, $
;      XSIZE=STRLEN(textblock[1]), YSIZE=5)
;   button = WIDGET_BUTTON(main, VALUE='Exit', UVALUE='EXIT')

   ; Set up splash screen 1
   splash1 = WIDGET_BASE(/COL, DISPLAY_NAME=names[primaryIndex], $
      ;GROUP_LEADER=main, $
      ;TLB_FRAME_ATTR = 1+2+4+8+16, $   ;covers the title bar(?), turns window into a simple frame
      XOFFSET=splash1Loc[0], YOFFSET=splash1Loc[1], $
      TLB_Size_Events = 1, $
      /TLB_Move_EVENTS, $
      TITLE='Splash Screen 1')
   draw1 = WIDGET_DRAW(splash1, $
      XSIZE=splash1Size[1], YSIZE=splash1Size[2])
   ; Set up splash screen 2
   splash2 = WIDGET_BASE(/COL, DISPLAY_NAME=names[primaryIndex+1], $
      GROUP_LEADER=splash1, $
      ;TLB_FRAME_ATTR = 1+2+4+8+16, $   ;covers the title bar(?), turns window into a simple frame
      XOFFSET=splash2Loc[0], YOFFSET=splash2Loc[1], $
      TITLE='Splash Screen 2')
   draw2 = WIDGET_DRAW(splash2, $
      XSIZE=splash2Size[1], YSIZE=splash2Size[2])
      
      
   help, splash1

   ; Put up splash
   WIDGET_CONTROL, splash1, /REALIZE
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

   ; Pause with just splash screen up, then start main GUI.
   ;WAIT, 2
   ;WIDGET_CONTROL, main, /REALIZE
   ; A real application would probably remove the splash
   ; screen after realizing the main GUI:
   ; WIDGET_CONTROL, splash, /DESTROY

   sState = {wBase: splash1, decomp: decomp}
   pState = PTR_NEW(sState, /NO_COPY)
   WIDGET_CONTROL, splash1, SET_UVALUE=pState
   XMANAGER, 'multimon_ex1', splash1
   ;XManager, 'multimon_ex1', splash1, Event_Handler='Widget_Plot_MS_EVENTS'

END
