Pro Widget_Plot
   ;RESTORE THE CORE FILE AND START ENVI IN BATCH
   ;envi, /restore_base_save_files
   ;envi_batch_init, log_file ='batch.log'

; Creating the top-level base widget
  Tlb = Widget_Base(Column = 2, TLB_Size_Events = 1, Title = 'Plot MS700', $
    MBar = menubarID)
  ; Define the drop-down Menu
  FileID = Widget_Button(menubarID, Value = 'File', /Menu)
  OpenID = Widget_Button(FileID, Value = 'Open', Event_Pro = 'Widget_Plot_Open')
  QuitID = Widget_Button(FileID, Value = 'Quit', Event_Pro = 'Widget_Plot_Quit')

  SelectID = Widget_Button(menubarID, Value = 'Select', /Menu)
  TimeID = Widget_Button(SelectID, Value = 'Time', Event_Pro = 'Widget_Plot_Time')

  HelpID = Widget_Button(menubarID, Value = 'Help', /Menu)
  AboutID = Widget_Button(HelpID, Value = 'About', Event_Pro = 'Widget_Plot_About')

  DrawID = Widget_Draw(Tlb, XSize = 720L, YSize = 405L)
  
  C1R1Tlb = Widget_Base(Tlb, Row = 1)
  LabelID = Widget_Label(C1R1Tlb, Value = 'Time')
  ComboboxID = Widget_Combobox(C1R1Tlb, /dynamic_resize, /editable)
  
  C2R1Tlb = Widget_Base(Tlb, Row = 1)
  PlotID = Widget_Button(C2R1Tlb, Value = 'Plot', Event_Pro = 'Widget_Plot_Plot')
  LabelID = Widget_Label(C2R1Tlb, Value = 'C2R1')
  
  C2R2Tlb = Widget_Base(Tlb, Row = 1)
  LabelID = Widget_Label(C2R2Tlb, Value = 'C2R2')
  
; Realizing the widgets on the display
  Widget_Control, TLB, /Realize
  
  ; Get the window index number of the draw widget window. Make it active.
  Widget_Control, DrawID, Get_Value=wid
  WSet, wid
; Create a pixmap window for "double buffering". This technique will avoid window flashing as graphics are redrawn in the window.
  Window, XSize=720L, YSize=405L, /Pixmap, /Free
  pixmapID = !D.Window
  
  ; Initialize
; restore the presaved ascii template of the data file
  TemplateName = 'D:\Class_ENVI_IDL\Homework2\CR1000_ms700_Template'
  restore, TemplateName
  FileName = 'D:\Class_ENVI_IDL\Homework2\CR1000_ms700.dat'
; read the data file
  Data = read_ascii(FileName,template = MyTemplate)
; decide which data to plot
  Index = 0L
; Create the info structure with the information required to run the program.
  info = { $
    Data:Data, $          ; A pointer to data
    FileName:FileName, $             ; The full path of data file
    TemplateName:TemplateName, $             ; The full path of Template
    Index:Index, $       ; Index of Data to plot
    DrawID:DrawID, $                 ; The identifier of the draw widget.
    wid:wid, $                       ; The window index number of the graphics window.
    pixmapID:pixmapID $              ; The window index number of the pixmap.
  }
  
  ; Set ComboBox values
  Widget_Control, ComboboxID, Set_Value=Data.Field001

; Store the info structure in the user value of the TLB. Turn keyboard focus events on.
  Widget_Control, Tlb, Set_UValue=info, /No_Copy, /KBRD_Focus_Events
  

  
  
  

; Set up the event loop. Register the program with the window manager.
  XManager, 'Widget_Plot', Tlb, Event_Handler='Widget_Plot_TLB_Events', $
    /No_Block, Cleanup='Widget_Plot_Cleanup', Group_Leader=group_leader
end


Pro Widget_Plot_Quit, Event
  Widget_Control, event.top, /Destroy
End 
Pro Widget_Plot_About, Event
  
End
Pro Widget_Plot_Open, Event
  FileName = pickfile(Title = 'Please select data file')
End 
PRO Widget_Plot_Cleanup, Tlb
; The purpose of this procedure is to clean up pointers,
; objects, pixmaps, and other things in our program that
; use memory. This procedure is called when the top-level
; base widget is destroyed.
  Widget_Control, tlb, Get_UValue=info, /No_Copy
  if N_Elements(info) eq 0 then return
end
;;;;;;;;;;;;;;;;;;;TLB EVENTS;;;;;;;;;;;;;;;;;;;;;;;
Pro Widget_Plot_TLB_Events, Event
; This event handler responds to keyboard focus and resize events.
  thisEvent = Tag_Names(event, /Structure_Name)
  print, thisEvent
    if ((thisEvent eq 'WIDGET_COMBOBOX')) then begin
; Get the info structure and copy it here.
    Widget_Control, event.top, Get_UValue=info, /No_Copy
    if (Event.index ne -1) then info.Index = Event.index 
; Plot
    WSet, info.pixmapID
    PlotR, info.Data, info.Index, info.FileName+info.Data.Field001[info.Index]
; Copy the pixmap to the display window.
    WSet, info.wid
    Device, Copy=[0, 0,720.0, 405.0, 0, 0, info.pixmapID]
; Put the info structure back in its storage location.
    Widget_Control, event.top, Set_UValue=info, /No_Copy
  endif
end

Pro PlotR, Data, Index, FileName 
; initialize
  Eu = fltarr(256)
  Ed = fltarr(256)
  WaveLength = fltarr(256)
  for i = 0L, 255L do begin
    WaveLength[i] = 350.0 + i * (1050.0 - 350.0) / 256.0
  endfor
; assign the data to plot
  FieldName = tag_names(Data)
  for i = 0L, 256L-1L do begin
    Ed[i] = Data.(i+21)[Index]
    Eu[i] = Data.(i+277)[Index]
  endfor
; plot spectra
  bands = where((Ed ne 0.0) and (WaveLength le 700.0) and (WaveLength gt 400.0))
  plot, WaveLength(bands), Eu(bands)/Ed(bands), xtitle = 'Wavelength (nm)', ytitle = 'Reflectance (%)', xrange = [400.0, 700.0], yrange = [0.0, max(Eu(bands)/Ed(bands))], Title = FileName, font = 1
end
