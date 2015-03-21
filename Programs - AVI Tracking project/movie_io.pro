; This file contains functions for movie input/output
; For using include it to your program as @movie_io

; THESE IDL ROUTINES ARE PROVIDED TO YOU "AS IS," WITHOUT WARRANTY.
; Copyright (c) 2000-2005, Oleg Kornilov (oleg.kornilov@mail.ru)
;
; AVI OPERATIONS USES CALL_EXTERNAL() AND WINDOWS AVI FUNCTIONS, SO JUST WINDOWS.
; ALSO IT'S NECESSARY TO HAVE INSTALLED VIDEO CODECS ON OPERATING SYSTEM.
; SOME CODECS DEMANDS TRUE-COLOR INPUT AND IMAGE SIZE IS PROPORTIONAL TO 16x16.
; DUE TO SPECIFIC METHODS, AVI OPERATIONS CAN HANG IDL OR OPERATING SYSTEM IN
; CASE OF INCORRECT WORKING WITH IT.

;++++++++++++++++++++++++++++++++++++++++++++++++++
; Necessary routines for working with AVI, MPEG, QT
;++++++++++++++++++++++++++++++++++++++++++++++++++

FUNCTION MOVIE2AVS, filename, type, filters
;+
; NAME:
;	MOVIE2AVS
;
; PURPOSE:
;	Creates .avs association file for AVI, MPEG, QT movie.
;	 With Avisynth server this .avs might be opened as AVI.
;	 See http://www.avisynth.org
;	 for free Avisynth (remember to properly install it),
;	 tested with Avisynth 2.5 for Win2000/IDL6.1, XP/IDL5.5
;
; CALLING SEQUENCE:
;	MOVIE2AVS, filename, type, filters
;
; INPUTS:
;	filename: Filename.
;	type: Type of file, 'AVI', 'MPEG', 'QT' or 'DVD'
;	filters: Array of strings describing Avisynth filters
;
; OUTPUT: .avs associated filename
;
; EXAMPLE:
;	filters=['#Bob()', $
;		'Sharpen(1)', $
;		'#ConvertToYUY2()', $
;		'Levels(0,5,255,0,255)', $
;		'#BilinearResize(640,480)']
;	avi_id=AVI_OPENR(MOVIE2AVS('idl.avi'), 'AVI', filters)
;	image=AVI_GET(avi_id,5)
;	AVI_CLOSER,avi_id
;-
OPENW, unit, filename+'.avs', /GET_LUN
IF type EQ 'AVI' THEN PRINTF, unit, 'AVISource("'+filename+'")' $
ELSE PRINTF, unit, 'DirectShowSource("'+filename+'")'
FOR i=0, N_ELEMENTS(filters)-1 DO PRINTF, unit, filters(i)
FREE_LUN, unit
RETURN, filename+'.avs'
END

FUNCTION AVI_OPENR, filename, red, green, blue
;+
; NAME:
;	AVI_OPENR
;
; PURPOSE:
;	Opens AVI file for reading.
;
; CALLING SEQUENCE:
;	avi_id=AVI_OPENR(filename, red, green, blue)
;
; INPUTS:
;	filename: Filename.
;	red,green,blue: If AVI is 8bpp, components of palette, undefined
;	 for 16bpp and 24bpp.
;
; OUTPUT:
;	avi_id: Vector type long to be associated with the opened file.
;	 Consist of bpp, width, height, length and 5 reserved values.
;	 Can be used for obtaining information about AVI file.
;
; EXAMPLE:
;	avi_id=AVI_OPENR('idl.avi', red, green, blue)
;-
IF filename EQ '' THEN MESSAGE, 'Unable to open file'
avi_id=LONARR(9)
red=BYTARR(256, /NOZERO) & green=BYTARR(256, /NOZERO) & blue=BYTARR(256, /NOZERO)
error=CALL_EXTERNAL('avi.dll','avi_openr',avi_id,filename,red,green,blue)
CASE error OF
 0: RETURN, avi_id
 1: error_message='Unable to open '+filename
 2: error_message='Unable to open stream 0'
 3: error_message='Unable to get frame at all'
 4: error_message='Unable to read info'
 5: error_message='Unable to get frame 0'
 ENDCASE
