@movie_io

PRO AVI_WRITE_IND
; Example that shows how to write indexed images to AVI
; it works with some old video codecs only !!!

avi_size=[320,240] & nframes=30
DEVICE,DEC=0 & LOADCT,15 & TVLCT,r,g,b,/GET
data2d=BYTE(DIST(avi_size(0),avi_size(1)))   ; prepare some test data
avi_id=AVI_OPENW('idl.avi', avi_size, r,g,b, RATE=15)   ; open AVI for writing
print,SYSTIME()   ; for speed test
FOR i=0, nframes-1 DO BEGIN
 data2d=data2d+10b   ; change our data
 AVI_PUT, avi_id, i, data2d   ; put it into AVI
 ENDFOR
print,SYSTIME()
AVI_CLOSEW, avi_id   ; close our AVI file
data2d=0
END



PRO AVI_WRITE_TRUE
; Example that shows how to write true-color images to AVI

avi_size=[320,240] & nframes=30
DEVICE,DEC=0 & LOADCT,15 & TVLCT,r,g,b,/GET
data2d=BYTE(DIST(avi_size(0),avi_size(1)))   ; prepare some test data
data3d=BYTARR(3,avi_size(0),avi_size(1))   ; prepare true-color empty matrix
avi_id=AVI_OPENW('idl.avi', avi_size, /TRUE, RATE=15, $
 CODEC='MP42',QUALITY=100,IFRAME_GAP=15,BITRATE=1000000l)   ; open AVI for writing

;	NOTE: Some codecs (DivX, Xvid, Mpg4, Mp42) does't support
;	 this QUALITY, IFRAME_GAP, BITRATE settings, instead they remember
;	 last settings that was made, for example using compression dialog
;	 or within other video software
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
print,SYSTIME()   ; for speed test
FOR i=0,nframes-1 DO BEGIN
 data2d=data2d+10b   ; change our data
 data3d(0,*,*)=r(data2d)   ; fill true-color matrix
 data3d(1,*,*)=g(data2d)
 data3d(2,*,*)=b(data2d)
 AVI_PUT, avi_id, i, data3d
 ENDFOR
print,SYSTIME()
AVI_CLOSEW, avi_id   ; close our AVI file
data2d=0 & data3d=0
END



PRO AVI_READ
; Example that shows how to read true-color images from AVI
; using online preprocessing (deinterlacing, etc.) with Avisynth frameserver
; see movie_io.pro and Avisynth documentation for details
;DEVICE,DEC=0   ; For indexed image

DEVICE,DEC=1   ; For true-color
filters=['#Bob()', $   ; Some filter script for Avisynth frameserver
	'Sharpen(1)', $
	'#ConvertToYUY2()', $
	'Levels(0,5,255,0,255)', $
	'#BilinearResize(640,480)']

avi_id=AVI_OPENR(PICKFILE(),r,g,b)   ; direct open, might not work starting XP SP3, try shown below
;avi_id=AVI_OPENR(MOVIE2AVS(PICKFILE(),'AVI'),r,g,b)   ; open using frameserver, require Avisynth
;avi_id=AVI_OPENR(MOVIE2AVS(PICKFILE(),'AVI',filters),r,g,b)   ; open using frameserver with preprocessing, require Avisynth
;avi_id=AVI_OPENR(MOVIE2AVS(PICKFILE(),'DVD'),r,g,b)   ; open DVD using frameserver and 'DirectShowSource' filter, 
;	require Avisynth, note that 'DirectShowSource' not always accurate with frame seeking, 
;	try to explore DGDecode filter (http://avisynth.org/mediawiki/External_filters)


PRINT, avi_id   ; avi_id is [bpp, xsize, ysize, nframes, ...some internal info]
nframes=30 ;avi_id(3)
XINTERANIMATE, SET=[avi_id(1),avi_id(2),nframes], /SHOWLOAD
PRINT,SYSTIME()   ; for speed test
FOR i=0, nframes-1 DO BEGIN
 data=AVI_GET(avi_id, i+0)   ; read true-color data from AVI
 TV, data, /TRUE

 ;data=COLOR_QUAN(data,1,r,g,b) ; Quantization to indexed colors
 ;TVLCT,r,g,b ; Loading color tables after quantization
 ;TV, data ; Showing indexed image

 XINTERANIMATE, FRAME=i, WINDOW=!d.window
ENDFOR
PRINT,SYSTIME()
AVI_CLOSER, avi_id   ; close our AVI file
XINTERANIMATE
data=0
END