MESSAGE, error_message
END

FUNCTION AVI_GET, avi_id, frame
;+
; NAME:
;	AVI_GET
;
; PURPOSE:
;	Reads frame from opened for reading AVI file.
;
; CALLING SEQUENCE:
;	image=AVI_GET(avi_id, frame)
;
; INPUTS:
;	avi_id: The unit associated with the opened file.
;	frame: Number of frame to read.
;
; OUTPUT: Image, dimension is (x,y) for 8 bpp, (2,x,y) for 16 bpp, (3,x,y) for 24 bpp.
;
; EXAMPLE:
;	image=AVI_GET(avi_id, 5)
;-
IF N_ELEMENTS(avi_id) NE 9 THEN MESSAGE, 'Not valid AVI_ID'
IF avi_id(0) EQ 8 THEN image=BYTARR(avi_id(1), avi_id(2), /NOZERO) $
ELSE image=BYTARR(avi_id(0)/8, avi_id(1), avi_id(2), /NOZERO)
error=CALL_EXTERNAL('avi.dll','avi_get',avi_id,LONG(frame),image)
IF error THEN PRINT, 'Unable to get frame '+STRTRIM(STRING(frame),2)
RETURN, image
END

PRO AVI_CLOSER, avi_id
;+
; NAME:
;	AVI_CLOSER
;
; PURPOSE:
;	Closes opened for reading AVI file.
;
; CALLING SEQUENCE:
;	AVI_CLOSER, avi_id
;
; INPUTS:
;	avi_id: The unit associated with the opened file.
;
; EXAMPLE:
;	AVI_CLOSER, avi_id
;-
IF N_ELEMENTS(avi_id) NE 9 THEN MESSAGE, 'Not valid AVI_ID'
error=CALL_EXTERNAL('avi.dll','avi_closer',avi_id)
avi_id=0
END

FUNCTION AVI_OPENW, filename, dimensions, red, green, blue, RATE=rate,TRUE=true, $
 CODEC=codec, QUALITY=quality, IFRAME_GAP=iframe_gap, BITRATE=bitrate
;+
; NAME:
;	AVI_OPENW
;
; PURPOSE:
;	Opens AVI file for writing.
;
; CALLING SEQUENCE:
;	avi_id=AVI_OPENW(filename, dimensions, red, green, blue, RATE=rate, $
;	 CODEC=codec, QUALITY=quality, IFRAME_GAP=iframe_gap, BITRATE=bitrate)
;
; INPUTS:
;	filename: Filename.
;	dimensions: Size [width,height] of AVI file.
;	/RATE: framerate, default is 15 fps.
;	/TRUE: Creates 24bpp AVI.
;	/CODEC: Video codec description (four character string),
;	 depends from installed codecs,	if omitted, then compression dialog will appear.
;
;	 Some codec's descriptions (as displayed in VirtualDub, http://www.virtualdub.org):
;	  Cinepak Codec by Radius - 'CVID'
;	  DivX codec - 'DIVX'
;	  Indeo Video R3.2 - 'IV32'
;	  Indeo Video 5.11 - 'IV50'
;	  Indeo Video R1.2 - 'YVU9'
;	  Microsoft H261 - 'M261'
;	  Microsoft H263 - 'M263'
;	  Microsoft Mpeg4 V1 - 'MPG4'
;	  Microsoft Mpeg4 V2 - 'MP42'
;	  Microsoft RLE - 'MRLE'
;	  Microsoft Video1 - 'MSVC'
;	  XVID codec - 'XVID'
;
;	/QUALITY: Integer value between 0 (low quality) and 100 (high quality)
;	/IFRAME_GAP: Specifies the number of frames between I frames
;	/BITRATE: Value to specify the movie bits per second
;
;	NOTE: Some codecs (DivX, Xvid, Mpg4, Mp42) does't support
;	 this QUALITY, IFRAME_GAP, BITRATE settings, instead they remember
;	 last settings that was made, for example using compression dialog
;
;	red,green,blue: If AVI file is 8bpp, components of palette, if
;	 omitted then current palette is used.
;
; OUTPUT:
;	avi_id: Vector type long to be associated with the opened file.
;	 Consist of bpp, width, height, length and 5 reserved values.
;	 Can be used for obtaining information about AVI file.
;
; EXAMPLE:
;	avi_id=AVI_OPENW('idl.avi', [320,240], RATE=3, /TRUE, $
;	 CODEC='MSVC', QUALITY=100, IFRAME_GAP=15, BITRATE=500000l)
;-
IF filename EQ '' THEN MESSAGE, 'Unable to open file'
IF N_ELEMENTS(dimensions) NE 2 THEN MESSAGE, 'Illegal dimensions'
IF NOT KEYWORD_SET(RATE) THEN rate=15
rate=1 > rate < 25
COMMON colors, r_orig, g_orig, b_orig, r_curr, g_curr, b_curr
IF NOT KEYWORD_SET(TRUE) THEN BEGIN
 avi_id=[8l,LONG(dimensions),LONARR(6)]
 r=BYTARR(256, / NOZERO) & g=BYTARR(256, /NOZERO) & b=BYTARR(256, /NOZERO)
 IF N_ELEMENTS(red) LE 0 THEN BEGIN
  IF N_ELEMENTS(r_curr) EQ 0 THEN LOADCT, 0, /SILENT
  red=r_curr & green=g_curr & blue=b_curr
  ENDIF
 r(0)=red & g(0)=green & b(0)=blue
ENDIF ELSE BEGIN
 avi_id=[24l,LONG(dimensions),LONARR(6)]
 r=0b & g=0b & b=0b
ENDELSE
IF NOT KEYWORD_SET(CODEC) THEN codec=''
codec=BYTE(codec)
IF N_ELEMENTS(codec) NE 4 THEN codec=BYTARR(4)
IF NOT KEYWORD_SET(QUALITY) THEN quality=100
quality=0 > quality < 100
IF NOT KEYWORD_SET(IFRAME_GAP) THEN iframe_gap=0
IF NOT KEYWORD_SET(BITRATE) THEN bitrate=0
error=CALL_EXTERNAL('avi.dll','avi_openw',avi_id,filename,r,g,b,BYTE(rate), $
 BYTE(codec),BYTE(quality),LONG(iframe_gap),LONG(bitrate))
CASE error OF
 0: RETURN, avi_id
 1: error_message='Unable to create '+filename
 2: error_message='Unable to allocate memory'
 3: error_message='Unable to create stream'
 4: error_message='Unable to set options'
 5: error_message='Unable to create compressed stream'
 6: error_message='Unable to set stream format'
 ENDCASE
MESSAGE, error_message
END

PRO AVI_PUT, avi_id, frame, image
;+
; NAME:
;	AVI_PUT
;
; PURPOSE:
;	Writes frame to opened for writing AVI file.
;
; CALLING SEQUENCE:
;	AVI_PUT(avi_id, frame, image)
;
; INPUTS:
;	avi_id: The unit associated with the opened file.
;	frame: Number of frame to read.
;	image: Image for writing, should be (x,y) for 8 bpp,
;	 (2,x,y) for 16 bpp, (3,x,y) for 24 bpp.
;
; EXAMPLE:
;	AVI_PUT(avi_id, 5, image)
;-
IF N_ELEMENTS(avi_id) NE 9 THEN MESSAGE, 'Not valid AVI_ID'
IF N_ELEMENTS(image) NE avi_id(0)/8*avi_id(1)*avi_id(2) THEN RETURN
IF SIZE(image, /TYPE) NE 1 THEN image=BYTE(image)
error=CALL_EXTERNAL('avi.dll','avi_put',avi_id,LONG(frame),image)
IF error THEN PRINT, 'Unable to put frame '+STRTRIM(STRING(frame),2)
avi_id(3)=avi_id(3)+1
END

PRO AVI_CLOSEW, avi_id
;+
; NAME:
;	AVI_CLOSEW
;
; PURPOSE:
;	Closes opened for writing AVI file.
;
; CALLING SEQUENCE:
;	AVI_CLOSEW, avi_id
;
; INPUTS:
;	avi_id: The unit associated with the opened file.
;
; EXAMPLE:
;	AVI_CLOSEW, avi_id
;
;-
IF N_ELEMENTS(avi_id) NE 9 THEN MESSAGE, 'Not valid AVI_ID'
error=CALL_EXTERNAL('avi.dll','avi_closew',avi_id)
avi_id=0
END

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
; Useful routines for working with video (not necessary for AVI):
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

FUNCTION TIME2FRAME, mtime, mframes, times
;+
; NAME:
;	TIME2FRAME
;
; PURPOSE:
;	Converts time to position of frame, useful for reading frames from AVI.
;	Having start time, finish time and number of frames in movie, it allow to
;	position in movie with time, not just frames.
;
; CALLING SEQUENCE:
;	frames=TIME2FRAME(mtime, mframes, times)
;
; INPUTS:
;	mtime: The vector [shour,smin,ssec,sdsec,fhour,fmin,fsec,fdsec]
;	 with start and finish time (movie for example).
;	mframes: Number of frames (in movie).
;	times: 2D array of positions to convert, each line is time
;	 [hour,min,sec,dsec] for one position.
;
; OUTPUT:
;	frames: Numbers of frames.
;
; EXAMPLE:
;	mtime=[15,0,0,0,16,0,0,0]
;	mframes=600
;	times=[[15,0,0,0],[15,30,0,0],[16,0,0,0]]
;	frames=TIME2FRAME(mtime, mframes, times)
;	It returns positions for frames 15:00, 15:30 and 16:00 in movie
;-
mtime(4)=mtime(4)+24*(mtime(4) LT mtime(0))
times(0,*)=times(0,*)+24*(times(0,*) LT mtime(0))
mtime_start=mtime(0)*36000.+mtime(1)*600.+mtime(2)*10+mtime(3)
mtime_interval=mtime(4)*36000.+mtime(5)*600.+mtime(6)*10+mtime(7)-mtime_start
frames=(times(0,*)*36000.+times(1,*)*600.+times(2,*)*10+times(3,*)- $
 mtime_start)*(mframes-1)/mtime_interval
RETURN, FIX(frames)
END

FUNCTION READ_IMAGE, file, nframes, GET_LEN=get_len, POS=pos, SIZ=siz, FLIP=flip
;+
; NAME:
;	READ_IMAGE
;
; PURPOSE:
;	Reads images from sequence of bmp, gif, jpg or file, created by FG-card.
;
; CALLING SEQUENCE:
;	Result=READ_IMAGE(file, nframes, POS=pos)
;
; INPUTS:
;	file: Filename.
;	nframes: Number of frames.
;
; KEYWORDS:
;	get_len: Returns number of frames.
;	pos: Positioning vector [start frame,finish frame].
;	siz: New [xsize, ysize] size of images.
;	flip: Flipping of image:
;	 0-None, 1-left->right, 2-bot->top, 3-bot->top,left->right
;
; OUTPUTS:
;	3D array of images.
;
; EXAMPLE:
;	images=READ_IMAGE('161195#3.img', 30, POS=[0, 300], SIZ=[256,256])
; 	Position of frames: x---x---x (nframes=3)
;-
;IF !d.name EQ 'WIN' THEN WIDGET_CONTROL, /HOURGLASS
IF NOT KEYWORD_SET(FLIP) THEN flip=0
CASE flip OF
 0: flip=0
 1: flip=5
 2: flip=7
 3: flip=2
 ENDCASE
type=STRLOWCASE(STRMID(file, STRLEN(file)-3, 3))
IF (type EQ 'bmp') OR (type EQ 'gif') OR (type EQ 'jpg') THEN BEGIN
 files=FINDFILE(STRMID(file,0,RSTRPOS(file,'\'))+'\*.'+type, COUNT=lframe)
 files=files(SORT(files))
 lframe=lframe-1
 IF KEYWORD_SET(GET_LEN) THEN RETURN, lframe
 IF NOT KEYWORD_SET(POS) THEN pos=[0,lframe] & pos_in=pos(SORT(pos))
 CASE type OF
  'bmp': ims=QUERY_BMP(files(0), info)
  'gif': ims=QUERY_GIF(files(0), info)
  'jpg': ims=QUERY_JPEG(files(0), info)
  ENDCASE
 ims=info.channels & width=info.dimensions(0) & height=info.dimensions(1)
 IF KEYWORD_SET(SIZ) THEN images=BYTARR(siz(0), siz(1), nframes, /NOZERO) $
 ELSE images=BYTARR(width, height, nframes, /NOZERO)
 num=(nframes-1) > 1
 FOR i=0, nframes-1 DO BEGIN
	sc=FIX((pos_in(1)-pos_in(0))/FLOAT(num)*i+pos_in(0))
	CASE type OF
     'bmp': BEGIN
	  IF ims EQ 1 THEN image=READ_BMP(files(sc)) $
	  ELSE image=REFORM((READ_BMP(files(sc)))(1,*,*),width,height)
	  END
	 'gif': READ_GIF, files(sc), image
	 'jpg': READ_JPEG, files(sc), image
	 ENDCASE
	IF KEYWORD_SET(SIZ) THEN image=CONGRID(image, siz(0), siz(1))
	IF KEYWORD_SET(FLIP) THEN image=ROTATE(image,flip)
	images(*,*,i)=image
	ENDFOR
 ENDIF ELSE BEGIN
 OPENR, unit, file, /GET_LUN
 length=FSTAT(unit)   &   length=length.size-5
 width=0   &   height=0
 POINT_LUN, unit, length   &   READU, unit, width, height
 npoints=LONG(width)*height   &   lframe=length/npoints-1
 IF KEYWORD_SET(GET_LEN) THEN RETURN, lframe
 IF NOT KEYWORD_SET(POS) THEN pos=[0,lframe] & pos_in=pos(SORT(pos))
 image=BYTARR(width, height, /NOZERO)
 IF KEYWORD_SET(SIZ) THEN BEGIN width=siz(0) & height=siz(1) & END
 images=BYTARR(width, height, nframes, /NOZERO)
 num=(nframes-1) > 1
 FOR i=0, nframes-1 DO BEGIN
	sc=FIX((pos_in(1)-pos_in(0))/FLOAT(num)*i+pos_in(0))
	POINT_LUN, unit, npoints*sc
	READU, unit, image
	IF KEYWORD_SET(SIZ) THEN  $
	 images(*, *, i)=ROTATE(CONGRID(image, width, height), flip)*4b $
	ELSE images(*, *, i)=ROTATE(image, flip)*4b
	ENDFOR
 FREE_LUN, unit
 ENDELSE
RETURN, images
END

PRO ANIMATE_DATA, anim_size, anim_pro, DATA=data, TYPE=type, FILE=file
;+
; NAME:
;	ANIMATE_DATA
;
; PURPOSE:
;	Data animation.
;
; CALLING SEQUENCE:
;	ANIMATE_DATA, anim_size, anim_pro
;
; INPUTS:
;	anim_size: Vector [width, height, nframes] of animation size.
;	anim_pro: String name of procedure that prepare window for animation.
;
; KEYWORDS:
;	data: Data (structure, for example) for transfer to anim_pro.
;	type: Type of output:
;	1-online animation, 2-bmps, 3-gifs, 4-jpegs, 5-avi, 6-mpeg, 7-no.
;	file: File for output.
;
; EXAMPLE:
;
;	PRO SHOW_DATA, frame, DATA=data
;	TV, data+i*10
;	END
;
;	data=DIST(320,240)
;	ANIMATE_DATA, [320, 240, 30], 'SHOW_DATA', DATA=data
;-
IF NOT KEYWORD_SET(TYPE) THEN type=1
IF NOT KEYWORD_SET(FILE) THEN BEGIN
 IF (type EQ 2) OR (type EQ 3) OR (type EQ 4) THEN BEGIN
  file=PICKFILE(FILE='Frames', TITLE='Type directory for output')
  SPAWN, 'mkdir '+file
  ENDIF
 IF type EQ 5 THEN file=PICKFILE(FILE='*.avi', /WRITE)
 IF type EQ 6 THEN file=PICKFILE(FILE='*.mpg', /WRITE)
 ENDIF
;RESOLVE_ROUTINE, anim_pro
IF type EQ 1 THEN BEGIN
 base=WIDGET_BASE(TITLE='Animation')
 anim=CW_ANIMATE(base, anim_size(0), anim_size(1), anim_size(2))
 WIDGET_CONTROL, base, /REALIZE
 ENDIF ELSE BEGIN
 WINDOW,3,XPOS=0,YPOS=0,XSIZE=anim_size(0),YSIZE=anim_size(1),TITLE='Animation'
 WSET, 3
 ENDELSE
IF (type EQ 2) OR (type EQ 3) OR (type EQ 4) THEN OPENW,unit,file+'\list.lst',/GET_LUN
IF type EQ 5 THEN unit=AVI_OPENW(file, anim_size(0:1), /TRUE)
IF type EQ 6 THEN unit=MPEG_OPEN(anim_size(0:1), FILENAME=file)
FOR i=0, anim_size(2)-1 DO BEGIN
 CALL_PROCEDURE, anim_pro, i, DATA=data
 IF type EQ 1 THEN CW_ANIMATE_LOAD, anim, FRAME=i, WINDOW=!d.window
 IF (type EQ 2) OR (type EQ 3) OR (type EQ 4) THEN BEGIN
  filename=file+'\'+STRMID(STRING(10000+i+1), 4, 4)
  CASE type OF
   2: BEGIN
    filename=filename+'.bmp'
    WRITE_BMP, filename, REVERSE(TVRD(/TRUE), 1)
    END
   3: BEGIN
    filename=filename+'.gif'
    WRITE_GIF, filename, COLOR_QUAN(TVRD(/TRUE),1,r,g,b),r,g,b
    END
   4: BEGIN
    filename=filename+'.jpg'
    WRITE_JPEG, filename, TVRD(/TRUE), /TRUE, QUAL=100
    END
   ENDCASE
  PRINTF, unit, filename
  ENDIF
 IF type EQ 5 THEN AVI_PUT, unit, i, TVRD(/TRUE)
 IF type EQ 6 THEN MPEG_PUT, unit, FRAME=i, WINDOW=!d.window, /ORDER
 ENDFOR
IF type EQ 1 THEN BEGIN
 CW_ANIMATE_RUN, anim, 10
 XMANAGER, 'ANIMATE', base
 ENDIF ELSE WDELETE, 3
IF (type EQ 2) OR (type EQ 3) OR (type EQ 4) THEN FREE_LUN, unit
IF type EQ 5 THEN AVI_CLOSEW, unit
IF type EQ 6 THEN BEGIN
 MPEG_SAVE, unit, FILENAME=file
 MPEG_CLOSE, unit
 ENDIF
END

PRO ANIMATE_EVENT, event
WIDGET_CONTROL, event.top, /DESTROY
END